Scripts and resources from the blog post [Checking Certificates For Expiry](https://kalfeher.com/expiry-checker).

## Script: cert-exp-check.sh
This script is intended as a primer for someone who will build their own solution. It currently outputs the results of the certificate validation step in a parsing friendly format.
### Requirements
1. You will need to schedule and log the results of the script somewhere. 
2. Ensure that the host on which the script executes has reachability to all monitored hosts.
3. An additional process will be required to detect warnings from the log destination and to generate a notice (email, dashboard update, chat client alert etc..)
## Lambda
For detailed instructions on building the container refer to the file `lambda/container/cert-expiry-checker.md`.

### Requirements
1. AWS account. You can probably adapt this to another cloud provider with container execution options, with only minor effort. 
2. SNS topic and subscribers to receive renewal warning notices.
3. You'll need an account/role that can create and manage Lambda functions and ECR private repos

### Container Architecture
Ensure that you read the build instructions and follow the advice regarding the processor architecture of your Lambda function. Since Graviton is cheaper and for this script network latency is a larger factor than chip performance in terms of total execution time, `arm64` is the default.

### IAM Policy
In order to allow the Lambda function to publish to an SNS topic for notification, the policy within `LambdaSNSPublishPolicy.json` will need to be added to its execution role.

## HTTPS Records
The post refers to `openssl s_client` not supporting HTTPS(SVCB) records. This will impact:
  1. Any Alias mode record endpoint
  2. Any Service mode record with a target that isn't `.`  
It is recommended that you resolve the endpoint first, then provide that endpoint address to the certificate validation check function. Bear in mind that the `-servername` must be the original domain, otherwise the wrong certificate may be returned. 

For Service mode records, if there is more than one endpoint, you will need to resolve them all and check them all if they each have different certificates. Since this is not an availability check, if all endpoints have the same certificate, then checking a single endpoint may be adequate. You will need to monitor consistency between endpoints separately.

Alias mode records should only have a single endpoint.

The following is a truncated example showing the steps to resolve the HTTPS endpoint for an Alias mode record and the adjusted `openssl` command:
```Bash
DOMAIN="httpsdomain.example"
ENDPOINT=$(dig https ${DOMAIN} +short | cut -d" " -f2)
# use $ENDPOINT for the -connect param, but keep $WEBSITE as the -servername param.
WILLEXP=$(openssl s_client -servername ${WEBSITE} -connect ${ENDPOINT}:443 </dev/null 2> /dev/null| openssl x509 -checkend ${EXP} -noout)
```
