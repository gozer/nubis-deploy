variable aws_profile {}
variable aws_region {}

variable admin_network {}
variable stage_network {}
variable prod_network {}

variable prod_ipsec_target {}
variable stage_ipsec_target {}

variable account_name {}
variable environments {}

variable technical_owner {
  default = "infra-aws@mozilla.com"
}

variable nubis_version {
}

variable ssh_key_name {
  default = "nubis"
}

variable enabled {
  default = 1
}
