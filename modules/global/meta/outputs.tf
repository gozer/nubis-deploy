output "datadog_access_key" {
  value = "${aws_iam_access_key.datadog.id}"
}

output "datadog_secret_key" {
  value = "${aws_iam_access_key.datadog.secret}"
}

output "route53_delegation_set" {
  value = "${aws_route53_delegation_set.meta.id}"
}

output "nameservers" {
  value = "${join(",",aws_route53_delegation_set.meta.name_servers)}"
}
