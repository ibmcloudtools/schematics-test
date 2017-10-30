#!/bin/bash
set -x
ls -la
HOST_ADDRESS=$(cat vsi_ip.txt)
mkdir -p ~/.ssh
echo $SSH_PRIVATE_KEY >> ~/.ssh/ssh_private_key_tmp
echo -----BEGIN RSA PRIVATE KEY----- >> ~/.ssh/ssh_private_key
sed 's/\s\+/\n/g' ~/.ssh/ssh_private_key_tmp >> ~/.ssh/ssh_private_key
echo -----END RSA PRIVATE KEY----- >> ~/.ssh/ssh_private_key
cat ~/.ssh/ssh_private_key
chmod 600 ~/.ssh/ssh_private_key
touch ~/.ssh/known_hosts
ssh-keygen -f ~/.ssh/known_hosts -R $HOST_ADDRESS
ssh-keyscan $HOST_ADDRESS >> ~/.ssh/known_hosts 
ssh -i ~/.ssh/ssh_private_key root@$HOST_ADDRESS mkdir -p app
rsync -arv -e "ssh -i $HOME/.ssh/ssh_private_key" . root@$HOST_ADDRESS:app
ssh -i ~/.ssh/ssh_private_key root@$HOST_ADDRESS "pkill node; cd app; npm install; nohup npm start > /dev/null 2>&1 &"