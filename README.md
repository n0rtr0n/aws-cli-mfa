# aws-cli-mfa

This is a script and optional alias to use MFA with the AWS CLI.

It was heavily inspired by https://github.com/asagage/aws-mfa-script and this gist: https://gist.github.com/ogavrisevs/2debdcb96d3002a9cbf2, with modifications to save profile configuration for the MFA ARN, as well as supply the profile to get a session token and an option profile from which to interact with the AWS API using the generated token.

The profile name should be the name of the profile stanza in your `~/.aws/credentials` file as used by the aws-cli.  This profile should have a policy that provisions the GetSessionToken permission when used with MFA.

The ARN should be the ARN of your MFA device as specified in the AWS console.

The MFA code is the code your MFA device gives you.

# Installation
 1. Install AWS CLI.
 2. Set up MFA device for user profile, and ensure that MFA allows a user the GetSessionToken permission through IAM.  See https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_users-self-manage-mfa-and-creds.html
 2. Use `aws configure --profile <PROFILE_NAME>` to configure your user profile with the credentials you'll need to get a session token.
 3. Give mfa.sh executable permissions, and optionally, symlink it or add it to your alias file

# Usage
At a command prompt run the following command.

```
./mfa.sh <AWS_PROFILE> <MFA_TOKEN_CODE> [<AWS_MFA_PROFILE>]
```

## Alias Note:
Scripts run in a subprocess of the calling shell.  This means that
if you attempt to set the env vars in the script, they will only persist
inside that subprocess.  The `alias.sh` script sets an alias function to source the env vars into your main shell whenever you
run the `mfa` command.
