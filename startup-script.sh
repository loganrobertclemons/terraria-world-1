#! /bin/bash
sudo apt-get update -y
curl https://sdk.cloud.google.com | bash
exec -l $SHELL