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
variable subnet_ids {}

variable ssh_security_groups {}
variable internet_access_security_groups {}
variable shared_services_security_groups {}
variable credstash_policies {}
variable credstash_key {}
variable credstash_dynamodb_table {}

variable lambda_uuid_arn {}

variable project {
  default = "fluent-collector"
}
