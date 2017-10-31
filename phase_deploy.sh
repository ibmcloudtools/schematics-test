#!/bin/bash
set -x
VSI_HOSTS=$(cat vsi_ip.txt)
for VSI_HOST in $VSI_HOSTS
do
    echo $VSI_HOST
    touch ~/.ssh/known_hosts
    ssh-keygen -f ~/.ssh/known_hosts -R $VSI_HOST
    ssh-keyscan $VSI_HOST >> ~/.ssh/known_hosts 
    ssh -i ssh_private_key root@$VSI_HOST mkdir -p app
    rsync -arv -e "ssh -i ssh_private_key" . root@$VSI_HOST:app
    ssh -i ssh_private_key root@$VSI_HOST "pkill node; cd app; npm install; nohup npm start > /dev/null 2>&1 &"
done
