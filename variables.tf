variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = 2
}
variable "name" {
  default = "project"
}

variable "use_nat" {
  default = false
  type    = bool
}