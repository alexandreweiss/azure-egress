resource "azurerm_subnet" "subnet_spoke_gw" {
  name                 = "subnet-spoke-gw"
  address_prefixes     = [cidrsubnet(var.lab_cidr, 8, 199)]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}


module "aviatrix_spoke" {
  source = "terraform-aviatrix-modules/mc-spoke/aviatrix"

  cloud            = "Azure"
  name             = "azr-${var.location_short}-spoke"
  vpc_id           = "${azurerm_virtual_network.vnet.name}:${azurerm_resource_group.rg.name}:${azurerm_virtual_network.vnet.guid}"
  gw_subnet        = azurerm_subnet.subnet_spoke_gw.address_prefixes[0]
  use_existing_vpc = true
  region           = var.location
  account          = var.azr_account
  single_ip_snat   = true
  single_az_ha     = false
  ha_gw            = false
  resource_group   = azurerm_resource_group.rg.name
  attached         = false
}
