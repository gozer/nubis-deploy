output "admins_users" {
  value = "${module.global_admins.admins_users}"
}

output "admins_access_keys" {
  value = "${module.global_admins.admins_access_keys}"
}

output "admins_secret_keys" {
  value = "${module.global_admins.admins_secret_keys}"
}
