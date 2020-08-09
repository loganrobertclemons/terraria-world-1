#! /bin/bash
sudo apt-get update -y
curl https://sdk.cloud.google.com | bash
exec -l /bin/bash
mkdir /tmp/worlds
gsutil cp gs://exam-prep-285301-startup-script/startup-script.sh /tmp/worlds
