# Testing zero-downtime deploy

## Pre-requisites
* Bash
* Terraform 0.11.11
* AWS CLI (configured with credentials)
* RSA Key Pair

## Usage
`./deploy.sh [plan|apply|destroy] [AMI_ID] [KEY_PAIR_FILE]`

When using the plan (default), or apply actions, you will be required 
to specify an AMI ID. The key pair file is optional as it assumes there 
will be a `key.pub` file in the root of this repo, but you can override 
it. The parameters are specified in order, so make sure to specify any 
previous optional parameters.

This configuration assumes two things. The AMI will be an Amazon Linux 
image since it uses `user_data` to configure docker on the instance and 
pull an nginx container. Also, it has health checks configured against 
port 80 in order to validate the health of the instances.


## Summary
This will deploy an entire VPC with public and private subnets, as well 
NAT instances. It will configure an application load balancer with a 
target group and autoscaling group. At the end of the deploy, it will 
output the DNS entry for the application load balancer which should 
return the nginx test page.