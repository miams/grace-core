"""Creates a GRACE tenant file and budget notification parameter."""
#!/usr/bin/env python
# Requires Python 3.6.4
#
# This script will take input and create a GRACE Tenant terraform file that should be checked in to
# source control. Hopefully, this will make it easier to create GRACE Tenants.
# GRACE Tenants must be uniquely named. Before proceeding, ensure that you have a unique name in
# mind for input.
#
# by Jason Miller - jasong.miller@gsa.gov
#

# import re
import sys
import os.path

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
    create_iam_roles = ""
    if create_iam_roles != "true" or create_iam_roles != "false":
        create_iam_roles = input(
            "Create the default IAM roles in each tenant? Valid values are 'true' or 'false': ")
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
    print("Create default IAM roles: " + create_iam_roles)
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
    from subprocess import run
    # TODO: Return the friendly happy stuff if we get back a JSON "Version: 1"
    create_budget_parameter = run(["aws ssm put-parameter --type String --name "
                                   + tenant_name + "-budget --value " +
                                   str(budget_notification_amount)], shell=True)
    """Check if the terraform file exists, first. Otherwise, we'll create it."""
    # TODO: Probably needs to be a little more robust. Should detect the filename and keep
    # incrementing something.
    file_name = tenant_name + "_tenant.tf"
    if os.path.exists(file_name):
        file_name = tenant_name + "_tenant_NEW.tf"
    f = open(file_name, "w+")
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
        if i != 0:
            f.write("  depends_on = [\"module.tenant_" + tenant_environment_names[i - 1] + "\"]\n")
        f.write("\n")
        f.write("  name = \"tenant_" + tenant_environment_names[i] + "\"\n")
        f.write("  email = \"" + tenant_email_owners[i] + "\"\n")
        f.write("  authlanding_prod_account_id = \"${module.authlanding_prod.account_id}\"\n")
        f.write("  create_iam_roles = \"" + create_iam_roles + "\"\n")
        f.write("\n")
        f.write("  tenant_admin_iam_role_list = [\"${local." + tenant_name
                + "_tenant_admin_iam_role_list}\"]\n")
        f.write("  tenant_poweruser_iam_role_list = [\"${local." +
                tenant_name + "_tenant_poweruser_iam_role_list}\"]\n")
        f.write("  tenant_viewonly_iam_role_list = [\"${local." +
                tenant_name + "_tenant_viewonly_iam_role_list}\"]\n")
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
    f.write("  ]")
    f.write("}")
    f.close()

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
