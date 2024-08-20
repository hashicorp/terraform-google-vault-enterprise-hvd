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
  member  = format("serviceAccount:%s", google_service_account.vault_sa.email)
}

resource "google_storage_bucket_iam_binding" "snapshots_creator" {
  count = var.vault_snapshot_gcs_bucket_name == null ? 0 : 1

  bucket = var.vault_snapshot_gcs_bucket_name
  role   = "roles/storage.objectCreator"

  members = [
    format("serviceAccount:%s", google_service_account.vault_sa.email)
  ]
}

resource "google_storage_bucket_iam_binding" "snapshots_viewer" {
  count = var.vault_snapshot_gcs_bucket_name == null ? 0 : 1

  bucket = var.vault_snapshot_gcs_bucket_name
  role   = "roles/storage.objectViewer"

  members = [
    format("serviceAccount:%s", google_service_account.vault_sa.email)
  ]
}