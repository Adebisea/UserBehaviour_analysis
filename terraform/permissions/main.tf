
# IAM role for redshift access to s3
resource "aws_iam_policy" "redshift-lake-policy" {
    name = "redshiftS3_policy"
    description = "Policy for redshift serverless to access s3"

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:Get*",
                    "s3:List*",
                    "s3:Describe*",
                    "s3-object-lambda:Get*",
                    "s3-object-lambda:List*"
                ],
                "Resource": "*"
            }
        ]
    })
    }

resource "aws_iam_role" "redshift-lake-role" {
    name = "redshift-lake-role"

    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "sts:AssumeRole"
                ],
                "Principal": {
                    "Service": [
                        "redshift.amazonaws.com"
                    ]
                }
            }
        ]
    })
    }


resource "aws_iam_role_policy_attachment" "redshift-lake-role-policy-attach" {
    role       = aws_iam_role.redshift-lake-role.name
    policy_arn = aws_iam_policy.redshift-lake-policy.arn
    }


#Security group for ec2 to allow ssh traffic

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
  }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

}

#IAM Role for ec2 to access S3, EMR & Redshift

resource "aws_iam_role" "ec2_userbehavior_role" {
    name = "ec2_userbehavior_role"

    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "sts:AssumeRole"
                ],
                "Principal": {
                    "Service": [
                        "ec2.amazonaws.com"
                    ]
                }
            }
        ]
    }) 
    managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess","arn:aws:iam::aws:policy/AmazonRedshiftAllCommandsFullAccess","arn:aws:iam::aws:policy/AmazonEMRFullAccessPolicy_v2"]
    }

resource "aws_iam_instance_profile" "ec2-userbehavior_iam_profile" {
  name = "ec2-userbehavior_iam_profile"
  role = aws_iam_role.ec2_userbehavior_role.name
}