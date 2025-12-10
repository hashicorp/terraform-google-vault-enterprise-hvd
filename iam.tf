# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Service Account
#------------------------------------------------------------------------------
resource "google_service_account" "vault_sa" {
  account_id   = format("%s-service-account", var.application_prefix)
  display_name = "HashiCorp Vault service account"
  project      = var.project_id
}

resource "google_project_iam_member" "vault_iam" {
  for_each = toset(var.google_service_account_iam_roles)

  project = var.project_id
  role    = each.value
  member  = google_service_account.vault_sa.member
}

resource "google_storage_bucket_iam_binding" "snapshots_creator" {
  count = var.vault_snapshot_gcs_bucket_name == null ? 0 : 1

  bucket = var.vault_snapshot_gcs_bucket_name
  role   = "roles/storage.objectCreator"

  members = [
    google_service_account.vault_sa.member
  ]
}

resource "google_storage_bucket_iam_binding" "snapshots_viewer" {
  count = var.vault_snapshot_gcs_bucket_name == null ? 0 : 1

  bucket = var.vault_snapshot_gcs_bucket_name
  role   = "roles/storage.objectViewer"

  members = [
    google_service_account.vault_sa.member
  ]
}

resource "google_project_iam_custom_role" "vault_custom_role" {
  role_id     = "vaultCustomRole"
  title       = "Vault Custom Role"
  description = "Custom role for Vault to access GCP resources"
  permissions = var.vault_custom_role
}

resource "google_project_iam_member" "vault_custom_role" {
  project = var.project_id
  role    = google_project_iam_custom_role.vault_custom_role.name
  member  = google_service_account.vault_sa.member
}
