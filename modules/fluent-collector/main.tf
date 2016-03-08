provider "aws" {
    profile = "${var.aws_profile}"
    region = "${var.aws_region}"
}

resource "atlas_artifact" "nubis-fluent-collector" {
  name = "nubisproject/nubis-fluentd-collector"
  type = "amazon.image"

  lifecycle { create_before_destroy = true }

  metadata {
        project_version = "${var.nubis_version}"
    }
}

resource "aws_cloudformation_stack" "vpc" {
  count = "${var.enabled * 3}"
 
  name  = "fluent-collector-${element(split(",",var.environments), count.index)}"

  capabilities = [ "CAPABILITY_IAM" ]
  template_body = "${file("${path.module}/../../fluent-collector/nubis/cloudformation/main.json")}"

  parameters = {
    ServiceName = "${var.service_name}"
    TechnicalOwner = "${var.technical_owner}"
    SSHKeyName    = "${var.key_name}"
    StacksVersion = "${var.nubis_version}"
    Environment = "${element(split(",",var.environments), count.index)}"
    # Fugly hack to work around limitations of TFs atlas provider, unfortunately, this is the only known
    # way to extract an AMI id by region from AWS, yuck
    AmiId = "${element(split(":", element(split(",", atlas_artifact.nubis-fluent-collector.id), lookup(var.atlas_region_map, var.aws_region))), 1)}"
  }
}
