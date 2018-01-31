#!/bin/sh

#Maven build 과정 중 테스트 수행 여부
MVN_TEST_SKIP=true;

#기존에 생성된 Docker Image, Kubernetes deploy, service 삭제여부
#기존에 생성된 Kubernetes deploy, service는 kubectl apply로 덮어쓰기 불가, 삭제 후 재생성 필요 
DELETE_PREVIOUS_DOCKER_IMAGE_AND_KUBERNETES_DEPLOYMENT=true;

#Docker Repository 정보
#Docker hub는 DOCKER_REPOSITORY_PROJECT와 DOCKER_REPOSITORY_USER 동일
DOCKER_REPOSITORY_URL="harbor1.ghama.io"
DOCKER_REPOSITORY_PROJECT="test"
DOCKER_REPOSITORY_USER="bckim0620"
DOCKER_REPOSITORY_PASSWORD="Skcc1234"
DOCKER_IMAGE_NAME="test-app"

#Kuberetes deployment, service/Dockerfile 경로
#파일이 존재하는 폴더까지의 경로
KUBERNETES_DEPLOYMENT_PATH="./k8s/"
DOCKER_FILE_PATH="./"

#Kuberetes Cluster 정보
#ICP의 경우 포탈에서 Configur client 코드를 복사하여 line 65~69에 덮어쓰기
KUBERNETES_CLUSTER_NAME="mycluster.icp"
KUBERNETES_CLUSTER_URL="https://169.56.113.156:8001"
KUBERNETES_CLUSTER_USERNAME="admin"
KUBERNETES_CLUSTER_TOKEN="eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImF0X2hhc2giOiItNTA5YS00OWJ3T0tuTEk4Q0p1YmF3IiwiaXNzIjoiaHR0cHM6Ly9teWNsdXN0ZXIuaWNwOjk0NDMvb2lkYy9lbmRwb2ludC9PUCIsImF1ZCI6ImRmODJmYjY3YWEyMWZjZTc5N2M1ODBjNDI5MTEyMmQxIiwiZXhwIjoxNTE3NDE2MjcyLCJpYXQiOjE1MTczNzMwNzJ9.GVRfvuucvBu9Oa-4Myel8lneqw1lu84vdfuj8pR1TMuTpoy26CJPzSENu8gvEcG9uRSJX3jABlam5I10_bPuN9ZuM1H9oYt2pgZh_zuXEXiwmPIWGo23MVA_h4IXf7p5FuBxEKfsB8PYJarJl3u4-XXYErvXNy32trDv93uF0gV0ZGr7ZcTsYFzg5ogpqwDbL87uq4hoKO2_saUMqXgkzj3x_-vEiCHoDc0_9ALv-yhudqjzWaJjIXBQF3tsbsVjFYRrTiAtldMJSYaz3DYqt9oygJM-DUCZ7m_z1Tcco2g5jwF7ccd8z_qY91UGmbQo21LTXHfyOc6A1THwt4z9Kw"
KUBERNETES_CLUSTER_NAMESPACE="dtlabs08"
KUBERNETES_CONTEXT_NAME="mycluster.icp-context"



function showlog() {
	echo ""
	echo ""
	echo ""
	echo "--------------------------- $1 ---------------------------"
}

showlog "deploy.sh"

showlog "Maven install"

if ./mvnw clean install -Dmaven.test.skip=${MVN_TEST_SKIP}; then
	echo ""
else
	exit 1
fi

if ${DELETE_PREVIOUS_DOCKER_IMAGE_AND_KUBERNETES_DEPLOYMENT}; then
	showlog "Delete docker image, kubernetes deployment"
	kubectl delete -f ${KUBERNETES_DEPLOYMENT_PATH}
	docker rmi ${DOCKER_REPOSITORY_URL}/${DOCKER_REPOSITORY_PROJECT}/${DOCKER_IMAGE_NAME}
fi

showlog "Build/tag docker image" 
docker build ${DOCKER_FILE_PATH} -t ${DOCKER_REPOSITORY_URL}/${DOCKER_REPOSITORY_PROJECT}/${DOCKER_IMAGE_NAME}

showlog "Login docker repository"
docker login ${DOCKER_REPOSITORY_URL} -u ${DOCKER_REPOSITORY_USER} -p ${DOCKER_REPOSITORY_PASSWORD}

showlog "Push Docker image"
docker push ${DOCKER_REPOSITORY_URL}/${DOCKER_REPOSITORY_PROJECT}/${DOCKER_IMAGE_NAME}

showlog "Login kubernetes"
kubectl config set-cluster ${KUBERNETES_CLUSTER_NAME} --server=${KUBERNETES_CLUSTER_URL} --insecure-skip-tls-verify=true
kubectl config set-context ${KUBERNETES_CONTEXT_NAME} --cluster=${KUBERNETES_CLUSTER_NAME} 
kubectl config set-credentials ${KUBERNETES_CLUSTER_USERNAME} --token=${KUBERNETES_CLUSTER_TOKEN}
kubectl config set-context ${KUBERNETES_CONTEXT_NAME} --user=${KUBERNETES_CLUSTER_USERNAME} --namespace=${KUBERNETES_CLUSTER_NAMESPACE}
kubectl config use-context ${KUBERNETES_CONTEXT_NAME}

showlog "Create kuberetes deployment"
kubectl apply -f ${KUBERNETES_DEPLOYMENT_PATH}

showlog "Pod infomation"
kubectl get pod

showlog "Service infomation"
kubectl get service