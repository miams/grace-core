import sys
import os.path
import boto3

def lambda_handler(event, context):
    """Set up boto3 sessions"""
    MASTER_PAYER_S3 = boto3.client('s3')
    MASTER_PAYER_ORG = boto3.client('organizations')
    TENANT_BUCKET = "grace-tenant-info"
    TENANT_KEY = "tenant-info"
    TENANTS_FILE = "tenants.txt"

    organizations_response = MASTER_PAYER_ORG.list_accounts_for_parent(
        ParentId='ou-bgtv-tu73r6dm',
    )

    tenant_accounts = ""
    for account_id in organizations_response['Accounts']:
        tenant_accounts += account_id['Id'] + ","

    tenant_accounts = tenant_accounts[:-1]

    MASTER_PAYER_S3.put_object(
        Body=tenant_accounts, Bucket=TENANT_BUCKET, Key=TENANT_KEY + "/" + TENANTS_FILE)
