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

variable admin_users {
  default = "gozer,limed,riweiss,jcrowe"
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

variable nubis_domain {
  default = "nubis.allizom.org"
}

variable features {
  default = {
    consul = 0
    jumphost = 0
    fluent = 0
  }
}

variable my_ip {
  default = "127.0.0.1/32"
}
