import boto3
import subprocess
import sys


ROLE_NAME = "TODO"


def get_tenant_accounts():
    client = boto3.client('organizations')
    paginator = client.get_paginator('list_accounts')
    accounts = paginator.paginate()['Accounts']
    # TODO filter out non-tenant accounts
    return accounts

def set_up_networking(role_arn):
    return subprocess.run(
        ['terraform', 'apply', '-var', "role_arn={}".format(role_arn)],
        cwd='terraform',
        stderr=subprocess.PIPE,
        stdout=subprocess.PIPE
    )


accounts = get_tenant_accounts()
failed = False
for account in accounts:
    # generate AssumeRole ARN
    role_arn = "arn:aws:iam::{}:role/{}".format(account['Id'], ROLE_NAME)
    result = set_up_networking(role_arn)
    if result.returncode not 0:
        # TODO print error
        failed = True

# fail if any failed
if failed:
    sys.exit(1)
