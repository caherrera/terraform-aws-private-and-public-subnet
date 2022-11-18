variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = 2
}

variable "use_nat" {
  default = false
  type    = bool
}

variable "name" {
  default = "project"
}

variable "public_tags" {
  default = {}
}

variable "private_tags" {
  default = {}
}

variable "public_cidr_block" {
  default = ""
}

variable "private_cidr_block" {
  default = ""
}

variable "newbits" {
  default = 8
}

variable "netnum_offset" {
  description = "Offset for separate private and public subnets"
  default     = 20
}

variable "vpc_id" {

}