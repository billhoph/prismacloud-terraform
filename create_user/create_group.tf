resource "prismacloud_account_group" "example" {
    name = "My new group"
    description = "Made by Terraform"
    account_ids = [
    prismacloud_cloud_account1,
    ]
}

/*
You can also create account groups from a CSV file using native Terraform
HCL and looping.  Assume you have a CSV file (acc_grps.csv) of account groups that looks like this (with
"||" separating account IDs from each other):

"name","description","accountIDs"
"test_acc_grp1","Made by Terraform","123456789||2315456789"
"test_acc_grp2","Made by Terraform","2315456789"

Here's how you would do this:
*/
locals {
    account_groups = csvdecode(file("acc_grps.csv"))
}

// Now specify the account group resource with a loop like this:
resource "prismacloud_account_group" "example" {
        for_each = { for inst in local.account_groups : inst.name => inst }

        name = each.value.name
        account_ids = split("||", each.value.accountIDs)
        description = each.value.description
}