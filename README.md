CloudFormation ec2-hosted kubernetes Infrastructure
==============================

Architecture
==============================
![alt text](docs/diagrams/Sample-Architecture-Full.drawio.svg)

Deployment
==============================

This document provides guidance deploying the EC2-hosted, kubernetes Infrastructure.

- [CloudFormation ec2-hosted kubernetes Infrastructure](#cloudformation-ec2-hosted-kubernetes-infrastructure)
- [Architecture](#architecture)
- [Deployment](#deployment)
  - [IMPORTANT](#important)
  - [Prerequisites](#prerequisites)
  - [Variables](#variables)
    - [`deploymentNumber` options:](#deploymentnumber-options)
    - [`deploymentEnvironment` options:](#deploymentenvironment-options)
    - [`sampleEnvironment` options:](#sampleenvironment-options)
  - [Deploy the Central Services Stack](#deploy-the-central-services-stack)
  - [Deploy a Deployment Stack](#deploy-a-deployment-stack)
- [Modification](#modification)
  - [Update a Stack](#update-a-stack)
- [Deletion](#deletion)
  - [Deleting the Central Services Stack](#deleting-the-central-services-stack)
  - [Deleting a Deployment Stack](#deleting-a-deployment-stack)
- [Appendix](#appendix)
  - [Auxiliary Templates](#auxiliary-templates)
    - [sampleAwsExternalEdgeIntegration.yaml](#sampleawsexternaledgeintegrationyaml)
      - [Preqeuisites](#preqeuisites)
      - [Stack Deployment](#stack-deployment)
      - [Post Deployment](#post-deployment)





IMPORTANT
---------------------------------------

Before running the playbooks, ensure you've start a disconnected session by running the  `tmux` command before starting the deployment. This ensures the playbook doesn't break due to a disconnected session. For more details on leveraging screen, see https://linux.die.net/man/1/tmux.


Prerequisites
---------------------------------------
The following packages must be installed prior to the playbooks being ran:
- Python3.12
- Python-Pip (for Python3.12)
- Ansible (installed via PIP)
- AWS CLI
- Red Hat Enterprise Linux Subscription

AWS Credentials must also be setup. It is recommended to use AWS CONFIGURE SSO to do so.

```bash
$ aws configure sso
```

Ensure the profile is set to **default** or the playbooks will not work.

Variables
--------------------------------------

### `deploymentNumber` options:

- 0
- 1
- 2
- 3
- 4
- 5
- 6
- 7
- 8

*Subject to grow as more infrastructure is provisioned*
### `deploymentEnvironment` options:

- prod
- test

### `sampleEnvironment` options:

- dev
- upprod
- uptest



Deploy the Central Services Stack
--------------------------------------

**IMPORTANT**
For a new AWS Account, this playbook 'must' be ran.

```bash
$ ansible-playbook playbooks/deploy-stack.yml
```


Deploy a Deployment Stack
--------------------------------------

To create a deployment stack, run the following playbook:

```bash
$ ansible-playbook playbooks/deploy-stack.yml -e "deployment_number=$deploymentNumber$"
```

**IMPORTANT**

The deployments must have an existing deploymentParameters file before deploying. If additional deployment stacks are required, a new dep{{ deployment_number }}.yaml file must be created in the appropriate directoy:

```bash
$ common/files/deploymentParameters/$deploymentEnvironment$/$sampleEnvironment/dep$deploymentNumber
```

Once the deployment stack is completed, the appropriate sample sample deployment playbooks can be ran.


All sample sample deployment playbooks **MUST** be ran from the deployed Automation EC2 at *automation.(dev/upprod/uptest).dev*



Modification
==============================

Update a Stack
--------------------------------------

To update a stack, simply edit the associated parameters file in `common/files/deploymentParameters` and rerun the playbook used to create the stack.


To prevent changes to an existing CloudFormation stack unintentionally triggering the replacement or deletion of an existing EC2 instance, the stack creation playbook enables Termination Protection on all EC2 instances deployed by the stack.

If you are making parameter changes that you know will replace or delete an existing EC2 instance, first run the appropriate playbook to disable Termination Protection:

Central Services

```bash
$ ansible-playbook playbooks/update-termination-protection.yml -e enabled="false"
```


Deployment

```bash
$ ansible-playbook playbooks/update-termination-protection.yml -e enabled="false" -e "deployment_number=$deploymentNumber$"
```

**IMPORTANT**

The instances must be in the **Running** state before running these playbooks.


Deletion
==============================

Deleting the Central Services Stack
--------------------------------------

To delete a deployment stack, run the following playbook:

```bash
$ ansible-playbook playbooks/stack-delete.yml -e central_services_stack="true"
```

You will be provided a prompt requiring you to input 'accept' before the play will continue. Any other input will end the playbook.


Deleting a Deployment Stack
--------------------------------------

To delete a deployment stack, run the following playbook:

```bash
$ ansible-playbook playbooks/stack-delete.yml -e "deployment_number=$deploymentNumber$"
```

You will be provided a prompt requiring you to input 'accept' before the play will continue. Any other input will end the playbook.


Appendix
==============================

Auxiliary Templates
--------------------------------------

These CloudFormation templates support integration from other AWS GovCloud accounts with sample's Services. These are stored in `common/files/cloudFormationTemplates/auxiliary`.


### sampleAwsExternalEdgeIntegration.yaml
This template is to be ran on another AWS Account who wishes to integrate their AWS GovCloud hosted sample edge site with one of sample's upstream deployments.

#### Preqeuisites

Before deploying the stack, they must provide their AWS Account ID and it must be added to the `AWS::EC2::VPCEndpointServicePermissions` resources on the `sampleCentralServices/sampleCentralServicesNLB.yaml` file.

After this has been done, the central services stack must be updated in the appropriate upstream account via the aforementioned playbooks.

#### Stack Deployment
After the stack update is complete, the distant end must deploy a CloudFormation stack using the `sampleAwsExternalEdgeIntegration.yaml` file.

#### Post Deployment
After their stack has deployed. A new `AWS::EC2::VPCEndpoint` resource must be created in the `sampleCentralServices/sampleCentralServicesEndpoints.yaml` file, using the `Service name` of the VPC Endpoint Service created by the CloudFormation stack.

A `AWS::Route53::HostedZone`, and `AWS::Route53::RecordSetGroup` resource must also be created in the file. See existing resources for examples.

Afterwards, the sampleCentralServices stack must be updated in all sample AWS Accounts via the aforementioned playbooks.

This will allow sample developers to connect to the distant end edge site from their AWS Workspace and facilitate push replication.