# IAM for AWS cert manager

This terraform module provides an easy way to generate cert-manager required IAM permissions.

> ⚠️ **Warning**: this module uses ["IAM Roles for ServiceAccount"](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to inject AWS credentials inside cluster autoscaler pods

## Requirements

|   Name    | Version     |
| --------- | ----------- |
| terraform | `>= 0.15.4` |
| aws       | `>= 3.37.0` |

## Providers

| Name | Version  |
| ---- | -------- |
| aws  | `>= 3.37.0` |

## Inputs

|         Name         |              Description              |     Type      | Default | Required |
| -------------------- | ------------------------------------- | ------------- | ------- | :------: |
| cluster_name         | The EKS cluster name                  | `string`      | n/a     |   yes    |
| public\_zone\_id     | The public zone ID                    | `string`      | n/a     |   yes    |

## Outputs

|            Name                    |               Description               |
| ---------------------------------- | --------------------------------------- |
| cert\_manager\_patches             | Cert Manager SA Kustomize patch   |
| cert\_manager\_iam\_role\_arn      | Cert Manager IAM role arn       |


## Usage

```hcl
module "cert_manager_iam_role" {
  source             = "../vendor/modules/ingress/aws-cert-manager"
  cluster_name       = "myekscluster"
  public_zone_id     = "Z1BM4RA99PG48O"
}
```
