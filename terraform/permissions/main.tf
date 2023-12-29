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