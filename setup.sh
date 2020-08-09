#ssh-keygen -t rsa -N '' -f ./flux/id_rsa -C flux <<< y
#echo "add the following to your github repo "
#cat ./flux/id_rsa.pub
export REGION=us-central1
export ZONE=$REGION-b
export NAME=terraria-world-1
export WORLD=worlds_World_1.wld
export A=$(echo $(gcloud iam service-accounts list   --filter='email ~ [0-9]*-compute@.*'   --format='(email)'|grep compute))
cat <<EOF >>startup-script.sh
#! /bin/bash
sudo mkdir /tmp/world
gsutil cp https://storage.cloud.google.com/$(echo $DEVSHELL_PROJECT_ID)-$(echo $NAME)/$(echo $WORLD)?authuser=1 /tmp/world/world/$(echo $WORLD)
EOF
gsutil mb gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME
gsutil cp ./$WORLD gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME/$WORLD
gsutil mb gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts
gsutil cp ./startup-script.sh gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts/startup-script.sh
gsutil cp ./startup-script.sh gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts/startup-script.sh
gcloud beta container --project $DEVSHELL_PROJECT_ID clusters create $NAME --zone $ZONE --metadata startup-script-url=gs://$DEVSHELL_PROJECT_ID-startup-scripts/startup-script.sh,disable-legacy-endpoints=true
echo "compute service account is" $A
gsutil acl ch -d $A:READ gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME/$WORLD
gsutil acl ch -d $A:READ gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts/startup-script.sh
kubectl create namespace flux
kubectl create secret generic flux-ssh --from-file=identity=./flux/id_rsa -n flux
cd flux
./installFlux.sh andrew
./installHelmOperator.sh
rm startup-script.sh