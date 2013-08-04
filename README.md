provisioner
===========

Handles provisioning and deployment 

## Environment Variables

The following environment variables are required to provision (or deprovision) ASGs.

|Name|Required|Description|Example|
|:---|:-------|:----------|:------|
|AMI_REGION|yes|the region to ami is to be deployed in|us-west-2|
|AMI_ENV|yes|the environment. must be one of - development, staging, production|development|
|AMI_USER|yes|the user account that our software runs under (not root)|tmtt|
|AMI_INSTANCE_TYPE|yes|what instance type|m1.medium|
|AMI_AZ|yes|a comma separate list of Availability Zones to run in|us-west-2a|
|NAME|yes|the name of the service, one word, no spaces|tmtt|
|AMI_ACCESS_KEY_ID|yes|restrictive aws credentials, these will be stored on the instance|
|AMI_SECRET_ACCESS_KEY|yes|restrictive aws credentials, these will be stored on the instance|
|AWS_ACCESS_KEY_ID|yes|aws credentials for managing the instances (not stored on the instance)|
|AWS_SECRET_ACCESS_KEY|yes|aws credentials for managing the instances (not stored on the instance)|

## Conventions

For now, this package uses a lot of conventions to simplify the configuration of other AWS services. 

|Service|Value|Description|Example|
|:------|:----|:----------|:------|
|Elastic Load Balancer (ELB)|#{NAME}-#{AMI_ENV}|provisioner deployer instances as ASGs.  each ASG is mounted behind and ELB.  these ELB have names defined by convention|tmtt-development|
|Security Groups|#{NAME}|Each instance will use a security group that shares the same name as NAME above|tmtt|
|SSH Key Pair|#{NAME}|Each instance will also use a key-pair with the same name as the group|tmtt|
|CI build number|GO_PIPELINE_COUNTER|For now, this tool only supports Thoughtwork's Go.  GO_PIPELINE_COUNTER is the autoincrementing build number env variable used by go.  In future, other buil systems could be supported|
 
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
