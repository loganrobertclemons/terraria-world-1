#! /bin/bash
read -p 'Repo: ' REPO
read -p 'Username: ' USERNAME
read -sp 'Password: ' PASSWORD
curl \
  -X POST \
  -u $USERNAME:$PASSWORD \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$USERNAME/$REPO/keys \
  -d '{"key":"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDp5fg1ZznsmGKOMzIYOMTnX2EIqjQay9n2R9Ps1gCfEPyax8x9YN8UjQV9ALSgEtHN4YdcuPSrIbdNbWFk3FUNDwgHsfk7/k1AD7dliwgPQDJVOUjFRXq1dpuDPoZl4X0bhrvWA0AAVENF0nuKFFkPpPUK/yRTtUfffcfaFLF6PwFTc0CvACS+dS7f1fWMHLARCqOHBizFtXOkdZfA1tSXsFFUs41Quf6ROVJScDcUIerA7DETZoA5+0cEQw0LrhXq/b9pCUUjEfC+TrzB8xOMx/d+/XtEH2R0aEtDMayK+lZWfe4vRbhKhk2pw23NheRB9YHR5ywYw9YRPtAXCDNv flux","title":"flux-ssh"}'
