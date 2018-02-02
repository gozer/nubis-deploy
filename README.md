# Nubis - Deployment

This is the repo to use if you want to deploy the Nubis platform into an AWS account.

This document covers some layout information and then goes into tooling and finally describes how to deploy an account.

 - [VPC Deployment](#vpc-deployment)
 - [OpSec Deployment](#opsec-deployment)
 - [Prerequisites](#prerequisites)
 - [INSTALLING](#installing)

## VPC Deployment
The VPC is designed to be deployed into a standard Nubis Account. It takes advantage of the standard deployment found [here](https://github.com/nubisproject/nubis-docs/blob/master/DEPLOYMENT_OVERVIEW.md).

The VPC deployment contains a number of other deployments. For example this is where the NAT deployment is defined. Additionally all other account services are deployed into the VPC.

### Deployment Notes
The Nubis VPC deployment consists of:
 - A number of VPC wide security policies
 - A number of lambda functions which will be deprecated soon
 - All of the IP (network) configuration
 - A VPC wide Route53 zone
 - The nubis-nat deployment (for some strange reason)

### Deployment Resources
Details for the deployment including; naming conventions, relationships, permissions, etcetera, can be found in the [Terraform template](modules/vpc/main.tf) used for deployment. Links to specific resources can be found in the following table.

Resource Type|Resource Title|Code Location|
|-------------|--------------|-------------|
|aws_key_pair|nubis|[modules/vpc/main.tf#L6](modules/vpc/main.tf#L6)|
|aws_iam_policy|credstash|[modules/vpc/main.tf#L21](modules/vpc/main.tf#L21)|
|aws_iam_role_policy|lambda|[modules/vpc/main.tf#L64](modules/vpc/main.tf#L64)|
|aws_iam_role|lambda|[modules/vpc/main.tf#L98](modules/vpc/main.tf#L98)|
|aws_cloudformation_stack|dummy-vpc|[modules/vpc/main.tf#L130](modules/vpc/main.tf#L130)|
|aws_lambda_function|UUID|[modules/vpc/main.tf#L201](modules/vpc/main.tf#L201)|
|aws_lambda_function|LookupStackOutputs|[modules/vpc/main.tf#L218](modules/vpc/main.tf#L218)|
|aws_lambda_function|LookupNestedStackOutputs|[modules/vpc/main.tf#L231](modules/vpc/main.tf#L231)|
|aws_vpc|nubis|[modules/vpc/main.tf#L262](modules/vpc/main.tf#L262)|
|aws_main_route_table_association|public|[modules/vpc/main.tf#L285](modules/vpc/main.tf#L285)|
|aws_security_group|monitoring|[modules/vpc/main.tf#L296](modules/vpc/main.tf#L296)|
|aws_security_group|ssh|[modules/vpc/main.tf#L337](modules/vpc/main.tf#L337)|
|aws_security_group|internet_access|[modules/vpc/main.tf#L364](modules/vpc/main.tf#L364)|
|aws_security_group|nat|[modules/vpc/main.tf#L391](modules/vpc/main.tf#L391)|
|aws_security_group|shared_services|[modules/vpc/main.tf#L470](modules/vpc/main.tf#L470)|
|aws_cloudformation_stack|availability_zones|[modules/vpc/main.tf#L531](modules/vpc/main.tf#L531)|
|aws_subnet|public|[modules/vpc/main.tf#L543](modules/vpc/main.tf#L543)|
|aws_subnet|private|[modules/vpc/main.tf#L565](modules/vpc/main.tf#L565)|
|aws_route_table_association|public|[modules/vpc/main.tf#L586](modules/vpc/main.tf#L586)|
|aws_internet_gateway|nubis|[modules/vpc/main.tf#L597](modules/vpc/main.tf#L597)|
|aws_route_table|public|[modules/vpc/main.tf#L614](modules/vpc/main.tf#L614)|
|aws_route|public|[modules/vpc/main.tf#L635](modules/vpc/main.tf#L635)|
|aws_route_table|private|[modules/vpc/main.tf#L674](modules/vpc/main.tf#L674)|
|aws_route_table_association|private|[modules/vpc/main.tf#L696](modules/vpc/main.tf#L696)|
|aws_network_interface|private-nat|[modules/vpc/main.tf#L707](modules/vpc/main.tf#L707)|
|atlas_artifact|nubis-nat|[modules/vpc/main.tf#L735](modules/vpc/main.tf#L735)|
|aws_autoscaling_group|nat|[modules/vpc/main.tf#L757](modules/vpc/main.tf#L757)|
|aws_launch_configuration|nat|[modules/vpc/main.tf#L806](modules/vpc/main.tf#L806)|
|aws_iam_role|nat|[modules/vpc/main.tf#L848](modules/vpc/main.tf#L848)|
|aws_iam_role_policy|nat|[modules/vpc/main.tf#L875](modules/vpc/main.tf#L875)|
|aws_iam_instance_profile|nat|[modules/vpc/main.tf#L887](modules/vpc/main.tf#L887)|
|aws_iam_policy_attachment|credstash|[modules/vpc/main.tf#L898](modules/vpc/main.tf#L898)|
|aws_vpn_gateway|vpn_gateway|[modules/vpc/main.tf#L1172](modules/vpc/main.tf#L1172)|
|aws_customer_gateway|customer_gateway|[modules/vpc/main.tf#L1189](modules/vpc/main.tf#L1189)|
|aws_vpn_connection|main|[modules/vpc/main.tf#L1208](modules/vpc/main.tf#L1208)|
|aws_route|vpn-public|[modules/vpc/main.tf#L1228](modules/vpc/main.tf#L1228)|
|aws_route|vpn-private|[modules/vpc/main.tf#L1243](modules/vpc/main.tf#L1243)|
|aws_route53_zone|proxy|[modules/vpc/main.tf#L1259](modules/vpc/main.tf#L1259)|
|aws_route53_record|proxy|[modules/vpc/main.tf#L1273](modules/vpc/main.tf#L1273)|
|aws_elb|proxy|[modules/vpc/main.tf#L1288](modules/vpc/main.tf#L1288)|
|aws_security_group|proxy|[modules/vpc/main.tf#L1335](modules/vpc/main.tf#L1335)|
|aws_eip|nat|[modules/vpc/main.tf#L1374](modules/vpc/main.tf#L1374)|
|aws_security_group|nubis_version|[modules/vpc/main.tf#L1384](modules/vpc/main.tf#L1384)|
|aws_s3_bucket_object|public_state|[modules/vpc/main.tf#L1405](modules/vpc/main.tf#L1405)|
|aws_iam_role|user_management|[modules/vpc/main.tf#L1449](modules/vpc/main.tf#L1449)|
|aws_iam_role_policy|user_management|[modules/vpc/main.tf#L1482](modules/vpc/main.tf#L1482)|
|aws_lambda_function|user_management|[modules/vpc/main.tf#L1528](modules/vpc/main.tf#L1528)|
|aws_security_group|ldap|[modules/vpc/main.tf#L1560](modules/vpc/main.tf#L1560)|
|aws_lambda_permission|allow_cloudwatch|[modules/vpc/main.tf#L1589](modules/vpc/main.tf#L1589)|
|aws_cloudwatch_event_rule|user_management_event_consul|[modules/vpc/main.tf#L1599](modules/vpc/main.tf#L1599)|
|aws_cloudwatch_event_target|user_management_consul|[modules/vpc/main.tf#L1607](modules/vpc/main.tf#L1607)|
|template_file|user_management_config|[modules/vpc/main.tf#L1632](modules/vpc/main.tf#L1632)|
|null_resource|user_management_unicreds|[modules/vpc/main.tf#L1660](modules/vpc/main.tf#L1660)|

## OpSec Deployment
The OpSec deployment is basically just CloudTrail and a security audit role

This can be deployed independent of a VPC which provides the capability of deploying these required assets even when a VPC is not required.

### Deployment Notes
The Nubis OpSec deployment consists of:
 - An IAM role which allows the InfoSec team god like privileges into all of our accounts
 - An external SNS topic to which we send all of our logs

### Deployment Resources
Details for the deployment including; naming conventions, relationships, permissions, etcetera, can be found in the [Terraform template](modules/opsec/main.tf) used for deployment. Links to specific resources can be found in the following table.

Resource Type|Resource Title|Code Location|
|-------------|--------------|-------------|
|aws_cloudformation_stack|opsec|[modules/opsec/main.tf#L6](modules/opsec/main.tf#L6)|

In this case we simply load a CloudFormation template found [here](modules/global/opsec/audit.json)

Resource Type|Resource Title|Code Location|
|-------------|--------------|-------------|
|AWS::IAM::Role|InfosecSecurityAuditRole|[modules/global/opsec/audit.json#L3](modules/global/opsec/audit.json#L3)|
|AWS::IAM::Role|InfosecIncidentResponseRole|[modules/global/opsec/audit.json#L81](modules/global/opsec/audit.json#L81)|
|Custom::PublishToSNSInfo|PublishToSNSInfo|[modules/global/opsec/audit.json#L174](modules/global/opsec/audit.json#L174)|
|AWS::Lambda::Function|PublishToSNS|[modules/global/opsec/audit.json#L208](modules/global/opsec/audit.json#L208)|
|AWS::IAM::Role|LambdaExecutionRole|[modules/global/opsec/audit.json#L236](modules/global/opsec/audit.json#L236)|

## Prerequisites

We've tried to keep the prerequisites as short as possible, but you'll still need to do some work if this is a first time.

These instructions assume Unix, but should work on any platform with some work.

### AWS Credentials

You need root (*.*) API credentials into the account. They
should have been created by the account provisionning process

 And you'll need them to be proprely configured in your ~/.aws/credentials file as a non-default profile.

```ini
[project-foo]
; state-bucket = state-000XXXX0-0000-00X0-000X-XXXX0X0X0000
aws_access_key_id = AA123AA123AA123AA123AA123AA123
aws_secret_access_key = LFvc+IPeS3UA2M3ND5xf6S7jg327ddeDGutGKc4z4Fc
```
```
$> export AWS_PROFILE=project-foo
```

### Terraform (0.6.14+)

Get it from [Terraform.io](https://www.terraform.io/downloads.html)

It's a simple Go binary bundle, just unzip and drop in your $PATH

Make sure you obtain at least version 0.6.14

### git

Get it from your favorite package manager.

### credstash (1.11.0+)

[Credstash](https://github.com/fugue/credstash) is a tool for managing our secrets into DynamoDB and KMS. It's a dependency we are hoping to get rid of, but for now, you'll need in your $PATH as well.

It's a Python PIP package, so assuming you have a working Python, just do

```shell
pip install "credstash>=1.11.0"
```

## INSTALLING

### Version to install

Determine which version you wish to install, for this tutorial, we'll assume v1.1.0

### clone the deployment repo

```
git clone https://github.com/nubisproject/nubis-deploy
cd nubis-deploy
git checkout v1.1.0
```

### Create the state bucket

This is a manual step at the moment, but we plan on getting rid of it

The current recommendation is to create the bucket in an undeployed-to region, like *eu-west-1*

It must be named **nubis-deploy-#UUID#**, where UUID is a random
string, not strictly speaking a UUID proper.

```
$> aws --profile ${AWS_PROFILE} --region eu-west-1 s3 mb s3://nubis-deploy-$(openssl rand -hex 16)
make_bucket: s3://nubis-deploy-479220c3efeaa0dfcba3e0078886c68a/
```

Make sure to note the name of the bucket in question, as it's going to be needed twice, once in the variables file, then at the end of the installation.

### setup the variables file

```
$> cd accounts/${AWS_PROFILE}
$> cp variables.tf-dist variables.tf
[edit]
```

```
# Name of the account (used for display and resources)
account_name = "some-account-name"

# The version of the platform you want
nubis_version = "v1.1.0"

# UUID used for the state bucket
state_uuid = "479220c3efeaa0dfcba3e0078886c68a"

# AWS regions to deploy to (us-east-1 & us-west-2 only in v1.1.0)
aws_regions           = "us-east-1,us-west-2"

# Name of the different environments you want
environments          = "admin,prod,stage"

# The CIDR block for each environment (order must match above)
environments_networks = "10.x.y.0/24,10.x.y.0/24,10.x.y.0/24"

# Usernames of admin IAM users to create
admin_users = "alice,bob,chris"

# Usernames of guest IAM users to create
guest_users = "jim,jack"

# Optionnal features

features.consul = 1
features.jumphost = 0
features.fluent = 0
features.ci = 0
features.opsec = 0
features.stack_compat = 0

# Consul (required)

# generate a UUID with "uuidgen"
consul.master_acl_token = "00000000-0000-0000-0000-000000000000"
# generate a secret with "openssl rand 16 | base64"
consul.secret = "AAAAAAAAAAAAAAAAAAAAAA=="

# CI (optionnal)

#ci.project = "skel"
#ci.git_repo = "https://github.com/nubisproject/nubis-skel.git"
#ci.github_oauth_client_secret = "AAA"
#ci.github_oauth_client_id = "BBB"

# Datadog
datadog.api_key = "00000000000000000000000000000000"
```

### Download modules
```bash
terraform get --update=true ../../
[...]
Get: git::https://github.com/nubisproject/nubis-consul.git?ref=master (update)
```

### Plan

```
terraform plan ../../
[...]
Plan: 321 to add, 0 to change, 0 to destroy.
```

### Deploy

```
terraform apply ../../
[...]
Apply complete! Resources: 176 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

Outputs:

  account_id         = 330914478726
  admins_access_keys = AKIAJ7XOZKEGA4KWMZRA,AKIAIZPEAYBJERLHM2GA,AKIAJQGMPHEAJGHKVSLA
  admins_secret_keys = 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,ucPG4BgympBFvrDnUrKV8WIktmcfmxCRKo4wbmCv,s3DU3CpboNhwY4bi//Oionf7Kthc4paVJLTqJq0N
  admins_users       = alice,bob,chris
  nameservers        = ns-1349.awsdns-40.org,ns-2000.awsdns-58.co.uk,ns-408.awsdns-51.com,ns-828.awsdns-39.net
```

### Store Remote State

This is the only somewhat manual step needed, and we have plans to get rid of it, but for now, you'll need to do it yourself once, the first time.

#### Use the state bucket

The last step is to tell Terraform about that S3 bucket so it can store its state in it for you and other administrator to make use of

```
terraform remote config
  -backend=s3
  -backend-config="region=eu-west-1"
  -backend-config="bucket=nubis-deploy-479220c3efeaa0dfcba3e0078886c68a"
  -backend-config="key=terraform/nubis-deploy"
[...]
Remote state management enabled
Remote state configured and pulled.
```

### Set up DNS delegation

To create a new domain in inventory:

**NOTE**: You must be on the VPN to connect to inventory.
 * Go to the [domain creation page](https://inventory.mozilla.org/en-US/mozdns/record/create/DOMAIN/) and create the account domain
  * Soa: SOA for allizom.org
  * Name: ${ACCOUNT_NAME}.nubis.allizom.org
 * Go to the [NS delegation page](https://inventory.mozilla.org/en-US/mozdns/record/create/NS/) and add NS records (4 times, once for each AWS NS server)
  * Domain: ${ACCOUNT_NAME}.nubis.allizom.org
  * Server: 1 of 4 AWS NameServers for the HostedZones
  * Views:
        * check private
        * check public
