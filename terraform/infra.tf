terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#Create s3 bucket
resource "aws_s3_bucket" "create-lake" {
  bucket = "userbehavior-lake"
}

#Reference iam_roles from permissions
module "redshift_iam" {
  source = "./permissions"  
}


#create redshift serverless workgroup

resource "aws_redshiftserverless_namespace" "warehouse-namespace" {
  namespace_name = "userbehavior-namespace"
  admin_user_password = var.admin_password
  admin_username = var.admin_username
  db_name = var.db_name
  iam_roles = [module.redshift_iam.iam_role_arn]
}


resource "aws_redshiftserverless_workgroup" "warehouse-workgroup" {
  namespace_name = aws_redshiftserverless_namespace.warehouse-namespace.id
  workgroup_name = "userbehavior-workgroup"
  base_capacity = "128"
  subnet_ids = var.subnet_ids
  security_group_ids = var.security_group_ids
}


