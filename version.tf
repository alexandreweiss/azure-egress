provider "azurerm" {
  features {
  }
  subscription_id = var.subscription_id
}

provider "random" {

}

provider "aviatrix" {
  controller_ip           = data.dns_a_record_set.controller_ip.addrs[0]
  username                = var.admin_username
  password                = var.admin_password
  skip_version_validation = true
}

terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
}
