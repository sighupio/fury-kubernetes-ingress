/**
 * Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file.
 */

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "public_zone_id" {
  description = "Route53 public zone ID"
  type        = string
}

variable "private_zone_id" {
  description = "Route53 private zone ID"
  type        = string
  default     = ""
}

variable "enable_private" {
  description = "Enable private IAM creation"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for the created resources"
  type        = map(string)
  default     = {}
}
