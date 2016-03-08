variable aws_profile {}
variable aws_region {}

variable key_name {}
variable nubis_version {}
variable service_name {}

variable environments {}

variable enabled {}

variable technical_owner {}

# Work around a limitation in TF, keep it an ordered list of
# regions indexed at 0, must match what is being built as an
# Artifact. WARNING: brittleness!
variable "atlas_region_map" {
  default = {
    "us-east-1" = 0
    "us-west-2" = 1
  }
}
