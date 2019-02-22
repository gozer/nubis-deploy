variable aws_region {}

variable enabled {}

variable cloudtrail_sns_topic {}

variable cloudtrail_bucket {}

variable notify_email {
  default = "infra-aws@mozilla.com"
}
