variable aws_profile {}
variable aws_region {}
variable aws_account_id {}

variable admin_network {}
variable stage_network {}
variable prod_network {}

variable prod_ipsec_target {}
variable stage_ipsec_target {}

variable account_name {}
variable environments {}

variable nubis_ssh_key {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0/tR0k8b6gIQpd6IHyEJdzmGur60ShmOdQGpBoF7IPMBWTHgc5w3CTcqvK6aJ6GpZHyybi9D9EON4+1WZTf9tcsdUP8kyVOs66sw26FWeCri2k1zomsGP9Ysr3bSUe3dpi5vipk1PDXpaD6wYs/eEtQxO1U1wRCGEGclRdh5G8UbOMwrPIHvQd77ma5RyXzd36htzFtsKnuyTtG7xHGPphzVqLZmiDZeyxbr3mCuaMBW30syEKviiVbMo4RsmDqzR3N2ltInGKYgZpCW7fd7KrZL/G0oi/XS+Up5MvmYSsP2tYNx909CWFpWDsXEPMNddl7ZYizHXLbLexU8+0h5j nubis"
}

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

variable consul_secret {}

variable enable_jumphost {}

variable enable_fluent {}

variable enable_consul {}

variable my_ip {}
