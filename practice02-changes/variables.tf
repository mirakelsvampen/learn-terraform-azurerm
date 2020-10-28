#General variables
variable "env" {
  type = string
}
variable "shortenv" {
  type = string
}
variable "location" {
  type = string
}

variable "tags" {
  type = map
  default = {
    Environment        = "Test"
    Project            = "Terraforming"
    CostCenter         = "IT-dep"
    Description        = "Shared resources used for terraform practices"
    TechnicalContact   = "support@example.com"
  }
}