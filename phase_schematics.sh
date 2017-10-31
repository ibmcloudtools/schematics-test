#!/bin/bash
set -x
bx plugin install schematics
bx api https://api.ng.bluemix.net
bx login --apikey $BLUEMIX_API_KEY -c $BLUEMIX_ACCOUNT_ID
bx target -o $BLUEMIX_ORG -s $BLUEMIX_SPACE
bx schematics environment show -id $SCHEMATICS_ENV_ID

COUNTER=0
echo Running IBM Schematics, will wait for up to 20 minutes
act_id=$(bx schematics action apply --id $SCHEMATICS_ENV_ID --force | grep activity | awk '{print $2}')
if [ "${#act_id}" -ne 32 ]; then
    echo Invalid activity_id
    exit 1
fi
echo IBM Schemativcs activity_id $act_id

# 120 intervals of 10 seconds == 20 minutes
while [ $COUNTER -lt 120 ]; do
    act_status=$(bx schematics activity show --id $act_id | grep Status | awk '{print $2}')
    echo IBM Schematics activity_status $act_status
    if [ "$act_status" == "INPROGRESS" ] || [ "$act_status" == "CREATED" ]; then
        echo Activity is still in progress.... Waiting....
        let COUNTER=COUNTER+1 
        sleep 10
    elif [ "$act_status" == "COMPLETED" ]; then
        echo Activity successfully completed 
        let COUNTER=999
    else 
        echo Unknown activity status, see below for more details
        bx schematics activity show --id $act_id
        exit -1
    fi
done

# Save VSI IP address to a text file
bx schematics activity log --id $act_id | grep vm_instance_ipv4_address | grep "Terraform show" | awk '{print $8}' | head -1 > vsi_ip.txt

# Save private key to a text file
echo -----BEGIN RSA PRIVATE KEY----- >> ssh_private_key
bx schematics activity log --id $act_id | grep "Terraform apply" | grep MIIE -A 24 | awk -F'|' '{print $2}' | awk '{print $1}' >> ssh_private_key
echo -----END RSA PRIVATE KEY----- >> ssh_private_key
chmod 600 ssh_private_key
cat ssh_private_key

