provider "aws" {
    profile = "${var.aws_profile}"
    region = "${var.aws_region}"
}

provider "aws" {
  alias = "state"
  profile = "${var.aws_profile}"
  region  = "${var.aws_region_state}"
}

# Chicken and egg problem for the destroy operations here
resource "aws_s3_bucket" "state" {
    count = 0
    provider = "aws.state"
    
    lifecycle {
      prevent_destroy = true
    }
    
    force_destroy = true

    bucket = "nubis-deploy-${var.state_uuid}"
    acl = "private"
}
