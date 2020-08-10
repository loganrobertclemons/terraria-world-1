#ssh-keygen -t rsa -N '' -f ./flux/id_rsa -C flux <<< y
#echo "add the following to your github repo "
#cat ./flux/id_rsa.pub
export REGION=us-west1
export ZONE=$REGION-b
export NAME=terraria-world-1
export WORLD=worlds_World_1.wld

cat <<EOF >>startup-script.sh
#! /bin/bash
sudo mkdir /tmp/world
gsutil cp gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME/$WORLD /tmp/world/world/$(echo $WORLD)
EOF

gsutil mb -b off gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME
gsutil cp ./$WORLD gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME/$WORLD
gsutil mb -b off gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts

export COMPUTE_ENGINE_SA_EMAIL=$(gcloud iam service-accounts list --filter="name:Compute Engine default service account" --format "value(email)")
gsutil iam ch serviceAccount:${COMPUTE_ENGINE_SA_EMAIL}:objectViewer gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts
gsutil iam ch serviceAccount:${COMPUTE_ENGINE_SA_EMAIL}:objectViewer gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME

gsutil cp ./startup-script.sh gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts/startup-script.sh
gsutil cp ./startup-script.sh gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts/startup-script.sh

gcloud beta container --project $DEVSHELL_PROJECT_ID clusters create $NAME --zone $ZONE --metadata startup-script-url=gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts/startup-script.sh,disable-legacy-endpoints=true

kubectl create namespace flux
kubectl create secret generic flux-ssh --from-file=identity=./flux/id_rsa -n flux
cd flux
echo "place this in git as a deploy key called flux-ssh"
cat id_rsa.pub
./installFlux.sh andrew
./installHelmOperator.sh

rm startup-script.sh