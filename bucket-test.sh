export REGION=us-central1
export ZONE=$REGION-b
export NAME=terraria-world-1-shit


gsutil mb -b on gs://$DEVSHELL_PROJECT_ID-$REGION-$NAME
gsutil mb -b on gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts

export COMPUTE_ENGINE_SA_EMAIL=$(gcloud iam service-accounts list --filter="name:Compute Engine default service account" --format "value(email)")
gsutil iam ch serviceAccount:$COMPUTE_ENGINE_SA_EMAIL:objectViewer gs://$DEVSHELL_PROJECT_ID-$REGION-startup-scripts