# GRACE platform configuration [![CircleCI](https://circleci.com/gh/GSA/grace-core.svg?style=svg)](https://circleci.com/gh/GSA/grace-core)

This repository contains the core Terraform configuration for the [GRACE](https://github.com/gsa/devsecops#readme) platform. This includes:

* Setting up an S3 bucket for storing sensitive configuration files (outside this repository)
* Creating an IAM user and permissions for continuous deployment of this code
* Configuring the master account as an Organization
* Setting up the [Service Control Policy](https://github.com/GSA/security-benchmarks/tree/master/scp) for tenants
* Creating member accounts

Note that the patterns in this repository are usable in other contexts, but this code can't be used directly elsewhere without tweaks, due to things like AWS account emails needing to be unique.

Also included: [an example of cross-VPC/account networking](terraform/networking).

## Initial setup

Having been done once for the account, the following steps shouldn't need to be done again. Documenting here for reference.

1. [Configure AWS](https://www.terraform.io/docs/providers/aws/#authentication) with credentials for the master AWS account locally.
1. Bootstrap the account.

    ```sh
    make bootstrap
    ```

1. [Create an access key for `circle-deployer`.](https://console.aws.amazon.com/iam/home#/users/circle-deployer?section=security_credentials)
1. [Save those credentials in CircleCI](https://circleci.com/gh/GSA/grace-core/edit#env-vars) using [AWS environment variables](https://www.terraform.io/docs/providers/aws/#environment-variables).
1. [Generate the Service Control Policy](https://github.com/GSA/security-benchmarks/tree/master/scp) and save to a file.
1. Copy the policy to S3.

    ```sh
    aws s3 cp <path/to/scp.json> s3://grace-config/service_control_policy.json
    ```

CircleCI will deploy changes to the environment going forward.

## Adding a member account

For new tenants, or tenants that want an additional AWS account, create one or more new AWS accounts by:

1. **Tenant or DevSecOps team:** Add one or more new `member_account` module blocks to [`terraform/master/members.tf`](terraform/master/members.tf)
    * You can see other existing accounts in that file to copy from.
    * The `name` and `email` should be unique.
    * For the `email`, use the tenant team's Google Group with a suffix: `<tenantgroup>+<env>@gsa.gov`. For example, `myteam+staging@gsa.gov`.
1. **Tenant or DevSecOps team:** Submit the change as a pull request
1. **DevSecOps team:** Merge the pull request
1. **DevSecOps team:** Move the new account to the Tenants Organizational Unit
    * This needs to be done manually, while waiting for [Terraform support](https://github.com/terraform-providers/terraform-provider-aws/pull/4405)
    * Easiest to do so through [the Console](https://console.aws.amazon.com/organizations/home)
