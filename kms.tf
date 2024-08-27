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
  member  = format("serviceAccount:%s", google_service_account.vault_sa.email)
}

resource "google_kms_crypto_key_iam_member" "vault_key" {
  count = var.gcp_kms_crypto_key == null ? 0 : 1

  crypto_key_id = data.google_kms_crypto_key.vault_key[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.vault_sa.email}"
}
resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  count       = var.gcp_kms_key_ring == null ? 0 : 1
  key_ring_id = data.google_kms_key_ring.vault[0].id
  # key_ring_id = "${var.gcloud-project}/${var.keyring_location}/${var.key_ring}"
  role = "roles/editor"

  members = [
    "serviceAccount:${google_service_account.vault_sa.email}",
  ]
}
