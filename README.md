# Nubis - Deployment

This is the repo to use if you want to deploy the Nubis platform into an AWS account.

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

[Credstash](https://github.com/fugue/credstash) is a tool for managing our secrets into DynamoDB and KMS. It's a dependency we are hoping to get rid fo, but for now, you'll need in your $PATH as well.

It's a Python PIP package, so assuming you have a working Python, just do

```shell
pip install "credstash>=1.11.0"
```

## INSTALLING

### Version to install

Determine which version you wish to install, for this tutorial, we'll assume v1.0.2

### clone the deployment repo

```
git clone https://github.com/nubisproject/nubis-deploy
cd nubis-deploy
git checkout v1.0.2
```

### Create the state bucket

This is a manual step at the moment, but we plan on getting rid of it

The current recommendation is to create the bucket in an undeployed-to region, like *eu-west-1*

It must be named **nubis-deploy-#UUID#**, where UUID is a random
string, not strictly speaking a UUID proper.

```
$> aws --profile some-account-name-profile --region eu-west-1 s3 mb s3://nubis-deploy-$(openssl rand -hex 16)
make_bucket: s3://nubis-deploy-479220c3efeaa0dfcba3e0078886c68a/
```

Make sure to note the name of the bucket in question, as it's going to be needed twice, once in the variables file, then at the end of the installation.

### setup the variables file

```
$> cp variables.tf-dist variables.tf
[edit]
```

```
# Name of the account (used for display and resources)
account_name = "some-account-name"

# The name of the profile in your ~/.aws/credentials file
aws_profile  = "project-foo"

# The version of the platform you want
nubis_version = "v1.0.2"

# UUID used for the state bucket
state_uuid = "479220c3efeaa0dfcba3e0078886c68a"

# AWS regions to deploy to (us-east-1 & us-west-2 only in v1.0.2)
aws_regions           = "us-east-1,us-west-2"

# Name of the different environments you want
environments          = "admin,prod,stage"

# The CIDR block for each environment (order must match above)
environments_networks = "10.x.y.0/24,10.x.y.0/24,10.x.y.0/24"

# Usernames of admin IAM users to create
admin_users = "alice,bob,chris"

# Optionnal features

features.consul = 1
features.jumphost = 0
features.fluent = 0
features.ci = 0
features.opsec = 0
features.stack_compat = 0

# Your own IP for debugging
# (curl ifconfig.me)
my_ip = "a.b.c.d/32"

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

### Plan

```
terraform plan
[...]
Plan: 176 to add, 0 to change, 0 to destroy.
```

### Deploy

```
terraform apply
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
  datadog_access_key = AKIAIRTOUEJJF6GKJKOA
  datadog_secret_key = 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
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

```
