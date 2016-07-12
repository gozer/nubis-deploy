provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

provider "aws" {
  alias   = "state"
  profile = "${var.aws_profile}"
  region  = "${var.aws_region_state}"
}

module "cloudhealth" {
  source = "github.com/nubisproject/nubis-terraform-cloudhealth"

  aws_profile = "${var.aws_profile}"
  aws_region  = "${var.aws_region_state}"
}

resource "aws_iam_user" "datadog" {
  path = "/nubis/datadog/"
  name = "datadog"
}

resource "aws_iam_access_key" "datadog" {
  user = "${aws_iam_user.datadog.name}"
}

resource "aws_iam_user_policy" "datadog" {
  name = "datadog-readonly"
  user = "${aws_iam_user.datadog.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
"Action": [
                    "autoscaling:Describe*",
                    "cloudtrail:DescribeTrails",
                    "cloudtrail:GetTrailStatus",
                    "cloudwatch:Describe*",
                    "cloudwatch:Get*",
                    "cloudwatch:List*",
                    "dynamodb:list*",
                    "dynamodb:describe*",
                    "ec2:Describe*",
                    "ec2:Get*",
                    "ecs:Describe*",
                    "ecs:List*",
                    "elasticache:Describe*",
                    "elasticache:List*",
                    "elasticloadbalancing:Describe*",
                    "elasticmapreduce:List*",
                    "elasticmapreduce:Describe*",
                    "kinesis:List*",
                    "kinesis:Describe*",
                    "logs:Get*",
                    "logs:Describe*",
                    "logs:FilterLogEvents",
                    "logs:TestMetricFilter",
                    "rds:Describe*",
                    "rds:List*",
                    "route53:List*",
                    "ses:Get*",
                    "sns:List*",
                    "sns:Publish",
                    "sqs:GetQueueAttributes",
                    "sqs:ListQueues",
                    "sqs:ReceiveMessage",
                    "support:*"
                  ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_route53_delegation_set" "meta" {
  lifecycle {
    create_before_destroy = true
  }

  reference_name = "Meta"
}
