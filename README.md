provisioner
===========

Provisioner is a highly opinionated tool for handling the deployment of services.  The following assumptions are made about the environment:

* pre-baked into an AMI
* AMI already include S3 security credentials in /etc/aws.credentials
* the software to be deployed will be stored (a) in an s3 bucket and (b) in a pre-defined format (see below) 

## Environment Variables

The following environment variables are required to provision (or deprovision) ASGs.

#### Required Environment Variables

|Name|Required|Description|Example|
|:---|:-------|:----------|:------|
|APP_NAME|yes|the name of the service, one word, no spaces|tmtt|
|APP_ENV|yes|the environment. must be one of - development, staging, production|development|
|AWS_ACCESS_KEY_ID|yes|aws credentials for managing the instances (not stored on the instance)|
|AWS_SECRET_ACCESS_KEY|yes|aws credentials for managing the instances (not stored on the instance)|

#### Optional Environment Variables

|Name|Required|Description|Example|
|:---|:-------|:----------|:------|
|AMI_AZ|no|a comma separate list of Availability Zones to run in|us-west-2a|
|AMI_ELB|no|the name of the elb to create the asg behind.  defaults to ${APP_NAME}-${APP_ENV}|tmtt-development|
|AMI_INSTANCE_TYPE|no|what instance type. defaults to m1.small|m1.small|
|AMI_KEY_PAIR|no|the aws ssh key pair to use.  defaults to ${APP_NAME}|
|AMI_REGION|no|the region to ami is to be deployed in|us-west-2|
|AMI_SECURITY_GROUP|no|the aws security the instances should belong to.  defaults to ${APP_NAME}|
 
## Input

The provisioner requires a json configuration file, baseami.json, that specifies the ami to be deployed:

```
{
"ami": "ami-3db92b0d",
"build": "21"
}
```

The key value here is the AMI which will be used as the base to spin up.

## Boot Logic

1. 
