variable "region" {
  type = string
  default = "ap-south-1"
}

# variable "access_key" {
#   type = string
#   default = ""
# }

# variable "secret_key" {
#   type = string
#   default = ""
# }

variable "vpc_cidr" {
  type = string
  default = "178.0.0.0/16" 
}

variable "public_subnet_cidr" {
  type = string
  default = "178.0.0.0/24"
}

variable "private_subnet_cidr" {
  type = string
  default = "178.0.1.0/24"
}

variable "private_db_subnet_cidr" {
  type = string
  default = "178.0.2.0/24"
} 

variable "availability_zone" {
  type = string
  default = "ap-south-1a"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}