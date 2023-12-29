variable "security_group_ids" {
    description = "security group for redshift allowed traffic"
    type        = list(string)
    default     =  ["sg-017679fbd91486c99"]
}

variable "admin_password" {
    type = string
    default = "Unhealthy6-Walnut-Unhitched"
    sensitive = true
}

variable "admin_username" {
    type = string
    default = "kiks"
}

variable "db_name" {
    type = string
    default = "userbehavior"
}

variable "vpc_id" {
    type = string
    default = "vpc-072a65c15380540d9"
}