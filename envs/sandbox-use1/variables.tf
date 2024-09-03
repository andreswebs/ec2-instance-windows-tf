variable "name" {
  type = string
}

variable "volume_delete" {
  type    = bool
  default = true
}

variable "volume_encrypted" {
  type    = bool
  default = true
}

variable "volume_size" {
  type    = number
  default = 100
}

variable "instance_type" {
  type    = string
  default = "m7a.xlarge"
}

variable "instance_termination_disable" {
  type    = bool
  default = false
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ssh_key_name" {
  type    = string
  default = ""
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "cidr_whitelist_ipv4" {
  type    = list(string)
  default = []
}

variable "enclave_enabled" {
  type    = bool
  default = false
}
