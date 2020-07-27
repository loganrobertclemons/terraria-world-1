gcloud config set project southern-scene-271919 
gcloud iam service-accounts add-iam-policy-binding \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:southern-scene-271919.svc.id.goog[flux/flux]" \
  flux-gcp@southern-scene-271919.iam.gserviceaccount.com
