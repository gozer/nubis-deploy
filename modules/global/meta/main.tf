provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

provider "aws" {
  alias   = "state"
  profile = "${var.aws_profile}"
  region  = "${var.aws_region_state}"
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
                    "ec2:Describe*",
                    "ec2:Get*",
                    "elasticache:Describe*",
                    "elasticache:List*",
                    "elasticloadbalancing:Describe*",
                    "iam:Get*",
                    "iam:List*",
                    "kinesis:Get*",
                    "kinesis:List*",
                    "kinesis:Describe*",
                    "rds:Describe*",
                    "rds:List*",
                    "ses:Get*",
                    "ses:List*",
                    "sns:List*",
                    "sns:Publish",
                    "sqs:GetQueueAttributes",
                    "sqs:ListQueues",
                    "sqs:ReceiveMessage"
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
