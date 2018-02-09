# devsecops-tenant-networking

This repo is a test implementation of the GSA DevSecOps tenant networking model. The model is intended to be used across 4 different AWS accounts. However, while that is being worked out, this repo deploys into 1 AWS account but across 3 different regions.

The repo deploys 4 VPCs: management, production, development and staging. Each VPC is in a different region (actually, two of them are in the same region because of a peering issue between us-west-1 and us-east-2). It will deploy the necessary VPN gateways and peering connections. Each VPC will be peered with the Management VPC. Each VPC (including management) will be set up with a VPN connection to the shared transit VPC. Note that today, that shared transit VPC does not exist. Therefore, the IP addresses specified in variables.tf are dummy values. If you have a VPN server that can accept the connections, please create a "variables.tfvars" file and set the variables for the VPN servers you wish to connect to this environment.

The repo is deployable out of the box with the proper AWS programmatic credentials and a recent (0.11.3 as of this writing) version of [Terraform.](https://www.terraform.io)

To deploy, check out a copy of the repo using your favorite git client. Then:

````sh
  cd terraform
  terraform init
  terraform plan
  terraform apply
````

Note that this repo does not set up a remote backend. If you wish to use a remote backend, you'll need to add the Terraform code itself.