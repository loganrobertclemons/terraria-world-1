#! /bin/bash
kubectl create namespace flux
kubectl create secret generic flux-ssh --from-file=identity=./flux/id_rsa -n flux
./flux/installFlux.sh 
./flux/installHelmOperator.sh
gsutil mb gs://terraria-world-1
gsutil cp worlds_World_1.wld gs://terraria-world-1/worlds_World_1.wld