# Tenant networking

This repo is a test implementation of the GSA DevSecOps tenant networking model. The model is intended to be used across 4 different AWS accounts. However, while that is being worked out, this repo deploys into 1 AWS account but across 3 different regions.

The repo deploys 2 VPCs: management, and an environment. Each VPC is in the same region because of a peering issue between us-west-1 and us-east-2. It will deploy the necessary VPN gateways and peering connections. The environment VPC will be peered with the Management VPC. Both VPCs will be set up with a VPN connection to the shared transit VPC. Note that today, that shared transit VPC does not exist. Therefore, the IP addresses specified in variables.tf are dummy values. If you have a VPN server that can accept the connections, please create a `variables.tfvars` file and set the variables for the VPN servers you wish to connect to this environment.

The Cloud Formation template for the AWS Web Application Firewall (WAF) was
downloaded from [https://s3.amazonaws.com/solutions-reference/aws-waf-security-automations/latest/aws-waf-security-automations-alb.template](https://s3.amazonaws.com/solutions-reference/aws-waf-security-automations/latest/aws-waf-security-automations-alb.template).
Impletation guide for the AWS WAF Security Automations is available at [https://docs.aws.amazon.com/solutions/latest/aws-waf-security-automations](https://docs.aws.amazon.com/solutions/latest/aws-waf-security-automations).

The repo is deployable out of the box with the proper AWS programmatic credentials and a recent (0.11.3 as of this writing) version of [Terraform](https://www.terraform.io).

To deploy, check out a copy of the repo using your favorite git client. Then:

```sh
cd terraform/networking
terraform init
terraform plan
terraform apply
```

Notes:

* The VPN connections take a long time to be set up (6+ minutes).
* This repo does not set up a remote backend. If you wish to use a remote backend, you'll need to add the Terraform code to do so.
