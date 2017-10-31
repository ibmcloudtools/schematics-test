#!/bin/bash
set -x
HOST_ADDRESS=$(cat vsi_ip.txt)
touch ~/.ssh/known_hosts
ssh-keygen -f ~/.ssh/known_hosts -R $HOST_ADDRESS
ssh-keyscan $HOST_ADDRESS >> ~/.ssh/known_hosts 
ssh -i ssh_private_key root@$HOST_ADDRESS mkdir -p app
rsync -arv -e "ssh -i ssh_private_key" . root@$HOST_ADDRESS:app
ssh -i ssh_private_key root@$HOST_ADDRESS "pkill node; cd app; npm install; nohup npm start > /dev/null 2>&1 &"