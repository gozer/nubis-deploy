output "admins_users" {
  value = "${join(",", aws_iam_access_key.admins.*.user)}"
}

output "admins_access_keys" {
  value = "${join(",", aws_iam_access_key.admins.*.id)}"
}

output "admins_roles" {
  value = "${join(",", aws_iam_role.admin.*.arn)}"
}

output "admins_secret_keys" {
  value = "${join(",", aws_iam_access_key.admins.*.secret)}"
}

output "guests_users" {
  value = "${join(",", aws_iam_access_key.guests.*.user)}"
}

output "guests_access_keys" {
  value = "${join(",", aws_iam_access_key.guests.*.id)}"
}

output "guests_secret_keys" {
  value = "${join(",", aws_iam_access_key.guests.*.secret)}"
}

output "readonly_role" {
  value = "${aws_iam_role.readonly.arn}"
}

output "account_id" {
  value = "${element(split(":",aws_iam_group.admins.arn), 4)}"
}
