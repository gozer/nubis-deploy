# environments
provider "aws" {
    profile = "${var.aws_profile}"
    region = "${var.aws_region}"
}

module "consul-admin" {
  #source = "github.com/nubisproject/nubis-consul//nubis/terraform?ref=${var.nubis_version}"
  source = "/home/gozer/opt/src/mozilla.org/gozer/nubis/consul/nubis/terraform"

  enabled = "${var.enabled}"

  environment = "admin"

  aws_profile = "${var.aws_profile}"
  region = "${var.aws_region}"
  aws_account_id = "${var.aws_account_id}"

  key_name = "${var.key_name}"
  nubis_version = "${var.nubis_version}"
  service_name = "${var.service_name}"

  consul_secret = "${var.consul_secret}"
  credstash_key = "${aws_cloudformation_stack.consul.0.outputs.CredstashKeyId}"

  shared_services_security_group_id = "${aws_cloudformation_stack.consul.0.outputs.SharedServicesSecurityGroupId}"
  internet_security_group_id = "${aws_cloudformation_stack.consul.0.outputs.InternetAccessSecurityGroupId}"

  private_subnets = "${aws_cloudformation_stack.consul.0.outputs.PrivateSubnets}"
  public_subnets  = "${aws_cloudformation_stack.consul.0.outputs.PublicSubnets}"
  zone_id = "${aws_cloudformation_stack.consul.0.outputs.HostedZoneId}"
  vpc_id = "${aws_cloudformation_stack.consul.0.outputs.VpcId}"

 master_acl_token = "00000000-0000-0000-0000-000000000000"

  ssl_cert = "/tmp/consul.pem"
  ssl_key = "/tmp/consul.key"
}

resource "aws_cloudformation_stack" "consul" {
  count = "${var.enabled * 3}"

  name  = "consul-${element(split(",",var.environments), count.index)}-info"

  capabilities = [ "CAPABILITY_IAM" ]
  disable_rollback = false
  template_body = "${file("${path.module}/main.json")}"

  parameters = {
    StacksVersion = "${var.nubis_version}"
    Environment = "${element(split(",",var.environments), count.index)}"
    ServiceName = "${var.service_name}"
  }
}
