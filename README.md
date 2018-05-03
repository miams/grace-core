# GRACE platform configuration

This repository contains the core configuration for the [GRACE](https://github.com/gsa/devsecops#readme) platform. Terraform is used to configure resources across the AWS master and member accounts in the Organization - see [`terraform/master/`](terraform/master).

Note that the patterns in this repository are usable in other contexts, but this code can't be used directly elsewhere without tweaks, due to things like AWS account emails needing to be unique.

## Usage

[Configure AWS](https://www.terraform.io/docs/providers/aws/#authentication) with credentials for the master AWS account, then run:

```sh
cd terraform/master
terraform init
terraform apply
```

---

See the [networking module](terraform/networking) module for a cross-VPC/account networking example.
