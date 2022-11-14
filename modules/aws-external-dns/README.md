# IAM for AWS external-dns

This terraform module provides an easy way to generate external-dns (public and private) required IAM permissions.

> ⚠️ **Warning**: this module uses ["IAM Roles for ServiceAccount"](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to inject AWS credentials inside cluster autoscaler pods.

## Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | >= 0.15.4 |
| aws       | >= 3.37.0 |

## Providers

| Name | Version   |
| ---- | --------- |
| aws  | >= 3.37.0 |

## Modules

| Name                                         | Source                                                              | Version |
| -------------------------------------------- | ------------------------------------------------------------------- | ------- |
| external\_dns\_private\_iam\_assumable\_role | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | v3.16.0 |
| external\_dns\_public\_iam\_assumable\_role  | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | v3.16.0 |

## Resources

| Name                                                                                                                          | Type        |
| ----------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.external_dns_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource    |
| [aws_iam_policy.external_dns_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)  | resource    |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster)            | data source |

## Inputs

| Name              | Description                               | Type          | Default | Required |
| ----------------- | ----------------------------------------- | ------------- | ------- | :------: |
| cluster\_name     | EKS cluster name                          | `string`      | n/a     |   yes    |
| private\_zone\_id | Route53 private zone ID                   | `string`      | `""`    |    no    |
| public\_zone\_id  | Route53 public zone ID                    | `string`      | n/a     |   yes    |
| tags              | Additional tags for the created resources | `map(string)` | `{}`    |    no    |

## Outputs

| Name                                   | Description                                       |
| -------------------------------------- | ------------------------------------------------- |
| external\_dns\_private\_iam\_role\_arn | external-dns-private IAM role                     |
| external\_dns\_private\_patches        | external-dns-private Kubernetes resources patches |
| external\_dns\_public\_iam\_role\_arn  | external-dns-public IAM role                      |
| external\_dns\_public\_patches         | external-dns-public Kubernetes resources patches  |

## Usage

```hcl
module "cert_manager_iam_role" {
  source             = "../vendor/modules/ingress/aws-external-dns"
  cluster_name       = "myekscluster"
  public_zone_id     = "Z1BM4RA99PG48O"
  private_zone_id    = "Z1BM4RA99PG499"
  tags               = {"mykey": "myvalue"}
}
```
