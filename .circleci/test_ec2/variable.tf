
# Ec2 instance type
variable "instance_type" {
    type    = string
    default = "t3.micro"
}

variable "vpc_cidr_block" {
    type    = string
    default = "0.0.0.0/0"
}

# vpc id
variable "vpc_id" {
    type    = string
    default = "vpc-072a65c15380540d9"
}