terraform {
  required_providers {
    prismacloud = {
      source = "PaloAltoNetworks/prismacloud"
      version = "1.2.11"
    }
  }
}
# Configure the prismacloud provider
provider "prismacloud" {
    json_config_file = "prismacloud_auth.json"
}

data "prismacloud_account_groups" "example" {}

output "prismacloud_account_groups_list" {
    value = data.prismacloud_account_groups.example.listing
}