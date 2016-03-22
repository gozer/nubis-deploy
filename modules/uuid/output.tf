output "uuids" {
  value = "${join(",",aws_cloudformation_stack.uuid.*.outputs.UUID)}"
}

