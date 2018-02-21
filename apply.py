import boto3
import os
import subprocess
import sys


MODULE = 'terraform'
# https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html#orgs_manage_accounts_access-cross-account-role
ROLE_NAME = 'OrganizationAccountAccessRole'


def get_current_account_id():
    client = boto3.client('sts')
    identity = client.get_caller_identity()
    return identity.get('Account')

def get_tenant_accounts():
    client = boto3.client('organizations')
    paginator = client.get_paginator('list_accounts')
    page_iterator = paginator.paginate()

    master_account_id = get_current_account_id()

    for page in page_iterator:
        for account in page['Accounts']:
            # skip the master account, which is the one we're calling from
            if account['Id'] == master_account_id:
                continue
            yield account

def run_terraform(args, check=True, capture_output=False, env=None):
    return subprocess.run(
        args,
        check=check,
        cwd=MODULE,
        env=env,
        # print in real time
        stdout=(subprocess.PIPE if capture_output else sys.stdout),
        stderr=(subprocess.STDOUT if capture_output else sys.stderr)
    )

def is_existing_workspace(name):
    result = run_terraform(['terraform', 'workspace', 'list'], capture_output=True)
    return name in result.stdout.decode('utf-8')

def use_workspace(name):
    if is_existing_workspace(name):
        print("Workspace '{}' exists.".format(name))
        subcommand = 'select'
    else:
        subcommand = 'new'

    run_terraform(['terraform', 'workspace', subcommand, name])

def set_up_networking(role_arn):
    my_env = os.environ.copy()
    my_env['AWS_DEFAULT_REGION'] = 'us-east-1'
    my_env['TF_VAR_role_arn'] = role_arn

    return run_terraform(['terraform', 'apply', '-input=false', '-auto-approve'], check=False, env=my_env)


accounts = get_tenant_accounts()
failed = False
for account in accounts:
    account_id = account['Id']
    print("---------\nRunning for account {}:\n".format(account_id))

    # manage each subaccount in its own Terraform workspace, so the states are independent
    use_workspace(account_id)

    # generate AssumeRole ARN
    role_arn = "arn:aws:iam::{}:role/{}".format(account_id, ROLE_NAME)

    result = set_up_networking(role_arn)
    if result.returncode != 0:
        failed = True

# fail if any failed
if failed:
    sys.exit(1)
