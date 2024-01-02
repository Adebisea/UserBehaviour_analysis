variable "security_group_ids" {
    description = "security group for redshift allowed traffic"
    type        = list(string)
    default     =  ["sg-017679fbd91486c99"]
}

# Redshift credentials

variable "admin_password" {
    type        = string
    default     = "Unhealthy6-Walnut-Unhitched"
    sensitive   = true
}

variable "admin_username" {
    type    = string
    default = "kiks"
}

variable "db_name" {
    type    = string
    default = "userbehavior"
}

# vpc id
variable "vpc_id" {
    type    = string
    default = "vpc-072a65c15380540d9"
}

# email for budget notification
variable "email" {
    type    = string
    default = "placeholder@gmail.com"
}

# Name of key pair to ssh into an ec2 instance
variable "keypair_name" {
    type    = string
    default = "userbehavior_key"
}

# Ec2 instance type
variable "instance_type" {
    type    = string
    default = "t3.micro"
}