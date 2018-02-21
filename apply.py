import boto3
import subprocess
import sys


# https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html#orgs_manage_accounts_access-cross-account-role
ROLE_NAME = 'OrganizationAccountAccessRole'


def get_tenant_accounts():
    client = boto3.client('organizations')
    paginator = client.get_paginator('list_accounts')
    page_iterator = paginator.paginate()
    # TODO filter out non-tenant accounts
    for page in page_iterator:
        for account in page['Accounts']:
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
