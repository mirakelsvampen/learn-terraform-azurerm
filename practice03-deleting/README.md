# Practice #3 - Destruction

This lession will provide you with a basic understanding of:

1. Redeploy individual resources
2. Destroying infrastructure

## Authenticating

*In case you are not authenticated anymore. Else skip this step* 
You must first login with az cli and set the correct context. Terraform will use the active az cli session when running. 

1. az login
2. az account list
3. az account set -s "< subscription_id >"

## Move the tfstate from the previous excercise

Open a WSL or Powershell window and navigate to the folder of this exercise. Then run the following command:

`cp ..\practice02-changes\terraform.tfstate .\terraform.tfstate`


## Redeploy invividual resources

Use the `taint` command in order to redeploy a single resource. Pick a random resource of choice and see what happens.

1. terraform taint < resource.name >
2. Now run apply and see what happens

## Splitting everything

We have decided that our testing environment has met up with our expectations and now we want to deploy to production.
However, we do not want to duplicate the whole project. We can leverage workspaces in order to save our environments into different state files while still using the same root module.

> use the `terraform workspace list` command to show your current selected workspace

1. copy the terraform.tfvars file and name it prod.tfvars
2. Edit the prod.tfvars file and change the values to the following:
    ```
    #General variables
    env = "prod"
    shortenv = "p"
    location = "westeurope"
    ```
2. copy the terraform.tfvars file and name it test.tfvars
3. remove the original terraform.tfvars file
4. Create a new production terraform workspace with `terraform workspace new prod`
5. Create a new testing terraform workspace with `terraform workspace new test`
6. Set the current workspace to production with `terraform workspace select prod`
7. Apply the code with `terraform apply -var-file=prod.tfvars`

Your production tfstate will not be seperate from the original testing tfstate!

## Destroy everything!

When deploying infrastructure with Terraform has you covered. However, it also has you covered with deletion of resource. This way you dont have to think about dependencies and think more about the solutions you are designing itself. We have no more need for testing. Lets nuke it!

1. Change workspace to test  with `terraform workspace select test`
2. run:

```
terraform destroy
```
