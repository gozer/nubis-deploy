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
