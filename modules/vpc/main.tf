provider "aws" {
    profile = "${var.aws_profile}"
    region = "${var.aws_region}"
}

resource "aws_key_pair" "nubis" {
  count = "${var.enabled}"
  key_name = "${var.ssh_key_name}"
  public_key = "${var.nubis_ssh_key}"

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
    cidr_block = "${element(split(",",var.environments_networks), count.index)}"
    
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
    vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_security_group" "monitoring" {
  count = "${var.enabled * length(split(",", var.environments))}"
  
  vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"
    
  name = "MonitoringSecurityGroup-${element(split(",",var.environments), count.index)}"
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
  
  vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"
    
  name = "SshSecurityGroup-${element(split(",",var.environments), count.index)}"
  description = "SSH Security Group"
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  } 
  
  ingress {
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
  
  vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"
    
  name = "InternetAccessSecurityGroup-${element(split(",",var.environments), count.index)}"
  description = "Internet Access security group"
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  } 
  
  ingress {
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

  vpc_id = "${element(aws_vpc.nubis.*.id, count.index)}"

  name = "NATSecurityGroup-${element(split(",",var.environments), count.index)}"
  description = "NAT security group"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "tcp"
      security_groups = [
        "${element(aws_security_group.internet_access.*.id, count.index)}",
      ]
  }

  ingress {
      from_port = 0
      to_port = 0
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
  
  template_body = "${file("${path.module}/availability-zones.json")}"
}

# ATM, we just create public subnets for each environment in the first 3 AZs
resource "aws_subnet" "public" {
  count = "${3 * var.enabled * length(split(",", var.environments))}"
  
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
    
    subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.public.*.id, count.index / 3)}"
}

resource "aws_internet_gateway" "nubis" {
    count = "${var.enabled * length(split(",", var.environments))}"
  
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

resource "aws_route_table" "private" {
  count = "${3 * var.enabled * length(split(",", var.environments))}"

  vpc_id = "${element(aws_vpc.nubis.*.id, count.index / 3)}"

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = "${element(aws_network_interface.private-nat.*.id, count.index)}"
  }

  tags {
    Name = "PrivateRoute-${element(split(",",var.environments), count.index/3)}-AZ${(count.index % 3 ) + 1}"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index)}"
  }
}

resource "aws_route_table_association" "private" {
    count = "${3 * var.enabled * length(split(",", var.environments))}"

    subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_network_interface" "private-nat" {
  count = "${3 * var.enabled * length(split(",", var.environments))}"

  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"

  source_dest_check = false

  tags {
    Name = "NatENI-${element(split(",",var.environments), count.index/3)}-AZ${(count.index % 3 ) + 1}"
    ServiceName = "${var.account_name}"
    TechnicalOwner = "${var.technical_owner}"
    Environment = "${element(split(",",var.environments), count.index)}"
  }

  security_groups = [
    "${element(aws_security_group.shared_services.*.id, count.index / 3 )}",
    "${element(aws_security_group.nat.*.id, count.index / 3 )}",
  ]
}

resource "aws_cloudformation_stack" "vpc" {
  count = "${var.enabled * var.enable_vpc_stack }"

  depends_on = [
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
    SSHKeyName = "${aws_key_pair.nubis.key_name}"
    
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

  enabled = "${var.enabled * var.enable_jumphost * var.enable_vpc_stack}"

  environments = "${var.environments}"
  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"

  key_name = "${var.ssh_key_name}"
  nubis_version = "${var.nubis_version}"
  technical_owner = "${var.technical_owner}"

  # Force a dependency on the VPC stack
  service_name = "${var.account_name}"
  #service_name = "${aws_cloudformation_stack.vpc.outputs.ServiceName}"
}

module "fluent-collector" {
  source = "../fluent-collector/multi"

  enabled = "${var.enabled * var.enable_fluent * var.enable_vpc_stack}"

  environments = "${var.environments}"
  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"

  key_name = "${var.ssh_key_name}"
  nubis_version = "${var.nubis_version}"
  technical_owner = "${var.technical_owner}"

  # Force a dependency on the VPC stack
  service_name = "${var.account_name}"
  #service_name = "${aws_cloudformation_stack.vpc.outputs.ServiceName}"

  consul_endpoints = "${module.consul.consul_endpoints}"
}

module "consul" {
  source = "../consul"

  enabled = "${var.enabled * var.enable_consul * var.enable_vpc_stack}"

  environments = "${var.environments}"

  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"
  aws_account_id = "${var.aws_account_id}"

  my_ip = "${var.my_ip}"

  key_name = "${var.ssh_key_name}"
  nubis_version = "${var.nubis_version}"

  consul_secret = "${var.consul_secret}"

  # Force a dependency on the VPC stack
  service_name = "${var.account_name}"
  #service_name = "${aws_cloudformation_stack.vpc.outputs.ServiceName}"
}
