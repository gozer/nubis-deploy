module "us-east-1" {
  source  = "../../vpc"

  aws_region = "us-east-1"
  aws_profile = "${var.aws_profile}"
  aws_account_id = "${var.aws_account_id}"
 
  # Okay, somewhat nasty
  #  - take the list of regions, look for the one we care about and make it XXX
  #  - take the result, and make all non-Xes into Ys
  #  - take the result of that (should be either XXX or YYY...)
  #  - change XXX, if found into 1
  #  - change YYY... if found into 0
  #  Result, 1 if the region is found, 0 otherwise
  enabled = "${replace(replace(replace(replace(var.aws_regions, "/.*,?us-east-1,?.*/", "XXX"), "/[^X]+/", "Y" ), "XXX", "1"),"/Y+/","0")}"

  # This exists to force a dependency on the global module
  account_name = "${var.account_name}"
  nubis_version = "${var.nubis_version}"
  environments = "${var.environments}"
  
  # should convert over to just passing in environments_networks
  admin_network = "${element(split(",",var.environments_networks), 0)}"
  prod_network = "${element(split(",",var.environments_networks), 1)}"
  stage_network = "${element(split(",",var.environments_networks), 2)}"

  # should convert over to just passing in environments_ipsec_targets
  prod_ipsec_target = "${element(split(",",var.environments_ipsec_targets), 1)}"
  stage_ipsec_target = "${element(split(",",var.environments_ipsec_targets), 2)}"
  
  consul_secret = "${var.consul_secret}"
}

# XXX: Yes, cut-n-paste, can't be helped at the moment
module "us-west-2" {
  source  = "../../vpc"

  aws_region = "us-west-2"
  aws_profile = "${var.aws_profile}"
  aws_account_id = "${var.aws_account_id}"
 
  # Okay, somewhat nasty
  #  - take the list of regions, look for the one we care about and make it XXX
  #  - take the result, and make all non-Xes into Ys
  #  - take the result of that (should be either XXX or YYY...)
  #  - change XXX, if found into 1
  #  - change YYY... if found into 0
  #  Result, 1 if the region is found, 0 otherwise
  enabled = "${replace(replace(replace(replace(var.aws_regions, "/.*,?us-west-2,?.*/", "XXX"), "/[^X]+/", "Y" ), "XXX", "1"),"/Y+/","0")}"

  # This exists to force a dependency on the global module
  account_name = "${var.account_name}"
  nubis_version = "${var.nubis_version}"
  environments = "${var.environments}"
  
  # should convert over to just passing in environments_networks
  admin_network = "${element(split(",",var.environments_networks), 0)}"
  prod_network = "${element(split(",",var.environments_networks), 1)}"
  stage_network = "${element(split(",",var.environments_networks), 2)}"

  # should convert over to just passing in environments_ipsec_targets
  prod_ipsec_target = "${element(split(",",var.environments_ipsec_targets), 1)}"
  stage_ipsec_target = "${element(split(",",var.environments_ipsec_targets), 2)}"

  consul_secret = "${var.consul_secret}"
}

