Example `Containerfile` and `function.sh` script for an AWS lambda function using `Bash`. Read below for details on customising this for your needs.

## Containerfile
### 1. Get the image
I'm pulling the image from AWS's public registry. Change this if you have a local repo.

For this example, I'm using the AWS bootstrap code with no changes.
```
# 1.
# First we get the base image
FROM public.ecr.aws/lambda/provided:latest

# Copy bootstrap
WORKDIR /var/runtime/
COPY bootstrap bootstrap
RUN chmod 755 bootstrap
```

### 2. Copy your code
The example file uses only a single `function.sh` file. Add any additional scripts in this section.
```
# 2.
# Copy function script. Must be executable
WORKDIR /var/task/
COPY function.sh function.sh
RUN chmod 755 function.sh
```
### 3. Add the tools you need.
The baseline amazonlinux container comes without some very common tools. `jq` is a notable absence and any function dealing with files will probably need `gzip` or `unzip` at the very least. Add any tools which can be installed via dnf in this section.
```
# 3.
# Install any tools you need via dnf
RUN dnf --nodocs install -y gzip unzip jq
```

### 4. Add the AWS cli.
If you don't need the `aws-cli` then remove this section, it will save you a _lot_ of room (AWS ECR charges you for image storage, so smaller is better). The example file has the url for the x86_64 architecture executable. Change this url if you plan on deploying the container on a graviton based instance. There are currently no space optimising install options. If they do become available, add them to the install command line.
```
# 4.
# Download and install AWS CLI
WORKDIR /tmp
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip && \
unzip -u awscliv2.zip
# install
RUN ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli
# clean up
RUN rm -rf /tmp/aws && rm -f /tmp/awscliv2.zip
```

### 5. The handler
You can change the handler name if you wish. Bear in mind that you'll need to ensure that your file is copied to the correct name in [step 2](#2-copy-your-code). Most people will not need to make any changes here.
```
# 5.
# Set the handler
# by convention <fileName>.<handlerName>
WORKDIR /var/task
ENTRYPOINT ["/lambda-entrypoint.sh"]
CMD [ "function.handler" ]
```
## Build the container
All examples use `podman`, but you can can use `docker` with all steps if you have that installed. Note the `arch` option. If you're building for Graviton instances, use `arch=arm64`.
```Bash
FUNCNAME=funcwmyhart
podman build --arch=amd64 -t ${FUNCNAME} -f /pathto/Containerfile
```
## Upload to AWS
Replace the command below with your region and your account. The command below will use your `~/.aws/config` or `~/.aws/credentials` files for authentication. DO NOT PUT ANY CREDENTIALS INTO A SCRIPT! The most convenient method of authentication will be _IAMRolesAnywhere_ when not building within AWS or using an instance role when building within AWS. 
```bash
MYACCOUNT=1234567890
MYREGION="nn-moonbase-1"
aws ecr get-login-password --region ${MYREGION} | \
podman login --username AWS --password-stdin ${MYACCOUNT}.dkr.ecr.${MYREGION}.amazonaws.com
```
We need to tag the container
```bash
podman tag ${FUNCNAME}:latest \
${MYACCOUNT}.dkr.ecr.${MYREGION}.amazonaws.com/${FUNCNAME}:latest
```
Then we upload. This may take a few minutes depending on upload bandwidth and if you're really using moonbase-1, grab a large coffee while you wait.
```bash
podman push \
${MYACCOUNT}.dkr.ecr.${MYREGION}.amazonaws.com/${FUNCNAME}:latest
```
## Run the lambda
The example function should be triggered by an S3 put event. The source bucket doesnt matter. Make sure the lambda function has permissions to fetch the object.