provider "aws" {
    profile = "${var.aws_profile}"
    region = "${var.aws_region}"
}

resource "aws_key_pair" "nubis" {
  count = "${var.enabled}"
  lifecycle { create_before_destroy = true }
  key_name = "${var.ssh_key_name}"
  public_key = "${var.nubis_ssh_key}"

  provisioner "local-exec" {
   command = "sleep 30"
  }
}

resource "aws_iam_policy" "credstash" {
  count = "${var.enabled * length(split(",", var.environments))}"

  name = "credstash-${element(split(",",var.environments), count.index)}-${var.aws_region}"
  description = "Policy for reading the Credstash DynamoDB"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${module.meta.CredstashKeyID}",
      "Condition": {
                "StringEquals": {
                  "kms:EncryptionContext:environment": "${element(split(",",var.environments), count.index)}",
                  "kms:EncryptionContext:region": "${var.aws_region}",
                  "kms:EncryptionContext:service": "nubis"
                }
            }
    },
                {
              "Effect": "Allow",
              "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:ListTables",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:DescribeReservedCapacity",
                "dynamodb:DescribeReservedCapacityOfferings"
              ],
              "Resource": "${module.meta.CredstashDynamoDB}"
            }
  ]
}
POLICY

}

resource "aws_iam_role_policy" "lambda" {
    count = "${var.enabled}"
    lifecycle { create_before_destroy = true }
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
lifecycle { create_before_destroy = true }

  name = "lambda-${var.aws_region}"

  provisioner "local-exec" {
   command = "sleep 30"
  }

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
    lifecycle { create_before_destroy = true }

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

module "meta" {
  source = "../meta"

  enabled = "${var.enabled}"

  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"

  nubis_version = "${var.nubis_version}"
  nubis_domain = "${var.nubis_domain}"
  technical_owner = "${var.technical_owner}"

  service_name = "${var.account_name}"
}

resource "aws_vpc" "nubis" {
    count = "${var.enabled * length(split(",", var.environments))}"
lifecycle { create_before_destroy = true }
    
    # index(split(",",var.aws_regions), var.aws_region)
    # is the index of the current region, starting at 0
    # So the correct grouping of subnets is count.index + ( 3 * region-index )
    cidr_block = "${element(split(",",var.environments_networks), count.index + (3 * index(split(",",var.aws_regions), var.aws_region)) )}"
    
    enable_dns_support = true
    enable_dns_hostnames = true
    
    tags {
      Name = "${var.aws_region}-${element(split(",",var.environments), count.index)}-vpc"
      ServiceName = "${var.account_name}"
      TechnicalOwner = "${var.technical_owner}"
      Environment = "${element(split(",",var.environments), count.index)}"
    }
}

resource "aws_main_route_table_association" "public" {
    count = "${var.enabled * length(split(",", var.environments))}"
    lifecycle { create_before_destroy = true }
    vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_security_group" "monitoring" {
  count = "${var.enabled * length(split(",", var.environments))}"
  
  lifecycle { create_before_destroy = true }
  
  vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"
    
  name_prefix = "MonitoringSecurityGroup-${element(split(",",var.environments), count.index)}-"
  description = "Securiry group for monitoring hosts"
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  } 
  
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }    

  tags {
    Name = "MonitoringSecurityGroup"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index)}"
  } 
}

resource "aws_security_group" "ssh" {
  count = "${var.enabled * length(split(",", var.environments))}"
  
  lifecycle { create_before_destroy = true }
  
  vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"
    
  name_prefix = "SshSecurityGroup-${element(split(",",var.environments), count.index)}-"
  description = "SSH Security Group"
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  } 

  tags {
    Name = "SshSecurityGroup"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index)}"
  } 
}

resource "aws_security_group" "internet_access" {
  count = "${var.enabled * length(split(",", var.environments))}"
  
  lifecycle { create_before_destroy = true }
  
  vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"
    
  name_prefix = "InternetAccessSecurityGroup-${element(split(",",var.environments), count.index)}-"
  description = "Internet Access security group"

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "InternetAccessSecurityGroup"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index)}"
  } 

}

resource "aws_security_group" "nat" {
  count = "${var.enabled * length(split(",", var.environments))}"
  
  lifecycle { create_before_destroy = true }

  vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"

  name_prefix = "NATSecurityGroup-${element(split(",",var.environments), count.index)}"
  description = "NAT security group"

  ingress {
      from_port = 0
      to_port = 65535
      protocol = "tcp"
      security_groups = [
        "${element(aws_security_group.internet_access.*.id, count.index)}",
      ]
  }

  ingress {
      from_port = 0
      to_port = 65535
      protocol = "udp"
      security_groups = [
        "${element(aws_security_group.internet_access.*.id, count.index)}",
      ]
  }

  ingress {
      from_port = 8
      to_port = -1
      protocol = "icmp"
      security_groups = [
        "${element(aws_security_group.internet_access.*.id, count.index)}",
      ]
  }
  
  #XXX
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [
        "${var.my_ip}"
      ]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "NATSecurityGroup-${element(split(",",var.environments), count.index)}"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index)}"
  }
}

resource "aws_security_group" "shared_services" {
  count = "${var.enabled * length(split(",", var.environments))}"
  lifecycle { create_before_destroy = true }
  vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"
    
  name = "SharedServicesSecurityGroup-${element(split(",",var.environments), count.index)}"
  description = "The security group for all instances."

  ingress {
      from_port = 8
      to_port = -1
      protocol = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Consul TCP
  ingress {
    self = true
    from_port = 8300
    to_port = 8302
    protocol = "tcp"
  }
  
  # Consul UDP
  ingress {
    self = true
    from_port = 8300
    to_port = 8302
    protocol = "udp"
  }
  
  # Poll Monitoring
  ingress {
    security_groups = [
      "${element(aws_security_group.monitoring.*.id, count.index)}"
    ]
    from_port = 9100
    to_port = 9110
    protocol = "tcp"
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
    
  tags {
    Name = "SharedServicesSecurityGroup"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index)}"
  }
}

resource "aws_cloudformation_stack" "availability_zones" {
  count = "${var.enabled}"
  name = "availability-zones"
  lifecycle { create_before_destroy = true }
  template_body = "${file("${path.module}/availability-zones.json")}"
}

# ATM, we just create public subnets for each environment in the first 3 AZs
resource "aws_subnet" "public" {
  count = "${3 * var.enabled * length(split(",", var.environments))}"
  lifecycle { create_before_destroy = true } 
  vpc_id = "${element(aws_vpc.nubis.*.id, count.index / 3)}"
    
  availability_zone = "${element(split(",",aws_cloudformation_stack.availability_zones.outputs.AvailabilityZones), count.index % 3 )}"
    
  cidr_block = "${cidrsubnet(element(aws_vpc.nubis.*.cidr_block, count.index / 3), 3, count.index % 3 )}"

  tags {
    Name = "PublicSubnet-${element(split(",",var.environments), count.index / 3)}-AZ${(count.index % 3 ) + 1}"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index / 3)}"
  }
}

# ATM, we just create private subnets for each environment in the first 3 AZs
resource "aws_subnet" "private" {
  count = "${3 * var.enabled * length(split(",", var.environments))}"
  
  lifecycle { create_before_destroy = true }

  vpc_id = "${element(aws_vpc.nubis.*.id, count.index / 3)}"

  availability_zone = "${element(split(",",aws_cloudformation_stack.availability_zones.outputs.AvailabilityZones), count.index % 3 )}"

  cidr_block = "${cidrsubnet(element(aws_vpc.nubis.*.cidr_block, count.index / 3), 3, (count.index % 3) + 3 )}"

  tags {
    Name = "PrivateSubnet-${element(split(",",var.environments), count.index / 3)}-AZ${(count.index % 3 ) + 1}"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index / 3)}"
  }
}

resource "aws_route_table_association" "public" {
    count = "${3 * var.enabled * length(split(",", var.environments))}"
    lifecycle { create_before_destroy = true }   
    subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.public.*.id, count.index / 3)}"
}

resource "aws_internet_gateway" "nubis" {
    count = "${var.enabled * length(split(",", var.environments))}"

  lifecycle { create_before_destroy = true }

    vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"

  tags {
    Name = "InternetGateway-${element(split(",",var.environments), count.index)}"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index)}"
  }
}

resource "aws_route_table" "public" {
    count = "${var.enabled * length(split(",", var.environments))}"

    lifecycle { create_before_destroy = true }

    vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${element(aws_internet_gateway.nubis.*.id, count.index)}"
    }

  tags {
    Name = "PublicRoute-${element(split(",",var.environments), count.index)}"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index)}"
  }
}

resource "aws_route" "private" {
    count = "${3 * var.enabled * length(split(",", var.environments))}"
    lifecycle { create_before_destroy = true }

    route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

    destination_cidr_block = "0.0.0.0/0"
    network_interface_id = "${element(aws_network_interface.private-nat.*.id, count.index)}"
}

resource "aws_route_table" "private" {
  count = "${3 * var.enabled * length(split(",", var.environments))}"

  lifecycle { create_before_destroy = true }
  
  vpc_id = "${element(aws_vpc.nubis.*.id, count.index / 3)}"

  tags {
    Name = "PrivateRoute-${element(split(",",var.environments), count.index/3)}-AZ${(count.index % 3 ) + 1}"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index)}"
  }
}

resource "aws_route_table_association" "private" {
  count = "${3 * var.enabled * length(split(",", var.environments))}"

  lifecycle { create_before_destroy = true }

  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_network_interface" "private-nat" {
  count = "${3 * var.enabled * length(split(",", var.environments))}"

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ "attachment" ]
  }

  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"

  source_dest_check = false

  tags {
    Name = "NatENI-${element(split(",",var.environments), count.index/3)}-AZ${(count.index % 3 ) + 1}"
    # Found by the nat instance doing --filter Name=tag-value,Values=nubis-nat-eni-stage Name=availability-zone,Values=$MY_AZ
    Autodiscover = "nubis-nat-eni-${element(split(",",var.environments), count.index/3)}"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index)}"
  }

  security_groups = [
    "${element(aws_security_group.shared_services.*.id, count.index / 3 )}",
    "${element(aws_security_group.nat.*.id, count.index / 3 )}",
  ]
}

resource "atlas_artifact" "nubis-nat" {
  count = "${var.enabled}"
  lifecycle { create_before_destroy = true }
  name = "nubisproject/nubis-nat"
  type = "amazon.image"

  metadata {
    project_version = "${var.nubis_version}"
  }
}

resource "aws_autoscaling_group" "nat" {
  count = "${3 * var.enabled * length(split(",", var.environments))}"

  lifecycle { create_before_destroy = true }
  
  name = "nubis-nat-${element(split(",",var.environments), count.index/3)}-AZ${(count.index % 3 ) + 1} (${element(aws_launch_configuration.nat.*.name, count.index/3 )})"

  availability_zones = [
    "${element(split(",",aws_cloudformation_stack.availability_zones.outputs.AvailabilityZones), count.index % 3 )}"
  ]

  # Subnets
  vpc_zone_identifier = [
    "${element(aws_subnet.public.*.id, count.index)}"
  ]

  max_size = 2
  min_size = 1
  desired_capacity = 1
  launch_configuration = "${element(aws_launch_configuration.nat.*.name, count.index/3 )}"
  
  tag {
    key = "Name"
    value = "nubis-nat-${element(split(",",var.environments), count.index/3)}-AZ${(count.index % 3 ) + 1}"
    propagate_at_launch = true
  }
  tag {
    key = "ServiceName"
    value = "${var.account_name}"
    propagate_at_launch = true
  }
  tag {
    key = "TechnicalOwner"
    value = "${var.technical_owner}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${element(split(",",var.environments), count.index)}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "nat" {
  count = "${var.enabled * length(split(",", var.environments))}"
  
  lifecycle { create_before_destroy = true }
    
  name_prefix = "nubis-nat-${element(split(",",var.environments), count.index)}-"
    
  # Somewhat nasty, since Atlas doesn't have an elegant way to access the id for a region
  # the id is "region:ami,region:ami,region:ami"
  # so we split it all and find the index of the region
  # add on, and pick that element
  image_id = "${ element(split(",",replace(atlas_artifact.nubis-nat.id,":",",")) ,1 + index(split(",",replace(atlas_artifact.nubis-nat.id,":",",")), var.aws_region)) }"
  
  instance_type = "t2.nano"
  associate_public_ip_address  = true
  key_name = "${var.ssh_key_name}"
  
  iam_instance_profile = "${element(aws_iam_instance_profile.nat.*.id, count.index)}"
 
  security_groups = [
    "${element(aws_security_group.internet_access.*.id, count.index)}",
    "${element(aws_security_group.nat.*.id, count.index)}",
    "${element(aws_security_group.ssh.*.id, count.index)}",
    "${element(aws_security_group.shared_services.*.id, count.index)}",
  ]
  
  user_data = <<USER_DATA
NUBIS_PROJECT='nubis-nat-${element(split(",",var.environments), count.index)}'
NUBIS_ENVIRONMENT='${element(split(",",var.environments), count.index)}'
NUBIS_DOMAIN='${var.nubis_domain}'
NUBIS_MIGRATE='1'
NUBIS_ACCOUNT='${var.account_name}'
NUBIS_PURPOSE='Nat Instance'
USER_DATA
}

# XXX: This could be a global
resource "aws_iam_role" "nat" {
    count = "${var.enabled * length(split(",", var.environments))}"
    lifecycle { create_before_destroy = true }

    path = "/nubis/"
    name = "nubis-nat-role-${element(split(",",var.environments), count.index)}-${var.aws_region}"
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "nat" {
    count = "${var.enabled * length(split(",", var.environments))}"
    lifecycle { create_before_destroy = true }

    name = "nubis-nat-policy-${element(split(",",var.environments), count.index)}-${var.aws_region}"
    role = "${element(aws_iam_role.nat.*.id, count.index)}"
    policy = "${file("${path.module}/nat-policy.json")}"
}

resource "aws_iam_instance_profile" "nat" {
    count = "${var.enabled * length(split(",", var.environments))}"
    lifecycle { create_before_destroy = true }

    name = "nubis-nat-profile-${element(split(",",var.environments), count.index)}-${var.aws_region}"
    roles = ["${element(aws_iam_role.nat.*.name, count.index)}"]
}

resource "aws_iam_policy_attachment" "credstash" {
    count = "${var.enabled * length(split(",", var.environments))}"

    name = "credstash-${var.aws_region}"
    
    roles = [
      #XXX: concat and compact should work here, but element() isn't a list, so BUG
      "${split(",",replace(replace(concat(element(split(",",module.jumphost.iam_roles), count.index), ",", element(split(",",module.consul.iam_roles), count.index), ",", element(split(",",module.fluent-collector.iam_roles), count.index), ",", element(aws_iam_role.nat.*.id, count.index) ), "/(,+)/",","),"/(^,+|,+$)/", ""))}",
    ]

    policy_arn = "${element(aws_iam_policy.credstash.*.arn, count.index)}"
}


module "jumphost" {
  source = "../jumphost"

  enabled = "${var.enabled * var.enable_jumphost}"

  environments = "${var.environments}"
  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"

  key_name = "${var.ssh_key_name}"
  nubis_version = "${var.nubis_version}"
  technical_owner = "${var.technical_owner}"

  zone_id = "${module.meta.HostedZoneId}"

  vpc_ids = "${join(",", aws_vpc.nubis.*.id)}"
  public_subnet_ids = "${join(",", aws_subnet.public.*.id)}"

  internet_access_security_groups = "${join(",",aws_security_group.internet_access.*.id)}"
  shared_services_security_groups = "${join(",",aws_security_group.shared_services.*.id)}"
  ssh_security_groups             = "${join(",",aws_security_group.ssh.*.id)}"

  nubis_domain = "${var.nubis_domain}"

  service_name = "${var.account_name}"
}

module "fluent-collector" {
  source = "../fluent-collector/multi"

  enabled = "${var.enabled * var.enable_fluent}"

  environments = "${var.environments}"
  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"

  lambda_uuid_arn = "${aws_lambda_function.UUID.arn}"

  key_name = "${var.ssh_key_name}"
  nubis_version = "${var.nubis_version}"
  technical_owner = "${var.technical_owner}"

  zone_id = "${module.meta.HostedZoneId}"

  vpc_ids = "${join(",", aws_vpc.nubis.*.id)}"
  subnet_ids = "${join(",", aws_subnet.private.*.id)}"

  internet_access_security_groups = "${join(",",aws_security_group.internet_access.*.id)}"
  shared_services_security_groups = "${join(",",aws_security_group.shared_services.*.id)}"
  ssh_security_groups             = "${join(",",aws_security_group.ssh.*.id)}"
#  credstash_policies              = "${join(",",aws_iam_policy.credstash.*.arn)}"

  nubis_domain = "${var.nubis_domain}"
#  credstash_key = "${module.meta.CredstashKeyID}"
#  credstash_dynamodb_table = "${module.meta.CredstashDynamoDB}"

  service_name = "${var.account_name}"
}

module "consul" {
  source = "../consul"

  enabled = "${var.enabled * var.enable_consul}"

  environments = "${var.environments}"

  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"
  aws_account_id = "${var.aws_account_id}"

  my_ip = "${var.my_ip}"
  lambda_uuid_arn = "${aws_lambda_function.UUID.arn}"

  key_name = "${var.ssh_key_name}"
  nubis_version = "${var.nubis_version}"
  vpc_ids = "${join(",", aws_vpc.nubis.*.id)}"
  public_subnet_ids = "${join(",", aws_subnet.public.*.id)}"
  private_subnet_ids = "${join(",", aws_subnet.private.*.id)}"

  internet_access_security_groups = "${join(",",aws_security_group.internet_access.*.id)}"
  shared_services_security_groups = "${join(",",aws_security_group.shared_services.*.id)}"
  ssh_security_groups             = "${join(",",aws_security_group.ssh.*.id)}"

  consul_secret = "${var.consul_secret}"
  consul_master_acl_token = "${var.consul_master_acl_token}"
  credstash_key = "${module.meta.CredstashKeyID}"
  credstash_dynamodb_table = "${module.meta.CredstashDynamoDB}"
  zone_id = "${module.meta.HostedZoneId}"

  service_name = "${var.account_name}"

  datadog_api_key = "${var.datadog_api_key}"
}

module "opsec" {
  source = "../opsec"

  enabled = "${var.enabled * var.enable_opsec}"

  environments = "${var.environments}"
  nubis_version = "${var.nubis_version}"

  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"

}
