provider "aws" {
    profile = "${var.aws_profile}"
    region  = "${var.aws_region}"
}

# Took this from the vpc module, this is to allow
# us to decrypt files via credstash globally
# tl;dr copy pasta from vpc module
resource "aws_iam_policy" "user_management_credstash" {

    name        = "user_management_iam_credstash"
    description = "Policy for reading the Credstash DynamoDB for user management"

    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "kms:Decrypt"
            ],
            "Effect": "Allow",
            "Resource": "${var.CredstashKeyID}",
            "Condition": {
                "StringEquals": {
                    "kms:EncryptionContext:environment": "global",
                    "kms:EncryptionContext:region": "${var.aws_region}",
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
            "Resource": "${var.CredstashDynamoDB}"
        }
    ]
}
POLICY
}

resource "aws_iam_policy_attachment" "user_management_credstash" {
    name    = "user_management_iam_credstash"
    roles   = [
        "${aws_iam_role.user_management_iam.id}"
    ]
    policy_arn = "${aws_iam_policy.user_management_credstash.arn}"
}

# User management IAM
resource "aws_iam_role" "user_management_iam" {
    lifecycle {
        create_before_destroy = true
    }

    name = "user_management_iam"

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

resource "aws_iam_role_policy" "user_management_iam" {

    lifecycle {
        create_before_destroy = true
    }

    provisioner "local-exec" {
        command = "sleep 10"
    }

    name = "user_management_iam"
    role = "${aws_iam_role.user_management_iam.id}"
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

resource "aws_lambda_function" "user_management_iam" {

    depends_on = [
        "aws_iam_role_policy.user_management_iam"
    ]

    function_name   = "user_management_iam"
    s3_bucket       = "nubis-stacks"
    s3_key          = "${var.nubis_version}/lambda/UserManagement.zip"
    role            = "${aws_iam_role.user_management_iam.arn}"
    handler         = "index.handler"
    description     = "Queries LDAP and inserts user into consul and create and delete IAM users"
    memory_size     = 128
    runtime         = "nodejs4.3"
    timeout         = "30"

}

resource "aws_cloudwatch_event_rule" "user_management_event_iam" {
    name                = "user_management_iam"
    depends_on          = [
        "aws_lambda_function.user_management_iam"
    ]

    description         = "Sends payload over a periodic time"
    schedule_expression = "${var.user_management_rate}"
}

resource "aws_cloudwatch_event_target" "user_management_iam" {
    rule        = "user_management_iam"
    arn         = "${aws_lambda_function.user_management_iam.arn}"
    input       = <<EOF
    {
        "command": "./nubis-user-management",
        "args": [
            "-execType=IAM",
            "-useDynamo=true",
            "-region=${var.aws_region}",
            "-environment=global",
            "-service=nubis",
            "-accountName=${var.account_name}",
            "-key=nubis/global/user-sync/config"
        ]
    }
    EOF
}

resource "aws_lambda_permission" "allow_cloudwatch" {
    depends_on      = [
        "aws_lambda_function.user_management_iam",
        "aws_cloudwatch_event_rule.user_management_event_iam"
    ]

    statement_id    = "AllowExecutionFromCloudWatch"
    action          = "lambda:InvokeFunction"
    function_name   = "user_management_iam"
    principal       = "events.amazonaws.com"
    source_arn      = "${aws_cloudwatch_event_rule.user_management_event_iam.arn}"
}

