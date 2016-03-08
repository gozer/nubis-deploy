provider "aws" {
    profile = "${var.aws_profile}"
    region = "${var.aws_region}"
}

resource "aws_key_pair" "nubis" {
  count = "${var.enabled}"
  key_name = "nubis"
  public_key = "${var.nubis_ssh_key}"

  provisioner "local-exec" {
   command = "sleep 30"
  }
}

resource "tls_private_key" "default" {
  count = "${var.enabled}"
  
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "default" {
    count = "${var.enabled}"
    key_algorithm = "${tls_private_key.default.algorithm}"
    private_key_pem = "${tls_private_key.default.private_key_pem}"

    # Certificate expires after 10 years
    validity_period_hours = 43800

    # Generate a new certificate if Terraform is run within 2 weeks
	# of the certificate's expiration time.
    early_renewal_hours = 168

    # Reasonable set of uses for a server SSL certificate.
    allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth",
    ]

    subject {
        common_name = "*.${var.aws_region}.${var.account_name}.nubis.allizom.org"
        organization = "Mozilla Nubis"
    }
}

resource "aws_iam_server_certificate" "default" {
    count = "${var.enabled}"
    name = "${var.aws_region}.${var.account_name}.nubis.allizom.org"
    certificate_body = "${tls_self_signed_cert.default.cert_pem}"
    private_key = "${tls_private_key.default.private_key_pem}"

    provisioner "local-exec" {
      command = "sleep 30"
    }
}

resource "aws_iam_role_policy" "lambda" {
    count = "${var.enabled}"
    name = "lambda_policy-${var.aws_region}"
    role = "${aws_iam_role.lambda.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
                  "Effect": "Allow",
                  "Action": [
                    "logs:*"
                  ],
                  "Resource": "arn:aws:logs:*:*:*"
                },
                {
                  "Effect": "Allow",
                  "Action": [
                    "cloudformation:DescribeStacks",
                    "cloudformation:DescribeStackResources"
                  ],
                  "Resource": "*"
                }
  ]
}
EOF
}

resource "aws_iam_role" "lambda" {
    count = "${var.enabled}"
    name = "lambda-${var.aws_region}"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Principal": {
                "Service": [
                  "lambda.amazonaws.com"
                ]
              },
              "Action": [
                "sts:AssumeRole"
              ]
            }
          ]
}
EOF
}

resource "aws_lambda_function" "UUID" {
    count = "${var.enabled}"
	function_name = "UUID"
	s3_bucket = "nubis-stacks"
	s3_key    = "${var.nubis_version}/lambda/UUID.zip"
	handler = "index.handler"
	description = "Generate UUIDs for use in Cloudformation stacks"
	memory_size = 128
	runtime = "nodejs"
	timeout = "10"
	role = "${aws_iam_role.lambda.arn}"
}

resource "aws_lambda_function" "LookupStackOutputs" {
    count = "${var.enabled}"
	function_name = "LookupStackOutputs"
	s3_bucket = "nubis-stacks"
	s3_key    = "${var.nubis_version}/lambda/LookupStackOutputs.zip"
	handler = "index.handler"
	description = "Gather outputs from Cloudformation stacks to be used in other Cloudformation stacks"
	memory_size = 128
	runtime = "nodejs"
	timeout = "10"
        role = "${aws_iam_role.lambda.arn}"
}

resource "aws_lambda_function" "LookupNestedStackOutputs" {
    count = "${var.enabled}"
	function_name = "LookupNestedStackOutputs"
	s3_bucket = "nubis-stacks"
	s3_key    = "${var.nubis_version}/lambda/LookupNestedStackOutputs.zip"
	handler = "index.handler"
	description = "Gather outputs from Cloudformation enviroment specific nested stacks to be used in other Cloudformation stacks"
	memory_size = 128
	runtime = "nodejs"
	timeout = "10"
        role = "${aws_iam_role.lambda.arn}"
}

resource "aws_cloudformation_stack" "vpc" {
  count = "${var.enabled}"

  depends_on = [
    "aws_key_pair.nubis",
    "aws_lambda_function.LookupNestedStackOutputs",
    "aws_lambda_function.LookupStackOutputs",
    "aws_lambda_function.UUID",
  ]

  name = "${var.aws_region}-vpc"
  capabilities = [ "CAPABILITY_IAM" ]
  template_body = "${file("${path.module}/../../vpc/vpc-account.template")}"
  
  parameters = {
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    StacksVersion = "${var.nubis_version}"
    SSHKeyName = "${var.ssh_key_name}"
    
    AdminVpcCidr = "${var.admin_network}"
    StageVpcCidr = "${var.stage_network}"
    ProdVpcCidr = "${var.prod_network}"
  
    ProdIPSecTunnelTarget = "${var.prod_ipsec_target}"
    StageIPSecTunnelTarget = "${var.stage_ipsec_target}"
  
    AdminPublicSubnetAZ1Cidr = "${cidrsubnet(var.admin_network, 3, 0)}"
    AdminPublicSubnetAZ2Cidr = "${cidrsubnet(var.admin_network, 3, 1)}"
    AdminPublicSubnetAZ3Cidr = "${cidrsubnet(var.admin_network, 3, 2)}"
  
    AdminPrivateSubnetAZ1Cidr = "${cidrsubnet(var.admin_network, 3, 3)}"
    AdminPrivateSubnetAZ2Cidr = "${cidrsubnet(var.admin_network, 3, 4)}"
    AdminPrivateSubnetAZ3Cidr = "${cidrsubnet(var.admin_network, 3, 5)}"
  
    ProdPublicSubnetAZ1Cidr = "${cidrsubnet(var.prod_network, 3, 0)}"
    ProdPublicSubnetAZ2Cidr = "${cidrsubnet(var.prod_network, 3, 1)}"
    ProdPublicSubnetAZ3Cidr = "${cidrsubnet(var.prod_network, 3, 2)}"
  
    ProdPrivateSubnetAZ1Cidr = "${cidrsubnet(var.prod_network, 3, 3)}"
    ProdPrivateSubnetAZ2Cidr = "${cidrsubnet(var.prod_network, 3, 4)}"
    ProdPrivateSubnetAZ3Cidr = "${cidrsubnet(var.prod_network, 3, 5)}"
  
    StagePublicSubnetAZ1Cidr = "${cidrsubnet(var.stage_network, 3, 0)}"
    StagePublicSubnetAZ2Cidr = "${cidrsubnet(var.stage_network, 3, 1)}"
    StagePublicSubnetAZ3Cidr = "${cidrsubnet(var.stage_network, 3, 2)}"
  
    StagePrivateSubnetAZ1Cidr = "${cidrsubnet(var.stage_network, 3, 3)}"
    StagePrivateSubnetAZ2Cidr = "${cidrsubnet(var.stage_network, 3, 4)}"
    StagePrivateSubnetAZ3Cidr = "${cidrsubnet(var.stage_network, 3, 5)}"
  
  }
}

module "jumphost" {
  source = "../jumphost"

  enabled = "${var.enabled}"

  environments = "${var.environments}"
  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"

  key_name = "${var.ssh_key_name}"
  nubis_version = "${var.nubis_version}"
  service_name = "${var.account_name}"
  technical_owner = "${var.technical_owner}"
}

module "fluent-collector" {
  source = "../fluent-collector"

  enabled = "${var.enabled}"

  environments = "${var.environments}"
  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"

  key_name = "${var.ssh_key_name}"
  nubis_version = "${var.nubis_version}"
  service_name = "${var.account_name}"
  technical_owner = "${var.technical_owner}"
}

#module "consul" {
#  source = "../consul"
#
#  environments = "${var.environments}"
#
#  aws_profile = "${var.aws_profile}"
#  aws_account_id = "${var.aws_account_id}"
#
#  key_name = "${var.ssh_key_name}"
#  nubis_version = "${var.nubis_version}"
#  service_name = "${var.account_name}"
#
#  consul_secret = "${var.consul_secret}"
#  credstash_key = "${aws_cloudformation_stack.vpc.outputs.CredstashKeyId}"
#}
