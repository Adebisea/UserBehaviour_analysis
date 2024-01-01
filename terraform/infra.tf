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

#get subnet ids

data "aws_subnets" "subnet_ids" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

#create redshift serverless workgroup

resource "aws_redshiftserverless_workgroup" "warehouse-workgroup" {
  namespace_name = aws_redshiftserverless_namespace.warehouse-namespace.id
  workgroup_name = "userbehavior-workgroup"
  base_capacity = "128"
  subnet_ids = data.aws_subnets.subnet_ids.ids
  security_group_ids = var.security_group_ids
}


#create emr serverless

resource "aws_emrserverless_application" "emr" {
  name          = "userbehavior_emr_applications"
  release_label = "emr-6.15.0"
  type          = "spark"

  initial_capacity {
    initial_capacity_type = "Driver"

    initial_capacity_config {
      worker_count = 1
      worker_configuration {
        cpu    = "1 vCPU"
        memory = "2 GB"
        }
      }
    }

  maximum_capacity {
    cpu    = "2 vCPU"
    memory = "4 GB"
    }
  }

#create budget
resource "aws_budgets_budget" "userbehavior" {
  name              = "budget-userbehavior-monthly"
  budget_type       = "COST"
  limit_amount      = "2"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "LESS_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.email]
  }
}

#Create ec2 instance

data "aws_ami" "example" {
  executable_users = ["self"]
  most_recent      = true
  name_regex       = "^myami-\\d{3}"
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["myami-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}