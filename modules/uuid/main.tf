provider "aws" {
    profile = "${var.aws_profile}"
    region = "${var.aws_region}"
}

#module "consul_master_token" {
#  source = "../uuid"
#  
#  enabled = "${var.enabled}"
#  
#  name = "consul-master-token"
#  
#  environments = "${var.environments}"
#  
#  aws_profile = "${var.aws_profile}"
#  aws_region = "${var.aws_region}"
#  
#  lambda_uuid_arn = "${var.lambda_uuid_arn}"
#}

resource "aws_cloudformation_stack" "uuid" {
  count = "${var.enabled * length(split(",", var.environments))}"
  name = "uuid-${var.name}-${element(split(",",var.environments), count.index)}"

  template_body = "${file("${path.module}/uuid.json")}"
  
  parameters = {
    LambdaUUIDArn = "${var.lambda_uuid_arn}"
  }
}
