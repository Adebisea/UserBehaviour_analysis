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
module "iam_perms" {
  source = "./permissions"  
}


#create redshift serverless workgroup

resource "aws_redshiftserverless_namespace" "warehouse-namespace" {
  namespace_name = "userbehavior-namespace"
  admin_user_password = var.admin_password
  admin_username = var.admin_username
  db_name = var.db_name
  iam_roles = [module.iam_perms.iam_role_arn]
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
  namespace_name      = aws_redshiftserverless_namespace.warehouse-namespace.id
  workgroup_name      = "userbehavior-workgroup"
  base_capacity       = "128"
  subnet_ids          = data.aws_subnets.subnet_ids.ids
  security_group_ids  = var.security_group_ids
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

data "aws_ami" "ubuntu" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220420"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "tls_gen_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_keypair" {
  key_name_prefix = var.keypair_name
  public_key      = tls_private_key.tls_gen_key.public_key_openssh
}

resource "aws_instance" "ec2_userbehavior" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.ec2_keypair.key_name
  vpc_security_group_ids = [module.iam_perms.allow_ssh_secgroup_name]
  iam_instance_profile = module.iam_perms.ec2_iam_profile
}

