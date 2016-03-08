# environments

module "consul-admin" {
  #source = "github.com/nubisproject/nubis-consul//nubis/terraform?ref=${var.nubis_version}"
  source = "/home/gozer/opt/src/mozilla.org/gozer/nubis/consul/nubis/terraform"

  environment = "admin"

  aws_profile = "${var.aws_profile}"
  aws_account_id = "${var.aws_account_id}"

  key_name = "${var.key_name}"
  nubis_version = "${var.nubis_version}"
  service_name = "${var.service_name}"

  consul_secret = "${var.consul_secret}"
  credstash_key = "${var.credstash_key}"
}
