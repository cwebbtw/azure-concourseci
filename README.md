# Concourse CI on Azure

WARNING: This is currently a work in progress and is **incomplete**, it is not safe for production

## Pre-requisites

* **Knowledge**
  * Understanding of what [Concourse CI](https://concourse-ci.org/) is
  * Basic understanding of Azure and permissions
  
* **Software installed**
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

#### Instructions

You will need to ensure that the shell you are working in has permission to provision the above infrastructure in Azure.

```
cd terraform/

terraform init
terraform apply
```

## Further reading

To understand more about how concourse is being installed and configured after the infrastructure
has been provisioned, see [here](#) -- **unfinished**
