# Concourse CI on Azure

This is currently a work in progress and is **incomplete**, it is not safe for production
without considering security, scaling and durability. It is recommended to use this as a
starting point for building a [Concourse CI](https://concourse-ci.org/) system.

## Pre-requisites

* **Knowledge**
  * Understanding of what [Concourse CI](https://concourse-ci.org/) is
  * Basic understanding of Azure and permissions
  
* **Software installed on local machine**
  * Terraform (written against v0.11.13)
  * Azure CLI (written against 2.0.60)

If Azure or concourse are new to you, head over to the links provided and read into what this codebase will be doing as 
the resources provisioned are not all free and concourse is not configured via a user interface.

## Concourse CI on Azure

This codebase will create the infrastructure needed for running [Concourse CI](https://concourse-ci.org/) and 
subsequently install and configure the software accordingly.

## Getting Started

### Provisioning the infrastructure

To provision the infrastructure, [terraform](https://www.terraform.io/) is used to create the following resources in Azure:

* Core ([managed identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview),
        [resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview#resource-groups))       
* Networking ([virtual network](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview),
              [network security group](https://docs.microsoft.com/en-us/azure/virtual-network/security-overview#network-security-groups),
              subnet,
              network interface)
* Key Vault ([azure key vault](https://azure.microsoft.com/en-gb/services/key-vault/))
* Machine ([virtual machine](https://azure.microsoft.com/en-gb/services/virtual-machines/))

###### Key Vault

The reason for the Azure Key Vault is that it is not recommended to manage the user authentication yourself.

Using Azure Key Vault, secrets can be added at provision time and then read securely at install/configuration time.
An example of secrets that would be added are client id and client secret as required by [Github OAuth](https://developer.github.com/apps/building-oauth-apps/authorizing-oauth-apps/).

#### Instructions

You will need to ensure that the shell you are working in has permission to provision the above infrastructure in Azure. i.e. run `az login` prior to executing the commands below. If you
do not have permission to provision the listed infrastructure, see the Owner of your subscription.

```
cd terraform/

terraform init
terraform apply
```

See the next section for information on installation and configuration of the components (automatic - no more commands are required)


## Installation and configuration

Once terraform has complete the provisioning of the infrastructure, [ansible](https://ansible.com) is used to
install and configure the following using cloud-init *automatically*:

* Postgresql 
* Concourse web
* Concourse worker

All of the software will be installed and configured on a single machine however when running at scale
it may be worth considering multiple web and worker nodes. More on scaling and performance can be found
on the Concourse CI website.

#### Local Authentication

Local Authentication is currently enabled with the username *concourse* and password *concourse*.

If you want to use [Github OAuth](https://developer.github.com/apps/building-oauth-apps/authorizing-oauth-apps/), see the sample key vault *client id* and *secret id* terraform declarations in [keyvault.tf](terraform/keyvault.tf). Using the azure machine identity, retrieve the secrets and write them into the templated [concourse-web service file](ansible/roles/concourse-web/templates/concourse-web.service.j2).

## Tests

[Inspec](https://www.inspec.io/) is used to remotely test whether ansible successfully started concourse and postgres.

To run the inspec tests:

```
inspec exec inspec -t ssh://concourse-admin@<dns label>.westeurope.cloudapp.azure.com
```
where the dns label is the value specified by the `public_ip_label` variable.

## Sample Pipelines

* Two jobs, one with a single task and the other with two tasks

## Improvements

* Sample pipelines
* Tests for terraform provisioned infrastructure