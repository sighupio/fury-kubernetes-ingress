# IAM for AWS External dns

This terraform module provides an easy way to generate external-dns (public and private) required IAM permissions.

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
| cluster\_name         | The EKS cluster name                  | `string`      | n/a     |   yes    |
| public\_zone\_id     | The public zone ID                    | `string`      | n/a     |   yes    |
| private\_zone\_id    | The private zone ID                   | `string`      | n/a     |   no     |

## Outputs

|            Name                            |               Description               |
| ------------------------------------------ | --------------------------------------- |
| external\_dns\_public\_patches             | External DNS public SA Kustomize patch  |
| external\_dns\_public\_iam\_role\_arn      | External DNS public IAM role arn        |
| external\_dns\_private\_patches            | External DNS private SA Kustomize patch |
| external\_dns\_private\_iam\_role\_arn     | External DNS private IAM role arn       |

## Usage

```hcl
module "cert_manager_iam_role" {
  source             = "../vendor/modules/ingress/aws-external-dns"
  cluster_name       = "myekscluster"
  public_zone_id     = "Z1BM4RA99PG48O"
  private_zone_id    = "Z1BM4RA99PG499"
}
```
