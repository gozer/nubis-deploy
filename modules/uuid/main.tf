provider "aws" {
  version = "~> 0.1"
  region  = "${var.aws_region}"
}

resource "aws_cloudformation_stack" "uuid" {
  count = "${var.enabled * length(split(",", var.environments))}"

  lifecycle {
    create_before_destroy = true
  }

  name = "uuid-${var.name}-${element(split(",",var.environments), count.index)}"

  template_body = "${file("${path.module}/uuid.json")}"

  parameters = {
    LambdaUUIDArn = "${var.lambda_uuid_arn}"
  }
}
