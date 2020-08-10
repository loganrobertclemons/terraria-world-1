#! /bin/bash

#sets environment variables
export REGION=us-east1
export ZONE=$REGION-b
export NAME=terraria-world-1
export WORLD=worlds_World_1.wld
export COMPUTE_ENGINE_SA_EMAIL=$(gcloud iam service-accounts list --filter="name:Compute Engine default service account" --format "value(email)")

#sets github specific environment variables to be used later
read -p 'GitHub Repo: ' REPO
read -p 'GitHub Username: ' USERNAME
read -sp 'GitHub Password: ' PASSWORD

#creates startup script that the k8s vms will use
cat <<EOF >>startup-script.sh
#! /bin/bash
sudo mkdir /tmp/world
#this copies down the world file from the project specific world storage bucket
gsutil cp gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME/$WORLD /tmp/world/world/$(echo $WORLD)
EOF

#creates the world file storage bucket, copies the file to it from this repo, and assigns permissions to ce service account
gsutil mb -b on gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME
gsutil cp ./$WORLD gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME/$WORLD
gsutil iam ch serviceAccount:$COMPUTE_ENGINE_SA_EMAIL:objectViewer gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME

#creates the startup scripts storage bucket, copies the file created above, and sets permissions to ce service account
gsutil mb -b on gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts
gsutil iam ch serviceAccount:$COMPUTE_ENGINE_SA_EMAIL:objectViewer gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts
gsutil cp ./startup-script.sh gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts/startup-script.sh

gcloud beta container --project $DEVSHELL_PROJECT_ID clusters create $NAME --zone $ZONE --metadata startup-script-url=gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts/startup-script.sh,disable-legacy-endpoints=true

kubectl create namespace flux
ssh-keygen -t rsa -N '' -f ./flux/id_rsa -C flux <<< y
kubectl create secret generic flux-ssh --from-file=identity=./flux/id_rsa -n flux

cat <<EOF >>git-key-deploy.sh
#! /bin/bash
curl \
  -X POST \
  -u $USERNAME:$PASSWORD \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$USERNAME/$REPO/keys \
  -d '{"key":"$(cat ./flux/id_rsa.pub)","title":"flux-ssh"}'
EOF

sudo chmod +x git-key-deploy.sh
./git-key-deploy.sh

cd flux
./installFlux.sh andrew
./installHelmOperator.sh

rm ../startup-script.sh
kubectl delete pod -n flux -l app=flux