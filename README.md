# aws-cli-mfa

This is a script and optional alias to use MFA with the AWS CLI.

It was heavily inspired by https://github.com/asagage/aws-mfa-script and this gist: https://gist.github.com/ogavrisevs/2debdcb96d3002a9cbf2, with modifications to save profile configuration for the MFA ARN, as well as supply the profile to get a session token and an option profile from which to interact with the AWS API using the generated token.

The profile name should be the name of the profile stanza in your `~/.aws/credentials` file as used by the aws-cli.  This profile should have a policy that provisions the GetSessionToken permission when used with MFA.

The ARN should be the ARN of your MFA device as specified in the AWS console.

The MFA code is the code your MFA device gives you.

# Installation
 1. Install AWS CLI.
 2. Set up MFA device for user profile, and ensure that MFA allows a user the GetSessionToken permission through IAM.  See https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_users-self-manage-mfa-and-creds.html
 3. Use `aws configure --profile <PROFILE_NAME>` to configure your user profile with the credentials you'll need to get a session token.
 4. Give mfa.sh executable permissions, and optionally, symlink it or add it to your alias file

# Usage
At a command prompt run the following command.

```
./mfa.sh <AWS_PROFILE> <MFA_TOKEN_CODE> [<AWS_MFA_PROFILE>] [<MFA_DURATION>]
```

Note that the default temporary profile is `mfa`. The default token duration is 14400 seconds, or 4 hours.  You may optionally add this as the last argument.  Once this profile is created, you can use it like so, replacing the actual region and profile name if necessary:

`aws s3 ls --region us-west-2 --profile mfa`
