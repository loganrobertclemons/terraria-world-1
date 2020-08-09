git clone $GIT
export GIT=https://github.com/ammilam/terraria-world-1.git 
export NAME=terraria-world-1
export WORLD=worlds_World_1.wld
gsutil mb gs://$DEVSHELL_PROJECT_ID-startup-script
gsutil cp ./startup-script.sh gs://$DEVSHELL_PROJECT_ID-startup-script/startup-script.sh
gsutil acl ch -d $A:READ gs://$DEVSHELL_PROJECT_ID-startup-script/startup-script.sh
gcloud container clusters create $NAME-$DEVSHELL_PROJECT_ID --zone us-central1-a --metadata=startup-script-url=gs://$DEVSHELL_PROJECT_ID-startup-script/startup-script.sh
export A=$(gcloud iam service-accounts list   --filter='email ~ [0-9]*-compute@.*'   --format='(email)'|grep compute)
kubectl create namespace flux
kubectl create secret generic flux-ssh --from-file=identity=./$NAME/flux/id_rsa -n flux
./flux/installFlux.sh andrew
./flux/installHelmOperator.sh
gsutil mb gs://$DEVSHELL_PROJECT_ID-terraria-world-1
gsutil cp ./$WORLD gs://$DEVSHELL_PROJECT_ID-terraria-world-1/$WORLD
gsutil acl ch -d $A:READ gs://$NAME/$WORLD

gcloud container clusters create $NAME-$DEVSHELL_PROJECT_ID --zone us-central1-a --metadata=startup-script-url=gs://$DEVSHELL_PROJECT_ID-startup-script/startup-script.sh
