A simple script to find certificates in AWS CloudTrail that have been used with IAM Roles Anywhere, in the last day. Search is by _serial_, which you should receive in any AWS warnings about expiring certificates.

## AWS Settings
Ensure that the values for **AWS CLI Settings** are correct for your configuration.
- **AWS_PROFILE** *(Default)*: `default`
- **AWS_REGION** *(Default)*:`ap-southeast-2`


## Prerequisites
The script requires both `aws-cli` and `jq` to be present. You may need to update the default paths in the script if it can't find either of these.

- **AWS_PATH** *(Default)*: `/usr/local/bin/aws`
- **JQ_PATH** *(Default)*: `/opt/local/bin/jq`

## All CNs Returned
Note that if multiple certificates have the same serial and have been used with IAM Roles Anywhere in the last day, then you will see multiple CN values returned. So long as these certificates have not been issued by a common issuer, this is not an error. 