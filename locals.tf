# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  vault_seal_attributes = {
    project    = var.gcp_kms_project == null ? var.project_id : var.gcp_kms_project
    region     = var.gcp_kms_region == null ? var.region : var.gcp_kms_region
    key_ring   = var.gcp_kms_key_ring
    crypto_key = var.gcp_kms_crypto_key
  }
}
