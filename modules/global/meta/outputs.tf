output "datadog_access_key" {
  value = "${aws_iam_access_key.datadog.id}"
}

output "datadog_secret_key" {
  value = "${aws_iam_access_key.datadog.secret}"
}
