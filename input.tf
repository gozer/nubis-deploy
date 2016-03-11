variable account_name {}

variable aws_profile {
  default = "default"
}

variable nubis_version {
  default = "v1.0.1-sec1"
}

variable environments {
  default = "admin,stage,prod"
}

variable environments_networks {
}

variable environments_ipsec_targets {
  default = "0.0.0.0,0.0.0.0,0.0.0.0"
}

variable aws_regions {
  default = "us-east-1,us-west-2"
}

variable consul_master_acl_token {
  default = "00000000-0000-0000-0000-000000000000"
}

variable consul_secret {
  default = "sGPeZ2clbA+PTi1naruZiw=="
}

variable enable_jumphost {
  default = 0
}

variable enable_fluent {
  default = 0
}

variable enable_consul {
  default = 0
}
