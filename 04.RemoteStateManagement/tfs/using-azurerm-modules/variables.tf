# Input variable definitions


variable "vnet_tags" {
  description = "VNET tags"
  type        = map(string)
  default = {
    environment = "terraform"
    owner       = "Rui"
  }
}
