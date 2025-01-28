# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#-----------------------------------------------------------------------------------
# GCS Encryption
#-----------------------------------------------------------------------------------
data "google_kms_key_ring" "vault" {
  count = var.gcp_kms_key_ring == null ? 0 : 1

  name     = var.gcp_kms_key_ring
  location = var.gcp_kms_region != null ? var.gcp_kms_region : var.region
}

data "google_kms_crypto_key" "vault_key" {
  count = var.gcp_kms_crypto_key == null ? 0 : 1

  name     = var.gcp_kms_crypto_key
  key_ring = data.google_kms_key_ring.vault[0].id
}

# If KMS exists in another project, add an IAM permission in that project with
# the 'roles/cloudkms.cryptoKeyEncrypterDecrypter' role
resource "google_project_iam_member" "vault_iam_kms" {
  count = var.gcp_kms_project == null ? 0 : 1

  project = var.gcp_kms_project
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = google_service_account.vault_sa.member
}

resource "google_project_iam_custom_role" "vault_kms_custom_role" {
  role_id     = "vaultKmsRole"
  title       = "Vault KMS CryptoKey Encrypter/Decrypter and Viewer Role"
  description = "Custom role for Vault to access Cloud KMS Key"
  permissions = var.vault_kms_custom_role
}

resource "google_kms_crypto_key_iam_member" "vault_key" {
  count = var.gcp_kms_crypto_key == null ? 0 : 1

  crypto_key_id = data.google_kms_crypto_key.vault_key[0].id
  role          = google_project_iam_custom_role.vault_kms_custom_role.name
  member        = google_service_account.vault_sa.member
}
