output "iam_role_arn" {
    value = aws_iam_role.redshift-lake-role.arn  
    }
output "allow_ssh_secgroup_name" {
    value = aws_security_group.allow_ssh.name
}

output "ec2_iam_profile" {
    value = aws_iam_instance_profile.ec2-userbehavior_iam_profile.name
}
