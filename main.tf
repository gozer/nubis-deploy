module "global_admins" {
  source = "modules/global/admins"

  aws_profile = "${var.aws_profile}"
  aws_region = "us-east-1"

  admin_users = "${var.admin_users}"

  account_name = "${var.account_name}"
  nubis_version = "${var.nubis_version}"
}

module "global_meta" {
  source = "modules/global/meta"

  aws_profile = "${var.aws_profile}"
  aws_region = "us-east-1"

  account_name = "${var.account_name}"
  nubis_version = "${var.nubis_version}"
  
  state_uuid = "${var.state_uuid}"
}

module "vpcs" {
  source = "modules/global/vpcs"

  enable_consul = "${lookup(var.features,"consul")}"
  enable_jumphost = "${lookup(var.features,"jumphost")}"
  enable_fluent = "${lookup(var.features,"fluent")}"
  enable_opsec = "${lookup(var.features,"opsec")}"
  enable_stack_compat = "${lookup(var.features,"stack_compat")}"

  my_ip = "${var.my_ip}"

  aws_regions = "${var.aws_regions}"
  aws_profile = "${var.aws_profile}"
  aws_account_id = "${module.global_admins.account_id}"

  # This exists to force a dependency on the global admins module
  account_name = "${module.global_admins.account_name}"
  
  nubis_version = "${var.nubis_version}"
  nubis_domain = "${var.nubis_domain}"
  environments = "${var.environments}"
  environments_networks = "${var.environments_networks}"
  environments_ipsec_targets = "${var.environments_ipsec_targets}"

  consul_secret = "${lookup(var.consul, "secret")}"
  consul_master_acl_token = "${lookup(var.consul, "master_acl_token")}"

  datadog_api_key = "${lookup(var.datadog, "api_key")}"
}
