output "iam_roles" {
  value = "${join(",",aws_iam_role.fluent-collector.*.id)}"
}

output "logging_buckets" {
  value = "${join(",",aws_s3_bucket.elb.*.id)}"
}
