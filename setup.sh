#! /bin/bash

#sets environment variables
export REGION=us-central1
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
#this copies down the world file from the project specific world storage bucket
sudo apt-get update -y
sudp apt install wget
sudo mkdir /tmp/world
touch test.txt
wget https://storage.cloud.google.com/$DEVSHELL_PROJECT_ID-$REGION-$NAME/$WORLD /tmp/world/world/$WORLD
EOF

#creates the world file storage bucket, copies the file to it from this repo, and assigns permissions to ce service account
gsutil mb -b on gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME
gsutil cp ./$WORLD gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME/$WORLD
gsutil iam ch allUsers:objectViewer gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME

#creates the startup scripts storage bucket, copies the file created above, and sets permissions to ce service account
gsutil mb -b on gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts
gsutil iam ch allUsers:objectViewer gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts
gsutil cp ./startup-script.sh gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts/startup-script.sh

#creates the k8s cluster in the sepcified region/zone with the generated startup script
gcloud beta container --project $DEVSHELL_PROJECT_ID clusters create $NAME --zone $ZONE  --image-type "UBUNTU" --scopes "https://www.googleapis.com/auth/cloud-platform" --metadata startup-script-url=https://storage.cloud.google.com/$DEVSHELL_PROJECT_ID-$REGION-startup-scripts/startup-script.sh,disable-legacy-endpoints=true

#creates the flux namespace and generates an ssh key
kubectl create namespace flux
ssh-keygen -t rsa -N '' -f ./flux/id_rsa -C flux <<< y
kubectl create secret generic flux-ssh --from-file=identity=./flux/id_rsa -n flux

#creates an executable to be invoked that creates a git deploy key on the repo specified above
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
rm git-key-deploy.sh

#installs flux and helm operator that will kick off and manage the terraria server deployment
cd flux
./installFlux.sh andrew
./installHelmOperator.sh

rm ../startup-script.sh
kubectl delete pod -n flux -l app=flux