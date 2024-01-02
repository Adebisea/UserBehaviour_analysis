#cidr_blocks for ec2 ssh security group

variable "vpc_cidr_block" {
    type    = string
    default = "0.0.0.0/0"
}

# vpc id
variable "vpc_id" {
    type    = string
    default = "vpc-072a65c15380540d9"
}