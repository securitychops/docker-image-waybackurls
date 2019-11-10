#!/bin/bash

mkdir -p ~/.aws/
echo "[default]" >> ~/.aws/credentials
echo "aws_access_key_id = $S3_BUCKET_KEY" >> ~/.aws/credentials
echo "aws_secret_access_key = $S3_BUCKET_SECRET" >> ~/.aws/credentials

UUID=$(cat /proc/sys/kernel/random/uuid)

aws s3 cp s3://$S3_BUCKET_NAME/tmp/$DOMAINS_FILE /tmp/scanme

waybackurls $SCAN_ME > /tmp/wayback.txt

if [ -r /tmp/wayback.txt ]
then
    if [ -s /tmp/wayback.txt ]
    then
       cat /tmp/wayback.txt >> /tmp/scanme
    fi
fi

aws s3 mv /tmp/scanme s3://$S3_BUCKET_NAME/tmp/$UUID
echo '{"task_type":"'$NEXT_STEP'","tld":"'$SCAN_ME'","domains_file":"'$UUID'","port_size":"'$PORT_SIZE'"}' > /tmp/$UUID
aws s3 mv /tmp/$UUID s3://$S3_BUCKET_NAME/tasks/
