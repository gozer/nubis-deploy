variable aws_profile {}
variable aws_region {}

variable key_name {}
variable nubis_version {}
variable nubis_domain {}
variable service_name {}

variable environments {}

variable enabled {}

variable technical_owner {}

variable zone_id {}
variable vpc_ids {}
variable public_subnet_ids {}

variable ssh_security_groups {}
variable internet_access_security_groups {}
variable shared_services_security_groups {}
variable credstash_policy {}

variable project {
  default = "jumphost"
}
