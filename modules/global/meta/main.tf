provider "aws" {
    profile = "${var.aws_profile}"
    region = "${var.aws_region}"
}

provider "aws" {
  alias = "state"
  profile = "${var.aws_profile}"
  region  = "eu-west-1"
}

# XXX: Doesn't work on create, TF bug ?
resource "aws_s3_bucket" "state" {
    count = 0
    provider = "aws.state"

    lifecycle {
      ignore_changes = ["bucket"]
    }

    bucket = "nubis-deploy-${uuid()}"
    acl = "private"
}
