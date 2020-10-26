resource "azurerm_resource_group" "this" {
  name     = "tf-${var.env}-shared-prac01" # notice variable usage, string interpolation is used here
  location = var.location # notice variable usage here

  tags = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "tf-vnet-prac01-${var.shortenv}" # notice variable usage, string interpolation is used here
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

resource "azurerm_subnet" "this" {
  name                 = "tf-snet-prac01-${var.shortenv}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "this" {
  name                = "tf-pip-prac01-${var.shortenv}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"

  tags = var.tags
}

resource "azurerm_network_interface" "this" {
  name                = "tf-nic-prac01-${var.shortenv}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

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
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
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