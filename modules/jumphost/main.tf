provider "aws" {
    profile = "${var.aws_profile}"
    region = "${var.aws_region}"
}

resource "atlas_artifact" "nubis-jumphost" {
  count = "${var.enabled}"
  name = "nubisproject/nubis-jumphost"
  type = "amazon.image"

  lifecycle { create_before_destroy = true }

  metadata {
        project_version = "${var.nubis_version}"
    }
}

resource "aws_cloudformation_stack" "vpc" {
  count = "${var.enabled * 3}"
 
  name  = "jumphost-${element(split(",",var.environments), count.index)}"

  capabilities = [ "CAPABILITY_IAM" ]
  disable_rollback = true
  template_body = "${file("${path.module}/../../jumphost/nubis/cloudformation/main.json")}"

  parameters = {
    ServiceName = "jumphost"
    TechnicalOwner = "${var.technical_owner}"
    SSHKeyName    = "${var.key_name}"
    StacksVersion = "${var.nubis_version}"
    Environment = "${element(split(",",var.environments), count.index)}"

    # Fugly hack to work around limitations of TFs atlas provider, unfortunately, this is the only known
    # way to extract an AMI id by region from AWS, yuck
    AmiId = "${element(split(":", element(split(",", atlas_artifact.nubis-jumphost.id), lookup(var.atlas_region_map, var.aws_region))), 1)}"
  }
}
