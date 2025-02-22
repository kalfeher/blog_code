## Important
The Containerfile and instructions here will build a container for a graviton Lambda instance. If you wish to build for an Intel instance, you will need to update the `podman build` command and use the Intel URL for the **awscli** package in the `Containerfile`.

## Required packages
* `jq` for basic _Lambda_ functions
* `unzip` for _aws-cli_ unpacking. Not strictly required if unpacked elsewhere.
* `openssl` for certificate checking

## Build container
```bash
CONTAINER="cert-expiry-checker"
REGION="nn-moonbase-1"
REPO="1234567890.dkr.ecr.${REGION}.amazonaws.com"
cd cert-expiry-checker
podman build -t ${CONTAINER} --platform linux/arm64 .
```

## AWS upload
```bash
aws ecr get-login-password --region ${REGION} | \
podman login --username AWS --password-stdin ${REPO}
```

```bash
podman tag ${CONTAINER}:latest ${REPO}/${CONTAINER}:latest
podman push ${REPO}/${CONTAINER}:latest
```