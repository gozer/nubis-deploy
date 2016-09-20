provider "aws" {
  region = "${var.region}"
}

resource "aws_iam_role" "lambda" {
  count = "${var.enabled}"

  lifecycle {
    create_before_destroy = true
  }

  name = "user-management-global-${var.region}"

  provisioner "local-exec" {
    command = "sleep 30"
  }

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "lambda.amazonaws.com"
                ]
            },
            "Action": [
                "sts:AssumeRole"
            ]
        }
    ]
}
EOF
}

resource "aws_lambda_function" "user_management" {
  count         = "${var.enabled}"
  function_name = "user-management-iam-${var.region}"
  s3_bucket     = "nubis-stacks-${var.region}"
  s3_key        = "${var.version}/lambda/UserManagement.zip"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "index.handler"
  description   = "Queries LDAP and inserts user into consul and create and delete IAM users"
  memory_size   = 128
  runtime       = "nodejs4.3"
  timeout       = "300"
}

# Took this from the vpc module, this is to allow
# us to decrypt files via credstash globally
# tl;dr copy pasta from vpc module
resource "aws_iam_role_policy" "credstash" {
  count = "${var.enabled}"
  name  = "user-management-iam-credstash-${var.region}"
  role  = "${aws_iam_role.lambda.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "kms:Decrypt"
            ],
            "Effect": "Allow",
            "Resource": "${var.credstash_key}",
            "Condition": {
                "StringEquals": {
                    "kms:EncryptionContext:environment": "global",
                    "kms:EncryptionContext:region": "${var.region}",
                    "kms:EncryptionContext:service": "nubis"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:ListTables",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:DescribeReservedCapacity",
                "dynamodb:DescribeReservedCapacityOfferings"
            ],
            "Resource": "${var.credstash_db}"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy" "iam" {
  count = "${var.enabled}"
  name  = "user-management-iam-policy-${var.region}"
  role  = "${aws_iam_role.lambda.id}"

  lifecycle {
    create_before_destroy = true
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Sid": "CreateIAMUsers",
            "Effect": "Allow",
            "Action": [
                "iam:AttachRolePolicy",
                "iam:AttachUserPolicy",
                "iam:AddUserToGroup",
                "iam:CreateAccessKey",
                "iam:CreateRole",
                "iam:CreateUser",
                "iam:DeleteAccessKey",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:DeleteUser",
                "iam:DeleteUserPolicy",
                "iam:DetachRolePolicy",
                "iam:GetUser",
                "iam:GetRole",
                "iam:ListAccessKeys",
                "iam:ListGroupsForUser",
                "iam:ListUsers",
                "iam:PutRolePolicy",
                "iam:RemoveUserFromGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_cloudwatch_event_rule" "lambda" {
  count = "${var.enabled}"
  name  = "user-managment-iam-event-${var.region}"

  description         = "Sends payload over a periodic time"
  schedule_expression = "${var.rate}"
}

resource "aws_cloudwatch_event_target" "lambda" {
  count = "${var.enabled}"
  rule  = "${aws_cloudwatch_event_rule.lambda.name}"
  arn   = "${aws_lambda_function.user_management.arn}"

  input = <<EOF
    {
        "command": "./nubis-user-management",
        "args": [
            "-execType=IAM",
            "-useDynamo=true",
            "-region=${var.region}",
            "-environment=global",
            "-service=nubis",
            "-accountName=${var.account_name}",
            "-key=nubis/global/user-sync/config"
        ]
    }
    EOF
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  count         = "${var.enabled}"
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.user_management.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.lambda.arn}"
}
