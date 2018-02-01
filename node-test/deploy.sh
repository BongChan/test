#!/bin/sh

#�옉�꽦以묒씤 Project 醫낅쪟
#maven, node
PROJECT_TYPE="node"

#Maven build 怨쇱젙 以� �뀒�뒪�듃 �닔�뻾 �뿬遺�
MAVEN_TEST_SKIP=true;

#湲곗〈�뿉 �깮�꽦�맂 Docker Image, Kubernetes deploy, service �궘�젣�뿬遺�
#湲곗〈�뿉 �깮�꽦�맂 Kubernetes deploy, service�뒗 kubectl apply濡� �뜮�뼱�벐湲� 遺덇�, �궘�젣 �썑 �옱�깮�꽦 �븘�슂 
DELETE_PREVIOUS_DOCKER_IMAGE_AND_KUBERNETES_DEPLOYMENT=true

#Docker Repository �젙蹂�
#Dockerhub registry: registry-1.docker.io
#Harbor registry: harbor1.ghama.io
#Docker hub�뒗 DOCKER_REPOSITORY_PROJECT�� DOCKER_REPOSITORY_USER �룞�씪
#DOCKER_REPOSITORY_URL="harbor1.ghama.io"
#DOCKER_REPOSITORY_PROJECT="test"
#DOCKER_REPOSITORY_USER="bckim0620"
#DOCKER_REPOSITORY_PASSWORD="Skcc1234"
#DOCKER_IMAGE_NAME="test-app"

DOCKER_REPOSITORY_URL="registry-1.docker.io"
DOCKER_REPOSITORY_PROJECT="coramdeo0620"
DOCKER_REPOSITORY_USER="coramdeo0620"
DOCKER_REPOSITORY_PASSWORD="qhdcksdlek123"
DOCKER_IMAGE_NAME="node-test-app"


#Kuberetes deployment, service/Dockerfile 寃쎈줈
#�뙆�씪�씠 議댁옱�븯�뒗 �뤃�뜑源뚯��쓽 寃쎈줈
KUBERNETES_DEPLOYMENT_PATH="./k8s/"
DOCKER_FILE_PATH="./"

#Kuberetes Cluster �젙蹂�
#ICP�쓽 寃쎌슦 �룷�깉�뿉�꽌 Configur client 肄붾뱶瑜� 蹂듭궗�븯�뿬 showlog "Login kubernetes" 諛묒뿉 �뜮�뼱�벐湲�
KUBERNETES_CLUSTER_NAME="mycluster.icp"
KUBERNETES_CLUSTER_URL="https://169.56.113.156:8001"
KUBERNETES_CLUSTER_USERNAME="admin"
KUBERNETES_CLUSTER_TOKEN="eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImF0X2hhc2giOiIzT2lwNy01VzZaNnRfVGxDQmVoR1pnIiwiaXNzIjoiaHR0cHM6Ly9teWNsdXN0ZXIuaWNwOjk0NDMvb2lkYy9lbmRwb2ludC9PUCIsImF1ZCI6ImRmODJmYjY3YWEyMWZjZTc5N2M1ODBjNDI5MTEyMmQxIiwiZXhwIjoxNTE3NTAyNDc4LCJpYXQiOjE1MTc0NTkyNzh9.cPG-_QtnLMqM1gV6TREurD8ToUM2c2GbrjcZJfXIvRZEgiNeyhqUp2HzBncNJIcx3LKWmNlNInTz-HTR1spt9j-EyTtetTQTspfW1GmuA4FX207yLwHz7M9veRkQx7uOMekUomfUYnZYyuXEUnicthrilhqldz6gIS-xtd9cnSU-d0qIOR3Syl1O20z_ektN5GL0KqoFaC_QHY2in8h94E_jSnuXU3WPCRxOaet31r0LquXHaIFgdRZAMbKqlr5j15YTSpnctOzq-ipbacFKE-UlPaep5bEm-UMqTbrGW4a318x8TXRjmNdbYqQaQ--tBKhmPhPc_8xnWXgcMPfSFQ"
KUBERNETES_CLUSTER_NAMESPACE="dtlabs08"
KUBERNETES_CONTEXT_NAME="mycluster.icp-context"



function showlog() {
	echo ""
	echo ""
	echo ""
	echo "--------------------------- $1 ---------------------------"
}

showlog "deploy.sh"

showlog "Packaging"

if [ "${PROJECT_TYPE}" == "maven" ]; then
	showlog "Maven packaging"
	if ./mvnw clean install -Dmaven.test.skip=${MAVEN_TEST_SKIP}; then
		echo ""
	else
		exit 1
	fi
else
	showlog "Node packging"
fi

if ${DELETE_PREVIOUS_DOCKER_IMAGE_AND_KUBERNETES_DEPLOYMENT}; then
	showlog "Delete docker image, kubernetes deployment"
	kubectl delete -f ${KUBERNETES_DEPLOYMENT_PATH}
	docker rmi ${DOCKER_REPOSITORY_URL}/${DOCKER_REPOSITORY_PROJECT}/${DOCKER_IMAGE_NAME}
fi

showlog "Build/Tag docker image" 
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