# GRACE platform configuration [![CircleCI](https://circleci.com/gh/GSA/grace-core.svg?style=svg)](https://circleci.com/gh/GSA/grace-core)

This repository contains the core configuration for the [GRACE](https://github.com/gsa/devsecops#readme) platform. Terraform is used to configure resources across the AWS master and member accounts in the Organization - see [`terraform/master/`](terraform/master).

Note that the patterns in this repository are usable in other contexts, but this code can't be used directly elsewhere without tweaks, due to things like AWS account emails needing to be unique.

## Initial setup

Having been done once for the account, the following steps shouldn't need to be done again. Documenting here for reference.

1. [Configure AWS](https://www.terraform.io/docs/providers/aws/#authentication) with credentials for the master AWS account locally.
1. Bootstrap the account.

    ```sh
    make bootstrap
    ```

1. [Create an access key for `circle-deployer`.](https://console.aws.amazon.com/iam/home#/users/circle-deployer?section=security_credentials)
1. [Save those credentials in CircleCI](https://circleci.com/gh/GSA/grace-core/edit#env-vars) using [AWS environment variables](https://www.terraform.io/docs/providers/aws/#environment-variables).

CircleCI will deploy changes to the environment going forward.

---

See the [networking module](terraform/networking) module for a cross-VPC/account networking example.
