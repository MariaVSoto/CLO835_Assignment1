# Instance type
variable "instance_type" {
  default = "t3.medium"
  description = "Type of the instance"
}

variable "key_name" {
  description = "Name of the EC2 Key Pair to allow SSH access"
  type        = string
}



