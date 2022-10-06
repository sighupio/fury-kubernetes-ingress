/**
 * Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file.
 */

output "cert_manager_patches" {
  description = "cert-manager Kubernetes resources patches"
  value       = <<EOT
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: ${module.cert_manager_iam_assumable_role.this_iam_role_arn}
  name: cert-manager
  namespace: cert-manager
EOT
}

output "cert_manager_iam_role_arn" {
  description = "cert-manager IAM role"
  value       = module.cert_manager_iam_assumable_role.this_iam_role_arn
}
