# Practice #1 - Virtual machine

This lession will provide you with a basic understanding of:

1. How to change existing infratructure
2. How to import infratructure into the tfstate

## Authenticating

*In case you are not authenticated anymore. Else skip this step* 
You must first login with az cli and set the correct context. Terraform will use the active az cli session when running. 

1. az login
2. az account list
3. az account set -s "< subscription_id >"

## Move the tfstate from the previous excercise

Open a WSL or Powershell window and navigate to the folder of this exercise. Then run the following command:

`cp ..\practice01-vm\terraform.tfstate .\terraform.tfstate`

## Modify the code

Now that we understand the code from the last excercise. Lets add some managed disks to our virtual machine.

Append the following block to `main.tf`

```
resource "azurerm_managed_disk" "data_01" {
  name                 = "data_disk_01"
  location             = var.location
  resource_group_name  = azurerm_resource_group.this.name
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
```

## Adding the disk to the VM

Lets see if we can add the disk to terraform.

1. `terraform init`
2. `terraform validate`
3. `terraform plan -var-file=terraform.tfvars`
4. `terraform apply -var-file=terraform.tfvars` 

Notice the changes, the output should be according to the following snippet:
```
Plan: 2 to add, 0 to change, 0 to destroy.
```

## Createing a resource outside of the terraform tfstate

Lets create a storage account with the following command:

**WSL**
```
storage_account_name="terraformsacc01p"
resource_group_name="tf-test-shared-prac01"
location="westeurope"

az storage account create --name ${storage_account_name} --resource-group ${resource_group_name} --location ${location} --sku Standard_ZRS --encryption-services blob
```

**Powershell**
```
$storage_account_name="terraformsacc01p"
$resource_group_name="tf-test-shared-prac01"
$location="westeurope"

az storage account create --name $storage_account_name --resource-group $resource_group_name --location $location --sku Standard_ZRS --encryption-services blob
```

But why do such a thing? How should we proceed if we want to manage the storage account with terraform?

1. First we add the code to our project
2. However, running an apply with result in an error, because terraform tries to add something that already exists.
3. We solve this problem by using `terraform import` 

Add the following code to our project:

```
resource "azurerm_storage_account" "this" {
  name                     = "terraformsacc01p"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
}
```

Now we need to know what the Id of our storage account looks like. Run the following AZ CLI command:
```
az storage account show --name terraformsacc01p -o json --query '{id:id}'
```

Now run the following terraform command in order to import our storage account into the tfstate.

terraform import azurerm_storage_account.this < id_of_storage_account_here >

If you run `terraform apply -var-file=terraform.tfvars` the output should be:

```
0 to add, 0 to change, 0 to destroy.
```