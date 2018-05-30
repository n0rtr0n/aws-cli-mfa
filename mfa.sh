#!/bin/bash
#
# Originally https://gist.github.com/ogavrisevs/2debdcb96d3002a9cbf2 with modifications by Nathan Norton @nortronthered
#
# Sample for getting temp session token from AWS STS
#
# aws --profile youriamuser sts get-session-token --duration 3600 \
# --serial-number arn:aws:iam::012345678901:mfa/user --token-code 012345
#
# Based on : https://github.com/EvidentSecurity/MFAonCLI/blob/master/aws-temp-token.sh
#

AWS_CLI=`which aws`

if [ $? -ne 0 ]; then
  echo "AWS CLI is not installed; exiting"
  exit 1
else
  echo "Using AWS CLI found at $AWS_CLI"
fi

if [ $# -lt 2 ]; then
  echo "Usage: $0 <AWS_PROFILE> <MFA_TOKEN_CODE> [<AWS_MFA_PROFILE>] [<MFA_DURATION>]"
  echo "Where:"
  echo "   <AWS_PROFILE> = AWS profile with MFA ARN, access key, and access secret"
  echo "   <MFA_TOKEN_CODE> = Code from virtual MFA device"
  echo "   <AWS_MFA_PROFILE> = Optional, specify profile to use generated sts credentials, defaults to 'mfa'"
  echo "   <MFA_DURATION> = Optional, specify the number of seconds for these temporary credentials to last, defaults to 14400 seconds, or 4 hours"
  exit 2
fi


if [ -z $(aws configure get aws_arn_mfa --profile $1) ]; then
  echo "Could not find necessary AWS configuration for profile $1"
  echo "Please enter in the ARN of your MFA device, followed by [ENTER]:"
  read MFA_ARN
  aws configure set aws_arn_mfa $MFA_ARN --profile $1
fi


### first step is to configure that profile with MFA

AWS_SUB_PROFILE=$3
MFA_DURATION=$4
AWS_USER_PROFILE=$1
AWS_MFA_PROFILE=${AWS_SUB_PROFILE:-"mfa"}
ARN_OF_MFA=$(aws configure get aws_arn_mfa --profile $1)
MFA_TOKEN_CODE=$2
DURATION=${MFA_DURATION:-14400} # 4 hours by default

echo "AWS User Profile: $AWS_USER_PROFILE"
echo "MFA ARN: $ARN_OF_MFA"
echo "MFA Token Code: $MFA_TOKEN_CODE"
echo "MFA Proflie: $AWS_MFA_PROFILE"
echo "If this command fails, you may try resetting the MFA ARN by running 'aws configure set aws_arn_mfa <MFA_ARN> --profile $1'"
set -x

#TODO: if access key is not obtained, explain to user

read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< \
$( aws --profile $AWS_USER_PROFILE sts get-session-token \
  --duration $DURATION  \
  --serial-number $ARN_OF_MFA \
  --token-code $MFA_TOKEN_CODE \
  --output text  | awk '{ print $2, $4, $5 }')
echo "AWS_ACCESS_KEY_ID: " $AWS_ACCESS_KEY_ID
echo "AWS_SECRET_ACCESS_KEY: " $AWS_SECRET_ACCESS_KEY
echo "AWS_SESSION_TOKEN: " $AWS_SESSION_TOKEN
if [ -z "$AWS_ACCESS_KEY_ID" ]
then
  exit 1
fi
`aws --profile $AWS_MFA_PROFILE configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"`
`aws --profile $AWS_MFA_PROFILE configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"`
`aws --profile $AWS_MFA_PROFILE configure set aws_session_token "$AWS_SESSION_TOKEN"`
