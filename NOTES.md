#STEPS TO RUN

IRELAND: To run the terraform use the following command:

```bash
terraform apply -var-file=dublin.tfvars
```

USA: To run the terraform use the following command:

```bash
terraform apply -var-file=virginia.tfvars
```
---
1. To Improve web server resilience the configuration was changed to allow autoscale groups

2. Region USA - Virginia file was created to allow similar interface in a different region

3. Configured Bastion server to a private subnet
 - Verify connection creating a tunel, ports 22,80: 
 ```bash
 ssh -i KEY ec2-user@PUBLIC_IP_BASTION -L 9999:PRIVATE_IP_WEB:22 -L 9998:PRIVATE_IP_WEB:80
 ```
 - Verify localhost:9998 displays the web NGIX Page

4. Updated script to change nginx to reverse proxy and install all java requirements
   Verify creating tunel: port 80 and send a curl in a new terminal
```bash
 ssh -i KEY ec2-user@PUBLIC_IP_BASTION -L 9999:PRIVATE_IP_WEB:80
```
curl in new terminal to display Hello World
```bash
 curl 127.0.0.1:80
```

