variable aws_profile {}

variable account_name {}

variable aws_region {
  default = ""
}

variable technical_contact {
  default = "infra-aws@mozilla.com"
}

variable nubis_version {
  default = "master"
}

variable ssh_key_name {
  default = "nubis"
}

variable nubis_domain {
  default = "nubis.allizom.org"
}

variable state_uuid {
  default = ""
}
