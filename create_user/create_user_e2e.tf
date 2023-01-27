resource "prismacloud_user_profile" "example" {
    first_name = "Bill"
    last_name = "Ho"
    email = "hojohn269@msn.com"
    username = "hojohn269@msn.com"
    role_ids = [
        "11111111-2222-3333-4444-555555555555",
        "12345678-2222-3333-4444-555555555555"
    ]
    time_zone = "America/Los_Angeles"
    default_role_id = "11111111-2222-3333-4444-555555555555"
}

resource "prismacloud_user_role" "example" {
    name = "my user role"
    description = "Made by Terraform"
    role_type = "Account Group Admin"
}

# Single AWS account type.
resource "prismacloud_cloud_account" "aws_example" {
    disable_on_destroy = true
    aws {
        name = "myAwsAccountName"
        account_id = "accountIdHere"
        external_id = "eidHere"
        group_ids = [
            prismacloud_account_group.g1.group_id,
        ]
        role_arn = "some:arn:here"
    }
}

/*
You can also create user profiles from a CSV file using native Terraform
HCL and looping.  Assume you have a CSV file (user_profiles.csv) of user profiles that looks like this (with
"||" separating user role IDs from each other):

"first_name","last_name","email","role_ids","access_keys_allowed","time_zone","default_role_id"
"FirstName1","LastName1","test1@email.com","11111111-2222-3333-4444-555555555555||12345678-2222-3333-4444-555555555555",true,"Asia/Calcutta","12345678-2222-3333-4444-555555555555"
"FirstName2","LastName2","test2@email.com","11111111-2222-3333-4444-555555555555||12345678-2222-3333-4444-555555555555",true,"America/Los_Angeles","12345678-2222-3333-4444-555555555555"
Here's how you would do this:
*/
locals {
    user_profiles = csvdecode(file("user_profiles.csv"))
    user_roles = csvdecode(file("user_roles.csv"))
    instances = csvdecode(file("aws.csv"))
}

// Now specify the user profile resource with a loop like this:
resource "prismacloud_user_profile" "example" {
    for_each = { for inst in local.user_profiles : inst.email => inst }

    first_name = each.value.first_name
    last_name = each.value.last_name
    email = each.value.email
    username = each.value.email
    role_ids = split("||", each.value.role_ids)
    access_keys_allowed = each.value.access_keys_allowed
    time_zone = each.value.time_zone
    default_role_id = each.value.default_role_id
}

// Now specify the user role resource with a loop like this:
resource "prismacloud_user_role" "example" {
    for_each = { for inst in local.user_roles : inst.name => inst }

    name = each.value.name
    description = each.value.description
    role_type = each.value.roletype
    restrict_dismissal_access = each.value.restrict_dismissal_access
    account_group_ids = (each.value.roletype == "System Admin" || each.value.roletype == "Build and Deploy Security") ? [] : split("||", each.value.account_group_ids)
    additional_attributes {
        only_allow_ci_access = each.value.only_allow_ci_access
        only_allow_read_access = each.value.only_allow_read_access
        has_defender_permissions = each.value.has_defender_permissions
        only_allow_compute_access = each.value.only_allow_compute_access
    }  
}

// Now specify the cloud account resource with a loop like so:
resource "prismacloud_cloud_account" "csv" {
    for_each = { for inst in local.instances : inst.name => inst }

    aws {
        name = each.value.name
        account_id = each.value.accountId
        external_id = each.value.externalId
        group_ids = split("||", each.value.groupIDs)
        role_arn = each.value.roleArn
    }
}