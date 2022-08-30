# Notes for setting up a root and intermediate
## Where to find the files
All relevant files will be copied to `/etc/certificates` with the following subdirectories:
- `root`
- `issuer`
- `certficates`

## Generate root cert
```bash
cfssl gencert -initca /etc/certificates/root/root-csr.json \
| cfssljson -bare /etc/certificates/root/root-ca
```
## Generate issuer cert
```bash
cfssl genkey /etc/certificates/issuer/issuer-csr.json \
| cfssljson -bare /etc/certificates/issuer/issuer-ca
```
## Sign the issuer
```bash
cfssl sign -ca /etc/certificates/root/root-ca.pem \
  -ca-key /etc/certificates/root/root-ca-key.pem \
  -config /etc/certificates/conf/config.json \
  -profile aws_issuer \
  /etc/certificates/issuer/issuer-ca.csr \
| cfssljson -bare /etc/certificates/issuer/issuer-ca
```
## Securing the private keys
The root key `root-ca-key.pem` should be copied off the server and then deleted. Copy it back only when an intermediate needs to be refreshed or a new one created.
## Sign a host cert
Ensure that the relevant json file is under the `/etc/certificates/certificates` directory.
```bash
cfssl gencert \
  -ca /etc/certificates/issuer/issuer-ca.pem \
  -ca-key /etc/certificates/issuer/issuer-ca-key.pem \
  -config /etc/certificates/conf/config.json \
  -profile host \
  /etc/certificates/certificates/sample-host.json \
| cfssljson -bare /etc/certificates/certificates/sample-host
``` 
## Creat a bundle for usage with webservers
```bash
cfssl bundle -ca-bundle /etc/certificates/root/root-ca.pem \
  -int-bundle /etc/certificates/issuer/issuer-ca.pem \
  -cert /etc/certificates/certificates/sample-host.pem \
| cfssljson -bare /etc/certificates/certificates/sample-host-fullchain
```
## Read cert with openssl
```bash
openssl x509 -in /etc/certificates/certificates/sample-host-fullchain-bundle.pem -text -noout
```