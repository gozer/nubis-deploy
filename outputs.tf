output "admins_users" {
  value = "${module.global_admins.admins_users}"
}

output "admins_access_keys" {
  value = "${module.global_admins.admins_access_keys}"
}

output "admins_secret_keys" {
  value = "${module.global_admins.admins_secret_keys}"
}

output "account_id" {
  value = "${module.global_admins.account_id}"
}

output "datadog_access_key" {
  value = "${module.global_meta.datadog_access_key}"
}

output "datadog_secret_key" {
  value = "${module.global_meta.datadog_secret_key}"
}

output "nameservers" {
  value = "${module.global_meta.nameservers}"
}

output "cloudhealth_assume_role_arn" {
  value = "${module.global_meta.cloudhealth_assume_role_arn}"
}

output "cloudhealth_assume_role_external_id" {
  value = "${module.global_meta.cloudhealth_assume_role_external_id}"
}
