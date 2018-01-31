#!/bin/sh
function showlog() {
	echo "\n\n\n --------------------------- $1 ---------------------------"
}

showlog "deploy.sh"

showlog "maven package"
./mvnw clean install

showlog "docker build" 
docker build . -t coramdeo0620/test-app

showlog "docker push"
docker push coramdeo0620/test-app

showlog "kubectl login"
kubectl config set-cluster mycluster.icp --server=https://169.56.113.156:8001 --insecure-skip-tls-verify=true
kubectl config set-context mycluster.icp-context --cluster=mycluster.icp
kubectl config set-credentials admin --token=eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImF0X2hhc2giOiItNTA5YS00OWJ3T0tuTEk4Q0p1YmF3IiwiaXNzIjoiaHR0cHM6Ly9teWNsdXN0ZXIuaWNwOjk0NDMvb2lkYy9lbmRwb2ludC9PUCIsImF1ZCI6ImRmODJmYjY3YWEyMWZjZTc5N2M1ODBjNDI5MTEyMmQxIiwiZXhwIjoxNTE3NDE2MjcyLCJpYXQiOjE1MTczNzMwNzJ9.GVRfvuucvBu9Oa-4Myel8lneqw1lu84vdfuj8pR1TMuTpoy26CJPzSENu8gvEcG9uRSJX3jABlam5I10_bPuN9ZuM1H9oYt2pgZh_zuXEXiwmPIWGo23MVA_h4IXf7p5FuBxEKfsB8PYJarJl3u4-XXYErvXNy32trDv93uF0gV0ZGr7ZcTsYFzg5ogpqwDbL87uq4hoKO2_saUMqXgkzj3x_-vEiCHoDc0_9ALv-yhudqjzWaJjIXBQF3tsbsVjFYRrTiAtldMJSYaz3DYqt9oygJM-DUCZ7m_z1Tcco2g5jwF7ccd8z_qY91UGmbQo21LTXHfyOc6A1THwt4z9Kw
kubectl config set-context mycluster.icp-context --user=admin --namespace=dtlabs08
kubectl config use-context mycluster.icp-context

showlog "kubectl apply"
kubectl apply -f k8s/

