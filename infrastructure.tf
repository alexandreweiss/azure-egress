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
  single_ip_snat   = false
  single_az_ha     = false
  ha_gw            = false
  resource_group   = azurerm_resource_group.rg.name
  attached         = false
  depends_on       = [azurerm_subnet_route_table_association.subnet-1-rt-assoc]
}

# Nat gateway subnet-0
module "nat_gw" {
  source = "github.com/alexandreweiss/misc-tf-modules/nat-gateway"

  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  nat_gateway_name    = "${var.location_short}-nat-gw"
}

# resource "azurerm_subnet_nat_gateway_association" "nat_gw_association_0" {
#   nat_gateway_id = module.nat_gw.nat_gateway.id
#   subnet_id      = azurerm_subnet.subnet[0].id
# }
