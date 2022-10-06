/**
 * Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file.
 */

output "external_dns_public_patches" {
  description = "external-dns-public Kubernetes resources patches"
  value       = <<EOT
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: ${module.external_dns_public_iam_assumable_role.this_iam_role_arn}
  name: external-dns-public
  namespace: ingress-nginx
EOT
}

output "external_dns_public_iam_role_arn" {
  description = "external-dns-public IAM role"
  value       = module.external_dns_public_iam_assumable_role.this_iam_role_arn
}

output "external_dns_private_patches" {
  description = "external-dns-private Kubernetes resources patches"
  value       = <<EOT
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: ${element(coalescelist(module.external_dns_private_iam_assumable_role.*.this_iam_role_arn, [""]), 0)}
  name: external-dns-private
  namespace: ingress-nginx
EOT
}

output "external_dns_private_iam_role_arn" {
  description = "external-dns-private IAM role"
  value       = element(coalescelist(module.external_dns_private_iam_assumable_role.*.this_iam_role_arn, [""]), 0)
}
