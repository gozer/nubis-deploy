module "global_admins" {
  source = "modules/global/admins"

  aws_profile = "${var.aws_profile}"
  aws_region = "us-east-1"

  account_name = "${var.account_name}"
  nubis_version = "${var.nubis_version}"
}
