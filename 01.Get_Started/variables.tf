variable "prefix" {
  type    = string
  default = "sakk"
}

variable "tags" {
  type = map

  default = {
    environment = "terraform"
    owner        = "rui"
  }
}

variable "sku" {
  default = {
    brazilsouth  = "18.04-LTS"
  }
}