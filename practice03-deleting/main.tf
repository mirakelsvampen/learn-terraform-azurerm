# resource "azurerm_resource_group" "this" {
#   name     = "tf-${var.env}-shared-prac01" # notice variable usage, string interpolation is used here
#   location = var.location # notice variable usage here

#   tags = var.tags
# }

resource "azurerm_virtual_network" "this" {
  name                = "tf-vnet-prac01-${var.shortenv}" # notice variable usage, string interpolation is used here
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.gold.location
  resource_group_name = data.azurerm_resource_group.gold.name

  tags = var.tags
}

resource "azurerm_subnet" "this" {
  name                 = "tf-snet-prac01-${var.shortenv}"
  resource_group_name  = data.azurerm_resource_group.gold.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "this" {
  name                = "tf-pip-prac01-${var.shortenv}"
  resource_group_name = data.azurerm_resource_group.gold.name
  location            = data.azurerm_resource_group.gold.location
  allocation_method   = "Static"

  tags = var.tags
}

resource "azurerm_network_interface" "this" {
  name                = "tf-nic-prac01-${var.shortenv}"
  location            = data.azurerm_resource_group.gold.location
  resource_group_name = data.azurerm_resource_group.gold.name

  ip_configuration {
    name                          = "nic01"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = "tf-vm-prac01-${var.shortenv}"
  resource_group_name = data.azurerm_resource_group.gold.name
  location            = data.azurerm_resource_group.gold.location
  size                = "Standard_B1s"
  admin_username      = "demouser"
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  admin_ssh_key {
    username   = "demouser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = var.tags
}

resource "azurerm_managed_disk" "data_01" {
  name                 = "data_disk_01"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.gold.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_01_this_vm" {
  managed_disk_id    = azurerm_managed_disk.data_01.id
  virtual_machine_id = azurerm_linux_virtual_machine.this.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_storage_account" "this" {
  name                     = "terraformsacc01p"
  resource_group_name      = data.azurerm_resource_group.gold.name
  location                 = data.azurerm_resource_group.gold.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
}