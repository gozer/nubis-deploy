# nubis-deploy - Credentials

Managing AWS credentails securely is a complex problem with many possible solutions. This document highlights the solution the Nubis project is advocating. The main purpose being to use short-lived temporary API credentials coupled with strong MFA authentication.

## aws-vault

[aws-vault](https://github.com/99designs/aws-vault) is a tool to securely manage AWS API credentials, and is the tool we strongly recommend using when
deploying Nubis accounts.

# Initial Account deployment

Initially, when creating an account for the first time, all that's available at the time are a set of API credentials for a *:* account, usually called *nubis-bootstrap*, manually created at account creation time.

To deploy Nubis the first time around, we have to use these credentials before new ones are created by the automation. We place these credentials into aws-vault like this:

```bash
 $> aws-vault add account-name
Enter Access Key ID: XXXX
Enter Secret Access Key: XXXX
Added credentials to profile "account-name" in vault
```

At that point, aws-vault now stores the credentials for that account securely, in an encrypted store.

We can now deploy the account by using aws-vault as a command invocation wrapper like this:

```bash
$> aws-vault exec account-name -- terraform apply ../..
```

# Securing the generated credentials

Once an account has been created, there will be new credentials created, per-user. We will need to get rid of the original credentials completely, and switch over to using these instead, and enable MFA for them in aws-vault.

## Removing the originial credentials

This should have been the only time we used these credentials, and we should never have to use them again, so it's safe to just forget about them from now on.

```bash
$> aws-vault rm account-name
```

## Adding the per-user credentials

When we ran Terraform, the outputs gave us the list of admin users credentials like this:

```
account_id = 12345678890
admins_access_keys = AAAABBBBCCCCDDDDEEEEFFFFF,0000111122223333444455556666
admins_roles = arn:aws:iam::12345678890:role/nubis/admin/jim,arn:aws:iam::12345678890:role/nubis/admin/bob
admins_secret_keys = AAA000BBB111CCC222,DDD333EEE444FFF555
admins_users = jim,bob
[...]
readonly_role = arn:aws:iam::12345678890:role/nubis/readonly
```

They are ordered in the same order for all values, so in this case, the  credentials for user 'jim' are 'AAAABBBBCCCCDDDDEEEEFFFFF'/'AAA000BBB111CCC222'

We then add these credentials to aws-vault itself.

```bash
$> aws-vault add account-name
Enter Access Key ID: AAAABBBBCCCCDDDDEEEEFFFFF
Enter Secret Access Key: AAA000BBB111CCC222
Added credentials to profile "account-name" in vault
```

## Setting up a virtual MFA token

These credentials, however, are severely restricted and have virtually no permissions enabled without MFA.

### Creating the virtual MFA device

First we must create the MFA device with :

```bash
$> aws-vault exec -n account-name -- aws iam create-virtual-mfa-device --virtual-mfa-device-name jim --outfile jim.png --bootstrap-method QRCodePNG
{
    "VirtualMFADevice": {
        "SerialNumber": "arn:aws:iam::1234567890:mfa/jim"
    }
}
```

This will produce jim.png, a QRCode that can be scanned into Google Authenticator or other similar TOTP applications.

### Binding the virtual MFA device to the user

Once we have setup the MFA device, we need to associate it with our user

```bash
aws-vault exec -n account-name -- aws iam enable-mfa-device --user-name jim --serial-number arn:aws:iam::1234567890:mfa/jim --authentication-code-1 123456  --authentication-code-2 345678
```

Note that the setup requires 2 consecutive MFA authentication codes

Also note the use of the **-n** flag to aws-vault exec, this is required to
directly use the credentials, and bypass the STS temporary credentials usage, which are not supported for the type of IAM operation we need to be making. It's the only time it should be needed.

At this point, our IAM user has a MFA token associated with it.

### Configuring aws-vault to use MFA and request STS sessions

Now, all that's left is telling aws-vault about our MFA device and the IAM roles we'll wish to use when using our account.

This is achieved by editing *~/.aws/config*

```ini
[profile account-name]

[profile account-name-admin]
source_profile = account-name
role_arn = arn:aws:iam::1234567890:role/nubis/admin/jim
mfa_serial = arn:aws:iam::1234567890:mfa/jim

[profile account-name-ro]
source_profile = account-name
role_arn = arn:aws:iam::1234567890:role/nubis/readonly
mfa_serial = arn:aws:iam::1234567890:mfa/jim
```

The values for the role_arn values are also coming from Terraform outputs, just cut and paste them in.

The value for *mfa_serial* was printed when we created the virtual MFA device

## Using aws-vault

At this point, we are fully setup to use aws-vault to access the account.

We created to profiles, one account-name-ro has read-only privileges only, and should generally be used when inspecting resources, since it doesn't have the ability to modify any resources.

The other profile, account-name-admin has full admin privileges and should be used carefully, when making changes to the account, typically, via terraform invocations.

### aws-vault exec

aws-vault exec is the most common way to use aws-vault, just specify the command you'd like to execute after the -- and everything should just work.

It will ask for the MFA authentication code from time to time, but aws-vault caches sessions for a while, so it won't be required every single time.

```bash
$> aws-vault exec account-name-ro -- aws ec2 describe-regions
Enter token for arn:aws:iam::1234567890:mfa/jim: 012345
[...]
```

```bash
$> ws-vault exec account-name-ro -- terraform plan
[...]
```

### aws-vault login

Another convenient feature of aws-vault makes logging into the AWS Web Console very simple.

If you want to use the Web Console, just do:

```bash
$> aws-vault login account-name-ro
or
$> aws-vault login account-name-admin
```

And it will launch a browser window logged into the Console for an hour, no passwords required. It will use the specified role, so you'll get either a read-only Console, or a full admin one (not generally recommended).
