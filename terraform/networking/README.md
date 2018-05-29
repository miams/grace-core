# Tenant networking

This repo is a test implementation of the GSA DevSecOps tenant networking model. The model is intended to be used across different AWS accounts. However, while that is being worked out, this repo deploys into 1 AWS account but across different regions.

The repo deploys 2 VPCs: management, and an environment, with the necessary gateways. Both VPCs will be set up with a VPN connection to the shared transit VPC.

The Cloud Formation template for the AWS Web Application Firewall (WAF) was
downloaded from [here](https://s3.amazonaws.com/solutions-reference/aws-waf-security-automations/latest/aws-waf-security-automations-alb.template).
Impletation guide for the AWS WAF Security Automations is available [here](https://docs.aws.amazon.com/solutions/latest/aws-waf-security-automations).

The repo is deployable out of the box with the proper AWS programmatic credentials and a recent (0.11.3 as of this writing) version of [Terraform](https://www.terraform.io).

You will need to set the following variables:

```
env_account_id
mgmt_account_id
gsa_internal_cidr_block
```

You will also have to provide server certificates for the ALB listeners and set
certificate names and path to the certificate and key files in the appropriate
variables:

```
mgmt_alb_cert_name
mgmt_alb_cert_file
mgmt_alb_key_file
env_alb_cert_name
env_alb_cert_file
env_alb_key_file
```

To deploy, check out a copy of the repo using your favorite git client. Set the
above variables in a `terraform\networking\terraform.tfvars` file.  Then:

```sh
cd terraform/networking
terraform init
terraform plan
terraform apply
```

Notes:

* The VPN connections take a long time to be set up (6+ minutes).
* This repo does not set up a remote backend. If you wish to use a remote backend, you'll need to add the Terraform code to do so.
