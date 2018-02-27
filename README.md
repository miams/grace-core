# devsecops-tenant-networking

This repo is a test implementation of the GSA DevSecOps tenant networking model. The model is intended to be used across 4 different AWS accounts. However, while that is being worked out, this repo deploys into 1 AWS account but across 3 different regions.

The repo deploys 4 VPCs: management, production, development and staging. Each VPC is in a different region (actually, two of them are in the same region because of a peering issue between us-west-1 and us-east-2). It will deploy the necessary VPN gateways and peering connections. Each VPC will be peered with the Management VPC. Each VPC (including management) will be set up with a VPN connection to the shared transit VPC. Note that today, that shared transit VPC does not exist. Therefore, the IP addresses specified in variables.tf are dummy values. If you have a VPN server that can accept the connections, please create a "variables.tfvars" file and set the variables for the VPN servers you wish to connect to this environment.

The repo is deployable out of the box with the proper AWS programmatic credentials and a recent (0.11.3 as of this writing) version of [Terraform.](https://www.terraform.io)

To deploy, check out a copy of the repo using your favorite git client. Then:

```sh
cd terraform
terraform init
terraform plan
terraform apply
```

Note that this repo does not set up a remote backend. If you wish to use a remote backend, you'll need to add the Terraform code to do so.

## Organizations

[A script](apply.py) is included for managing AWS accounts across an [AWS Organization](https://aws.amazon.com/organizations/).

1. Install Python 3.
1. [Set up AWS access key for the master account.](https://boto3.readthedocs.io/en/latest/guide/configuration.html)
1. Run the script.

    ```sh
    python3 apply.py
    ```

The code loops through all non-master member in the Organization and `apply`s the Terraform configuration to each (after assuming the corresponding role). The separate states are kept in Terraform [workspaces](https://www.terraform.io/docs/state/workspaces.html) corresponding to each account. It treats each account independently; if one account fails to update for some reason, it logs that, but then continues on to the next one.

Example output:

```
$ python3 apply.py
Running for account 11111.
Workspace '11111' exists.
+ terraform workspace select 11111
Switched to workspace "11111".
+ terraform apply -input=false -auto-approve
data.aws_caller_identity.current: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

account_id = 11111
caller_arn = arn:aws:sts::11111:assumed-role/OrganizationAccountAccessRole/22222
caller_user = SOMEUSER:22222

Successfully set up networking for account 11111.
---------
Running for account 33333.
Workspace '33333' exists.
+ terraform workspace select 33333
Switched to workspace "33333".
+ terraform apply -input=false -auto-approve
data.aws_caller_identity.current: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

account_id = 33333
caller_arn = arn:aws:sts::33333:assumed-role/OrganizationAccountAccessRole/44444
caller_user = OTHERUSER:44444

Successfully set up networking for account 33333.
---------
Networking set up for all accounts successfully.
```
