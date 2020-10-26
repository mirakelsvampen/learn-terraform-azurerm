# Practice #1 - Virtual machine

This lession will provide you with a basic understanding of:

1. How to authenticate terraform with az cli
2. How to declare and use variables
3. How to deploy resources to Azure

## Authenticating

You must first login with az cli and set the correct context. Terraform will use the active az cli session when running. 

1. az login
2. az account list
3. az account set -s "< subscription_id >"

## Create SSH keys

1. Open a Powershell window and run the following command. Continue by just pressing enter when promted.
**If you have a pre-existing key that is named id_rsa then you can use that one and skip this step**

`ssh-keygen -t rsa -C "terraform_practice`

The ssh keys will be used for the deployment of a Ubuntu virtual machine in Azure.

## Inspect the code

Take a quick look at the code and try to understand what it declaring. Notice how some of the variables are used to set attribute values within resources.

Try to understand the differences between variables.tf and terraform.tfvars.

1. variables.tf tells what variables are to be expected. They are just declarations.
2. terraform.tfvars actually assigns values to the expected variables

## Initialize the project

1. Run `terraform init` in order to initialize the project. If everything goes according to plan you should see that terraform is initializing the backend and should download the azurerm plugin according to the version specified in settings.tf.

## Create a plan

Now we want to actually see if our code runs but dont necessarily want to go live with it just yet.
Instead, we can create a plan. Run the following command:

`terraform plan -var-file=terraform.tfvars`

**Notice that the terraform.tfvars file is referenced. There are multiple ways of telling terraform what values a variable has. However, using .tfvars files are handy to use with version control. You can reference as many .tfvars files as you would like.**

## Going live

Now that you have created a theoretical outcome of the code. Lets go live with the following command:

`terraform apply -var-file=terraform.tfvars`