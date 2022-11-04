/**
 * Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file.
 */

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

resource "aws_iam_policy" "external_dns_public" {
  name   = "${var.cluster_name}-e-dns-public"
  tags   = var.tags
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:GetHostedZone",
                "route53:GetHostedZoneCount",
                "route53:ListHostedZonesByName",
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/${var.public_zone_id}"
            ]
        }
    ]
}
EOF
}

module "external_dns_public_iam_assumable_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "v3.16.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-e-dns-public"
  provider_url                  = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.external_dns_public.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:ingress-nginx:external-dns-public"]
}


resource "aws_iam_policy" "external_dns_private" {
  count  = var.private_zone_id != "" ? 1 : 0
  name   = "${var.cluster_name}-e-dns-private"
  tags   = var.tags
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:GetHostedZone",
                "route53:GetHostedZoneCount",
                "route53:ListHostedZonesByName",
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/${var.private_zone_id}"
            ]
        }
    ]
}
EOF
}

module "external_dns_private_iam_assumable_role" {
  count                         = var.private_zone_id != "" ? 1 : 0
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "v3.16.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-e-dns-private"
  provider_url                  = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.external_dns_private[0].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:ingress-nginx:external-dns-private"]
}
