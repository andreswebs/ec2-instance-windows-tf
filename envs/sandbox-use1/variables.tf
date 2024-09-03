variable "name" {
  type = string
}

variable "root_volume_size" {
  type    = number
  default = 100
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ad_domain_id" {
  type    = string
  default = null
}
