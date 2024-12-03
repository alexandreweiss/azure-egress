data "azurerm_subscription" "current" {
}

resource "random_integer" "random" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.location_short}-lab-${random_integer.random.result}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.lab_cidr]
  location            = var.location
  name                = "${var.location_short}-lab-vn"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  count = var.subnet_count

  name                 = "subnet-${count.index}"
  address_prefixes     = [cidrsubnet(var.lab_cidr, 8, count.index)]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

data "template_file" "test_vm_config" {
  template = file("${path.module}/test-vm-config.tftpl")

  vars = {
  }
}

module "vm" {
  source = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  count  = var.subnet_count

  environment         = "test"
  location            = var.location
  location_short      = var.location_short
  index_number        = count.index
  resource_group_name = azurerm_resource_group.rg.name
  custom_data         = base64encode(data.template_file.test_vm_config.rendered)
  subnet_id           = azurerm_subnet.subnet[count.index].id
  admin_ssh_key       = var.admin_ssh_key
  customer_name       = "lab"
  depends_on = [
  ]
}



