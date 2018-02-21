import boto3
import subprocess
import sys


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

def set_up_networking(role_arn):
    return subprocess.run(
        ['terraform', 'apply', '-var', "role_arn={}".format(role_arn)],
        cwd='terraform',
        stderr=subprocess.STDOUT,
        stdout=subprocess.PIPE
    )


accounts = get_tenant_accounts()
failed = False
for account in accounts:
    account_id = account['Id']
    # generate AssumeRole ARN
    role_arn = "arn:aws:iam::{}:role/{}".format(account_id, ROLE_NAME)
    result = set_up_networking(role_arn)
    if result.returncode is not 0:
        print("---------\nError for account {}:\n".format(account_id), result.stdout.decode('utf-8'), file=sys.stderr)
        failed = True

# fail if any failed
if failed:
    sys.exit(1)
