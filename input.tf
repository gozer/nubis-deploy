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
