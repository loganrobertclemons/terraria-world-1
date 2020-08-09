git clone https://github.com/ammilam/terraria-world-1.git 
kubectl create namespace flux
kubectl create secret generic flux-ssh --from-file=identity=./terraria-world-1/flux/id_rsa -n flux
cd ./terraria-world-1/flux
./installFlux.sh andrew
./installHelmOperator.sh
gsutil mb gs://terraria-world-1
gsutil cp ../worlds_World_1.wld gs://terraria-world-1/worlds_World_1.wld
