#!/bin/bash

read -p 'GitHub Repo: ' REPO
read -p 'GitHub Username: ' USERNAME
read -sp 'GitHub Password: ' PASSWORD

kubectl create namespace flux
ssh-keygen -t rsa -N '' -f ./flux/id_rsa -C flux <<< y
kubectl create secret generic flux-ssh --from-file=identity=./id_rsa -n flux

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
