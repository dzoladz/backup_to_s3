#!/bin/sh
PATH=/usr/bin:/usr/local/bin:/bin:/usr/local/bin/aws

#############
# BACKUP FILES to an AWS s3 Bucket
#
# Notes:
#   1. s3 bucket retention cycles can be set in AWS s3 console
#   2. Template script: assumes Linux user named s3user with AWS CLI credentials and AWS IAM permissions to manage s3
#      Replace with specific paths/files/s3 bucket/email address
#
#############

# Make temporary directory for script process /tmp
mkdir /home/s3user/tmp


##
## REPEATABLE BLOCK: add additional directories to prep for the s3 bucket
# Compress directory, add date to compressed file, and place in /tmp. Wait one minute to complete process before moving on.
tar -zcvf /home/s3user/tmp/somedata$(date +"%Y%m%d").tar.gz /path/to/directory
sleep 60

# Send somedata to an s3 bucket named somebucket, report status to user@domain.org
aws s3 cp /home/s3user/tmp/somedata$(date +"%Y%m%d").tar.gz s3://somebucket/

somedata_return=$(echo $?)

if [ $somedata_return = "0" ]; then
        echo "Success: Backup to s3 on $(date)" | mail -s "Success: somedata backup" user@domain.org
else
        echo "Failed: Backup to s3 on $(date). AWS CLI return or exit code value: $somedata_return. Manual backup required." | mail -s "Failed somedata backup" user@domain.org
fi

sleep 10
## END BLOCK
##


# Wait, then remove temporary directory
sleep 5
rm -R /home/s3user/tmp
