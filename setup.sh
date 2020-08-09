export NAME=terraria-world-1
export WORLD=worlds_World_1.wld
cat <<EOF >>startup-script.sh
#! /bin/bash
sudo mkdir /tmp/world
gsutil cp gs://$(echo $DEVSHELL_PROJECT_ID)-startup-script/startup-script.sh /tmp/world
EOF
gsutil mb gs://$DEVSHELL_PROJECT_ID-startup-script
gsutil cp ./startup-script.sh gs://$DEVSHELL_PROJECT_ID-startup-script/startup-script.sh
gsutil acl ch -d $A:READ gs://$DEVSHELL_PROJECT_ID-startup-script/startup-script.sh
gcloud beta container --project $DEVSHELL_PROJECT_ID clusters create $NAME --zone "us-central1-c" --no-enable-basic-auth --cluster-version "1.15.12-gke.2" --machine-type "e2-medium" --image-type "UBUNTU" --disk-type "pd-standard" --disk-size "100" --metadata startup-script-url=gs://$DEVSHELL_PROJECT_ID-startup-script/startup-script.sh,disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "3" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/$DEVSHELL_PROJECT_ID/global/networks/default" --subnetwork "projects/$DEVSHELL_PROJECT_ID/regions/us-central1/subnetworks/default" --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0
export A=$(gcloud iam service-accounts list   --filter='email ~ [0-9]*-compute@.*'   --format='(email)'|grep compute)
kubectl create namespace flux
kubectl create secret generic flux-ssh --from-file=identity=./flux/id_rsa -n flux
./flux/installFlux.sh andrew
./flux/installHelmOperator.sh
gsutil mb gs://$DEVSHELL_PROJECT_ID-terraria-world-1
gsutil cp ./$WORLD gs://$DEVSHELL_PROJECT_ID-terraria-world-1/$WORLD
gsutil acl ch -d $A:READ gs://$NAME/$WORLD