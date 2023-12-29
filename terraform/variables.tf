
variable "subnet_ids" {
    description = "Subnets ids for redshift clusters to be deployed in."
    type        = list(string)
    default     = ["subnet-0033c21bfb8d89722", "subnet-0108623f7a0864f1e", "subnet-0f7eeb98dce2a7cd8", "subnet-0e935d597fb149930", "subnet-0cea9e18431dd240f", "subnet-05abeec698074d40b"]

}

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