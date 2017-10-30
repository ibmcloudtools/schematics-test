#!/bin/bash
COUNTER=0
echo Running IBM Schematics, will wait for up to 20 minutes
act_id=$(bx schematics action apply --id cdfd7f399fec324bd8142107f136c4cf --force | grep activity | awk '{print $2}')
if [ "${#act_id}" -ne 32 ]; then
    echo Invalid activity_id
    exit 1
fi
echo IBM Schemativcs activity_id $act_id

while [ $COUNTER -lt 20 ]; do
    act_status=$(bx schematics activity show --id $act_id | grep Status | awk '{print $2}')
    echo IBM Schematics activity_status $act_status
    if [ "$act_status" == "INPROGRESS" ] || [ "$act_status" == "CREATED" ]; then
        echo Activity is still in progress.... Waiting....
        let COUNTER=COUNTER+1 
        sleep 5
    else 
        echo BOOM!
    fi
    
done