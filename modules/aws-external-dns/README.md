# IAM for AWS external-dns

This terraform module provides an easy way to generate external-dns (public and private) required IAM permissions.

> ⚠️ **Warning**: this module uses ["IAM Roles for ServiceAccount"](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to inject AWS credentials inside cluster autoscaler pods

## Requirements

| Name                                                                      | Version   |
| ------------------------------------------------------------------------- | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 3.37.0 |

## Providers

| Name                                              | Version   |
| ------------------------------------------------- | --------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.37.0 |

## Modules

| Name                                                                                                                                                                | Source                                                              | Version |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | ------- |
| <a name="module_external_dns_private_iam_assumable_role"></a> [external\_dns\_private\_iam\_assumable\_role](#module\_external\_dns\_private\_iam\_assumable\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | v3.16.0 |
| <a name="module_external_dns_public_iam_assumable_role"></a> [external\_dns\_public\_iam\_assumable\_role](#module\_external\_dns\_public\_iam\_assumable\_role)    | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | v3.16.0 |

## Resources

| Name                                                                                                                          | Type        |
| ----------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.external_dns_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource    |
| [aws_iam_policy.external_dns_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)  | resource    |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster)            | data source |

## Inputs

| Name                                                                                | Description                               | Type          | Default | Required |
| ----------------------------------------------------------------------------------- | ----------------------------------------- | ------------- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)            | EKS cluster name                          | `string`      | n/a     |   yes    |
| <a name="input_private_zone_id"></a> [private\_zone\_id](#input\_private\_zone\_id) | Route53 private zone ID                   | `string`      | `""`    |    no    |
| <a name="input_public_zone_id"></a> [public\_zone\_id](#input\_public\_zone\_id)    | Route53 public zone ID                    | `string`      | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input\_tags)                                      | Additional tags for the created resources | `map(string)` | `{}`    |    no    |

## Outputs

| Name                                                                                                                                              | Description                                       |
| ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| <a name="output_external_dns_private_iam_role_arn"></a> [external\_dns\_private\_iam\_role\_arn](#output\_external\_dns\_private\_iam\_role\_arn) | external-dns-private IAM role                     |
| <a name="output_external_dns_private_patches"></a> [external\_dns\_private\_patches](#output\_external\_dns\_private\_patches)                    | external-dns-private Kubernetes resources patches |
| <a name="output_external_dns_public_iam_role_arn"></a> [external\_dns\_public\_iam\_role\_arn](#output\_external\_dns\_public\_iam\_role\_arn)    | external-dns-public IAM role                      |
| <a name="output_external_dns_public_patches"></a> [external\_dns\_public\_patches](#output\_external\_dns\_public\_patches)                       | external-dns-public Kubernetes resources patches  |

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
