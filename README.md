# Sealed Secrets module

Module to provision the Sealed Secrets controller in the cluster. The Sealed Secrets controller provides a secure, self-contained mechanism to manage credentials in a GitOps repo. The credentials are encrypted and stored in the GitOps repository in a SealedSecret custom resource. When the SealedSecret resources are created in the cluster, the Sealed Secret controller decrypts the value and generates a kubernetes secret from the value.

The alternative to Sealed Secrets for managing credentials in GitOps is to use some third-party software component to store and manage the secrets and them pull values from that system for use in the cluster. Sealed Secrets have the advantage of being self-contained and managed directly in git. In large enterprise deployments an external secret manager is preferable but Sealed Secrets provide a safe and simple entry point for handling credentials in GitOps.

More information on sealed secrets can be found here - https://github.com/bitnami-labs/sealed-secrets

## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform - v13
- kubectl

### Terraform providers

- IBM Cloud provider >= 1.5.3

## Module dependencies

This module makes use of the output from other modules:

- Cluster - github.com/ibm-garage-cloud/terraform-ibm-container-platform.git
- Namespace - github.com/ibm-garage-clout/terraform-cluster-namespace.git

## Example usage

```hcl-terraform
module "sealed_secrets" {
  source = "github.com/cloud-native-toolkit/terraform-tools-sealed-secrets.git"

  cluster_config_file = module.dev_cluster.config_file_path
  namespace           = module.namespace.name
}
```

