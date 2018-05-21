# Initial setup

Having been done once for the current master account, the following steps shouldn't need to be done again. Documenting here for reference.

1. Install the dependencies.
    * [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
    * [Terraform](https://www.terraform.io/)
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

1. Create a Parameter Store parameter for the master account budget.

    ```sh
    aws ssm put-parameter --type String --name master-budget --value <budget>
    ```

CircleCI will deploy changes to the environment going forward.