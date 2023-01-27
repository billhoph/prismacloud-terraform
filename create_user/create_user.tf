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