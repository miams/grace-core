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
1. [Set environment variables in CircleCI.](https://circleci.com/gh/GSA/grace-core/edit#env-vars)
    * [AWS credentials](https://www.terraform.io/docs/providers/aws/#environment-variables)
    * [Other required variables](terraform/master/veriables.tf)
1. [Generate the Service Control Policy](https://github.com/GSA/security-benchmarks/tree/master/scp) and save to a file.
1. Copy the policy to S3.

    ```sh
    aws s3 cp <path/to/scp.json> s3://grace-config/service_control_policy.json
    ```

1. Create a Parameter Store parameter for the master account budget.

    ```sh
    aws ssm put-parameter --type String --name master-budget --value <budget>
    ```

1. Run a build on the `master` branch of CircleCI.
1. Connect the Cisco CSR to the GSA network.
    1. Coordinate with Network Operations (NetOps) team to connect Verizon SCI (AWS virtual interface) to the VGW. NetOps will need AWS account number and VGW ID to create a ticket with Verizon, so they can create the SCI connection.
    1. Verizon creates the SCI. A VNI will appear attached to the VGW in the Transit VPC account.
    1. Follow [detached VGW connection steps](https://docs.aws.amazon.com/solutions/latest/cisco-based-transit-vpc/appendix-d.html).

CircleCI will deploy changes to the environment going forward.
