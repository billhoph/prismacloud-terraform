# Configure the prismacloud provider
provider "prismacloud" {
    json_config_file = ".prismacloud_auth.json"
}

data "prismacloud_cloud_accounts" "example" {}

