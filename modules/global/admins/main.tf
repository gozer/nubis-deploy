provider "aws" {
    profile = "${var.aws_profile}"
    region = "${var.aws_region}"
}

output "account_name" {
    value = "${var.account_name}"
}

output "technical_owner" {
    value = "${var.technical_owner}"
}

output "ssh_key_name" {
    value = "${var.ssh_key_name}"
}

resource "aws_iam_user" "admin" {
  count = "${length(split(",",var.admin_users))}"
  path = "/nubis/admin/"
  name = "${element(split(",",var.admin_users), count.index)}"
}

resource "aws_iam_access_key" "admins" {
  count = "${length(split(",",var.admin_users))}"
  user = "${element(aws_iam_user.admin.*.name, count.index)}"
}

resource "aws_iam_group" "admins" {
    name = "Administrators"
    path = "/nubis/admin/"
}

resource "aws_iam_group_membership" "admins" {
    name = "admins-group-membership"

    users = [
        "${aws_iam_user.admin.*.name}"
    ]

    group = "${aws_iam_group.admins.name}"
}
