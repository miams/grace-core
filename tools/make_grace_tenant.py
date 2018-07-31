"""Creates a GRACE tenant file and budget notification parameter."""
#!/usr/bin/env python
# Requires Python 3.6.4 or higher and boto3
#
# This script will take input and create a GRACE Tenant terraform file that should be checked in to
# source control. Hopefully, this will make it easier to create GRACE Tenants.
# GRACE Tenants must be uniquely named. Before proceeding, ensure that you have a unique name in
# mind for input.
#
# by Jason Miller - jasong.miller@gsa.gov
#

import sys
import os.path
import boto3
import argparse

"""Set up command parsing"""
parser = argparse.ArgumentParser(description='Create GRACE users, budget parameters, '
                                 + 'IAM role parameters and a tenant file for a new tenant. Two sets of AWS credentials '
                                 + 'must be supplied.'
                                 + '  The credentials must exist in your ~.aws/credentials file. You must also supply '
                                 + ' a KMS KeyId to create the new tenant IAM roles.',
                                 epilog='Sorry, I know it is painful.')
parser.add_argument('--masteraccount', required=True, help='AWS credentials profile of the master account')
parser.add_argument('--authlandingaccount', required=True,
                    help='AWS credentials profile of the authlanding account')
parser.add_argument('--keyid', required=True,
                    help='KeyId of the KMS key to use when creating IAM roles')
args = parser.parse_args()

"""Set up boto3 sessions"""
master_payer_session = boto3.session.Session(
    profile_name=str(args.masteraccount))
authlanding_session = boto3.session.Session(
    profile_name=str(args.authlandingaccount))
authlanding_key_id = str(args.keyid)
master_payer_ssm = master_payer_session.client('ssm')
authlanding_ssm = authlanding_session.client('ssm')

def main():
    """Main function to collect info and produce the file."""
    budget_notification_email = input("Enter a budget notification email address: ")
    budget_notification_amount = input("Enter the amount of whole dollars for the "
                                       + "tenant budget (ex: 100 for $100): ")
    tenant_name = input("Enter the short name of the tenant (ex: d2d): ")
    number_of_tenant_environments = input("Enter the number of tenant accounts/environments"
                                          + " that will be used, aside from prod and management."
                                          + " If no other environments will be used, just input "
                                          + "0: ")
    prod_environment_email_owner = input("Enter the email address of the tenant prod owner: ")
    mgmt_environment_email_owner = input("Enter the email address of the tenant mgmt owner: ")
    tenant_environment_names = []
    tenant_email_owners = []
    tenant_environment_names.append(tenant_name + "_" + "prod")
    tenant_environment_names.append(tenant_name + "_" + "mgmt")
    tenant_email_owners.append(prod_environment_email_owner)
    tenant_email_owners.append(mgmt_environment_email_owner)
    for i in range(int(number_of_tenant_environments)):
        tenant_environment_name = input("Enter a tenant environment name (ex: staging) - "
                                        + "DO NOT use prod or mgmt: ")
        tenant_environment_names.append(tenant_name + "_" + tenant_environment_name)
        tenant_email_owner = input("Enter the email address of the owner for the account: ")
        tenant_email_owners.append(tenant_email_owner)
    create_iam_roles = "true"
    print("IAM users are next. We'll ask which IAM users to add to the roles. If the users "
        + "do not exist, we'll create them. You can specify the same user for all three roles.")
    iam_admin_user = input("Enter the name of an IAM user to be added to the admin role: ")
    iam_poweruser_user = input("Enter the name of an IAM user to be added to the power user role: ")
    iam_viewonly_user = input("Enter the name of an IAM user to be added to the view only role: ")
#     if create_iam_roles != "true" or create_iam_roles != "false":
#         create_iam_roles = input(
#             "Create the default IAM roles in each tenant? Valid values are 'true' or 'false': ")
    print("The information you gave me is listed below. Please review it before continuing.")
    print("Budget notification email: " + budget_notification_email)
    print("Budget notification amount: " + budget_notification_amount)
    print("Tenant name: " + tenant_name)
    total_number_of_tenant_environments = int(
        number_of_tenant_environments) + 2
    print("Number of tenant environments: " + str(total_number_of_tenant_environments))
    for i in range(total_number_of_tenant_environments):
        print("Tenant Environment Name: " + tenant_environment_names[i] + ", Tenant email owner: "
              + tenant_email_owners[i])
#     print("Create default IAM roles: " + create_iam_roles)
    print("Admin IAM user: " + iam_admin_user)
    print("Power IAM user: " + iam_poweruser_user)
    print("View only IAM user: " + iam_viewonly_user)
    ready_to_continue = input("Ready to proceed? (yes or no): ")
    if ready_to_continue != "yes" or ready_to_continue != "no":
        if ready_to_continue == "no":
            sys.exit('Then please rerun this script with the proper values.')
    print(" ")
    print("Now we will process tenants. If you receive some sort of error, most likely you do not "
          + "have the AWS environment configured with permissions to the GRACE platform. We'll try "
          + "to create a budget notification for you via the AWSCLI, then output a terraform file. "
          + "It will be up to you to get the Terraform file into the grace-core repo and apply it "
          + "properly.")
    print("Creating budget parameter...")
    create_budget_parameter_response = master_payer_ssm.put_parameter(
        Name = tenant_name + '-budget',
        Description = 'Budget notification parameter for tenant',
        Value = str(budget_notification_amount),
        Type = 'String',
        Overwrite=True
    )
    print("create_budget_parameter_response: " + str(create_budget_parameter_response))
    print("Checking list of IAM users...")
    # Check to see if the primary IAM user exists. If not, create it, then add it to the authlanding user list.
    # Check to see if the user exists from the above values. If not, put the user into the SSM parameter for the user
    # list, but we'll let the pipeline create them. This may present issues when running Terraform in CircleCI.
    create_iam_admin_user = "false"
    create_iam_poweruser_user = "false"
    create_iam_viewonly_user = "false"
    print("Comparing list of IAM users with the users you specified...")
    # Check Admin IAM user
    create_iam_admin_user = search_authlanding_user_list_parameter(
        iam_admin_user, "admin")
    if create_iam_admin_user == "true":
        print("Adding admin user to the authlanding user list...")
        update_authlanding_user_list_parameter(iam_admin_user, "admin")
    # Check PowerUser IAM user
    create_iam_poweruser_user = search_authlanding_user_list_parameter(iam_poweruser_user, "poweruser")
    if create_iam_poweruser_user == "true":
        print("Adding poweruser user to the authlanding user list...")
        update_authlanding_user_list_parameter(iam_poweruser_user, "poweruser")
    # Check View Only user
    create_iam_viewonly_user = search_authlanding_user_list_parameter(
        iam_viewonly_user, "viewonly")
    if create_iam_viewonly_user == "true":
        print("Adding viewonly user to the authlanding user list...")
        update_authlanding_user_list_parameter(iam_viewonly_user, "viewonly")
    print("User actions complete...")
    print("Creating IAM role lists...")
    create_iam_admin_role_list_response = authlanding_ssm.put_parameter(
        Name=tenant_name + '-tenant-admin-iam-role-list',
        Description='List of users for admin role in' + tenant_name,
        Value=str(iam_admin_user),
        Type='SecureString',
        KeyId=authlanding_key_id,
        Overwrite=True
    )
    print("create_iam_admin_role_list_response: " + str(create_iam_admin_role_list_response))
    create_iam_poweruser_role_list_response = authlanding_ssm.put_parameter(
        Name=tenant_name + '-tenant-poweruser-iam-role-list',
        Description='List of users for poweruser role in' + tenant_name,
        Value=str(iam_poweruser_user),
        Type='SecureString',
        KeyId=authlanding_key_id,
        Overwrite=True
    )
    print("create_iam_poweruser_role_list_response:" + str(create_iam_poweruser_role_list_response))
    create_iam_viewonly_role_list_response = authlanding_ssm.put_parameter(
        Name=tenant_name + '-tenant-viewonly-iam-role-list',
        Description='List of users for viewonly role in' + tenant_name,
        Value=str(iam_viewonly_user),
        Type='SecureString',
        KeyId=authlanding_key_id,
        Overwrite=True
    )
    print("create_iam_viewonly_role_list_response: " + str(create_iam_viewonly_role_list_response))
    print("Roles created...")
    print("Now producing the Terraform file...")
    """Check if the terraform file exists, first. Otherwise, we'll create it."""
    # TODO: Probably needs to be a little more robust. Should detect the filename and keep
    # incrementing something.
    file_name = "tenant_" + tenant_name + ".tf"
    if os.path.exists(file_name):
        file_name = tenant_name + "_tenant_NEW.tf"
    f = open(file_name, "w+")
    f.write("# Tenant file for "+ tenant_name + ", autogenerated by python tool.\n")
    f.write("data \"aws_ssm_parameter\" \"" + tenant_name + "_tenant_admin_iam_role_list\" {\n")
    f.write("  provider = \"aws.authlanding\"\n")
    f.write("\n")
    f.write("  # The name for this parameter must be unique to other tenants!\n")
    f.write("  name = \"" + tenant_name + "-tenant-admin-iam-role-list\"\n")
    f.write("}\n")
    f.write("\n")
    f.write("data \"aws_ssm_parameter\" \"" + tenant_name +
            "_tenant_poweruser_iam_role_list\" {\n")
    f.write("  provider = \"aws.authlanding\"\n")
    f.write("\n")
    f.write("  # The name for this parameter must be unique to other tenants!\n")
    f.write("  name = \"" + tenant_name + "-tenant-poweruser-iam-role-list\"\n")
    f.write("}\n")
    f.write("\n")
    f.write("data \"aws_ssm_parameter\" \"" + tenant_name +
            "_tenant_viewonly_iam_role_list\" {\n")
    f.write("  provider = \"aws.authlanding\"\n")
    f.write("\n")
    f.write("  # The name for this parameter must be unique to other tenants!\n")
    f.write("  name = \"" + tenant_name + "-tenant-viewonly-iam-role-list\"\n")
    f.write("}\n")
    f.write("\n")
    f.write("locals {\n")
    f.write("  " + tenant_name + "_tenant_admin_iam_role_list = [\"${split(\",\", "
            + "data.aws_ssm_parameter." + tenant_name + "_tenant_admin_iam_role_list."
            + "value)}\"]\n")
    f.write("  " + tenant_name +
            "_tenant_poweruser_iam_role_list = [\"${split(\",\", "
            + "data.aws_ssm_parameter." + tenant_name + "_tenant_poweruser_iam_role_list."
            + "value)}\"]\n")
    f.write("  " + tenant_name +
            "_tenant_viewonly_iam_role_list = [\"${split(\",\", data.aws_ssm_parameter."
            + tenant_name + "_tenant_viewonly_iam_role_list.value)}\"]\n")
    f.write("}\n")
    f.write("\n")
    for i in range(total_number_of_tenant_environments):
        f.write("module \"tenant_" + tenant_environment_names[i] + "\" {\n")
        f.write("  source = \"../member_account\"\n")
        # Commenting this next portion out because of bug in terraform:
        # https://github.com/hashicorp/terraform/issues/10462
        # if i != 0:
        #     f.write("  depends_on = [\"module.tenant_" + tenant_environment_names[i - 1] + "\"]\n")
        f.write("\n")
        f.write("  name = \"tenant_" + tenant_environment_names[i] + "\"\n")
        f.write("  email = \"" + tenant_email_owners[i] + "\"\n")
        f.write("  authlanding_prod_account_id = \"${module.authlanding_prod.account_id}\"\n")
        f.write("  create_iam_roles = \"" + create_iam_roles + "\"\n")
        f.write("\n")
        if create_iam_roles != "false":
            f.write("  tenant_admin_iam_role_list = [\"${local." + tenant_name
                    + "_tenant_admin_iam_role_list}\"]\n")
            f.write("  tenant_poweruser_iam_role_list = [\"${local." +
                    tenant_name + "_tenant_poweruser_iam_role_list}\"]\n")
            f.write("  tenant_viewonly_iam_role_list = [\"${local." +
                    tenant_name + "_tenant_viewonly_iam_role_list}\"]\n")
            f.write("  enable_member_guardduty = \"true\"\n")
            f.write("  guardduty_master_detector_id = \"" +
                    "${aws_guardduty_detector.aws_guardduty_master.id}\"\n")
        f.write("}\n")
        f.write("\n")
    f.write("module \"" + tenant_name + "_budget\" {\n")
    f.write("  source = \"../budget\"\n")
    f.write("\n")
    f.write("  name = \"" + tenant_name + "\"\n")
    f.write("\n")
    f.write("  budget_notifications = [\n")
    f.write("    {\n")
    f.write("      protocol = \"email\"\n")
    f.write("      endpoint = \"" + budget_notification_email + "\"\n")
    f.write("    }\n")
    f.write("  ]\n")
    f.write("\n")
    f.write("  account_ids = [\n")
    for i in range(total_number_of_tenant_environments):
        f.write("    \"${module.tenant_" + tenant_environment_names[i]
                + ".account_id}\",\n")
    f.write("  ]\n")
    f.write("}\n")
    f.write("\n")
    if create_iam_roles != "false":
        f.write("# IAM role permission section - have to give sts-assume-role permission "
            + "to users to allow them to switch to the roles.\n")
        f.write("\n")
        for i in range(total_number_of_tenant_environments):
            # Admin policy and role attachment
            f.write("resource \"aws_iam_policy\" \"sts_assume_admin_role_user_policy_" + tenant_environment_names[i] + "\" {\n")
            f.write("  provider = \"aws.authlanding\"\n")
            f.write("  name = \"" + tenant_environment_names[i] + "_admin_assume_role_user_policy\"\n")
            f.write("  description = \"Allows this user to assume the admin role in this " + tenant_environment_names[i] + " account\"\n")
            f.write("\n")
            f.write("  policy = <<EOF\n")
            f.write("{\n")
            f.write("  \"Version\": \"2012-10-17\",\n")
            f.write("  \"Statement\": [\n")
            f.write("     {\n")
            f.write("       \"Effect\": \"Allow\",\n")
            f.write("       \"Resource\": \"${module.tenant_" + tenant_environment_names[i] + ".tenant_admin_role_arn}\",\n")
            f.write("       \"Action\": \"sts:AssumeRole\"\n")
            f.write("     }\n")
            f.write("   ]\n")
            f.write("}\n")
            f.write("EOF\n")
            f.write("}\n")
            f.write("\n")
            f.write("resource \"aws_iam_user_policy_attachment\" \"sts_assume_admin_role_user_policy_" +             tenant_environment_names[i] + "_attachment\" {\n")
            f.write("  provider = \"aws.authlanding\"\n")
            f.write("  count = \"${length(local." + tenant_name + "_tenant_admin_iam_role_list)}\"\n")
            f.write("  user = \"${local." + tenant_name + "_tenant_admin_iam_role_list[count.index]}\"\n")
            f.write("  policy_arn = \"${aws_iam_policy.sts_assume_admin_role_user_policy_" +                         tenant_environment_names[i] + ".arn}\"\n")
            f.write("}\n")
            f.write("\n")
            # Power User role
            f.write("resource \"aws_iam_policy\" \"sts_assume_poweruser_role_user_policy_" + tenant_environment_names[i] + "\" {\n")
            f.write("  provider = \"aws.authlanding\"\n")
            f.write("  name = \"" + tenant_environment_names[i] + "_poweruser_assume_role_user_policy\"\n")
            f.write("  description = \"Allows this user to assume the poweruser role in this " + \
                    tenant_environment_names[i] + "account\"\n")
            f.write("\n")
            f.write("  policy = <<EOF\n")
            f.write("{\n")
            f.write("  \"Version\": \"2012-10-17\",\n")
            f.write("  \"Statement\": [\n")
            f.write("     {\n")
            f.write("       \"Effect\": \"Allow\",\n")
            f.write(
                    "       \"Resource\": \"${module.tenant_" + tenant_environment_names[i] + ".tenant_poweruser_role_arn}\",\n")
            f.write("       \"Action\": \"sts:AssumeRole\"\n")
            f.write("     }\n")
            f.write("   ]\n")
            f.write("}\n")
            f.write("EOF\n")
            f.write("}\n")
            f.write("\n")
            f.write("resource \"aws_iam_user_policy_attachment\" \"sts_assume_poweruser_role_user_policy_" + tenant_environment_names[i] + "_attachment\" {\n")
            f.write("  provider = \"aws.authlanding\"\n")
            f.write(
                    "  count = \"${length(local." + tenant_name + "_tenant_poweruser_iam_role_list)}\"\n")
            f.write("  user = \"${local." + tenant_name + \
                    "_tenant_poweruser_iam_role_list[count.index]}\"\n")
            f.write("  policy_arn = \"${aws_iam_policy.sts_assume_poweruser_role_user_policy_" + tenant_environment_names[i] + ".arn}\"\n")
            f.write("}\n")
            f.write("\n")
            # View Only role
            f.write("resource \"aws_iam_policy\" \"sts_assume_viewonly_role_user_policy_" + tenant_environment_names[i] + "\" {\n")
            f.write("  provider = \"aws.authlanding\"\n")
            f.write("  name = \"" + tenant_environment_names[i] + "_viewonly_assume_role_user_policy\"\n")
            f.write("  description = \"Allows this user to assume the viewonly role in this " + \
                    tenant_environment_names[i] + "account\"\n")
            f.write("\n")
            f.write("  policy = <<EOF\n")
            f.write("{\n")
            f.write("  \"Version\": \"2012-10-17\",\n")
            f.write("  \"Statement\": [\n")
            f.write("     {\n")
            f.write("       \"Effect\": \"Allow\",\n")
            f.write(
                    "       \"Resource\": \"${module.tenant_" + tenant_environment_names[i] + ".tenant_viewonly_role_arn}\",\n")
            f.write("       \"Action\": \"sts:AssumeRole\"\n")
            f.write("     }\n")
            f.write("   ]\n")
            f.write("}\n")
            f.write("EOF\n")
            f.write("}\n")
            f.write("\n")
            f.write("resource \"aws_iam_user_policy_attachment\" \"sts_assume_viewonly_role_user_policy_" + tenant_environment_names[i] + "_attachment\" {\n")
            f.write("  provider = \"aws.authlanding\"\n")
            f.write(
                    "  count = \"${length(local." + tenant_name + "_tenant_viewonly_iam_role_list)}\"\n")
            f.write("  user = \"${local." + tenant_name + \
                    "_tenant_viewonly_iam_role_list[count.index]}\"\n")
            f.write("  policy_arn = \"${aws_iam_policy.sts_assume_viewonly_role_user_policy_" + tenant_environment_names[i] + ".arn}\"\n")
            f.write("}\n")
            f.write("\n")
    f.close()
    print("Finished.")
        
def get_authlanding_user_list_parameter():
    authlanding_user_list = authlanding_ssm.get_parameter(
        Name='authlanding-user-list',
        WithDecryption=True
    )
    user_list = authlanding_user_list['Parameter']['Value']
    return str(user_list)
        
def search_authlanding_user_list_parameter(user_name, role):
    user_list = get_authlanding_user_list_parameter()
    print("Current user list parameter contents (" + role + " user execution): " + str(user_list))
    if user_name in user_list:
        print("User " + user_name + " found, so not creating them.")
        return "false"
    else:
        print("We'll create the user " + user_name + " as role " + role)
        return "true"

def update_authlanding_user_list_parameter(user_name, role):
    user_list = get_authlanding_user_list_parameter()
    create_iam_user_response = authlanding_ssm.put_parameter(
        Name='authlanding-user-list',
        Description='List of users for GRACE platform',
        Value=str(user_list) + "," + str(user_name),
        Type='SecureString',
        Overwrite=True
    )
    print("create_iam_" + role + "_user_response: " +
          str(create_iam_user_response))

# def create_iam_role_parameter(iam_role_parameter, user_name):
        
# def create_tenant_file(tenant_name):
        
def usage():
    """Just display a little page about usage."""
    print(' -------------------------------------------------------------------------')
    print(' Jason Miller (jasong.miller@gsa.gov) June 13, 2018')
    print(' ')
    print(' Take some input and produce a valid GRACE Tenant Terraform file.')
    print(' Tenants must be uniquely named, so please make sure you do not already')
    print(' have a tenant that will use the same name as what you\'re trying to use.')
    print(' ')
    print(' Make sure you have an AWS account set up in your environment that has')
    print(' credentials to create an SSM parameter in the GRACE master account.')
    print(' ')
    print(' Simply follow the instructions during input, then check the resulting')
    print(' Terraform file into a branch on https://github.com/gsa/grace-core')
    print(' Then submit a PR to bring it into the master branch.')
    print(' -------------------------------------------------------------------------')
    sys.exit(' ')

if __name__ == "__main__":
    main()
