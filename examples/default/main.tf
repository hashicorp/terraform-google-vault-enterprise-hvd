module "default_example" {
  source = "../.."

  #------------------------------------------------------------------------------
  # Common
  #------------------------------------------------------------------------------
  project_id = var.project_id
  region     = var.region
  vault_fqdn = var.vault_fqdn
  tags       = ["vault"]

  #------------------------------------------------------------------------------
  # Networking
  #------------------------------------------------------------------------------
  load_balancing_scheme = var.load_balancing_scheme
  vault_health_endpoints = {
    standbyok              = "true"
    perfstandbyok          = "true"
    activecode             = "200"
    standbycode            = "429"
    drsecondarycode        = "200"
    performancestandbycode = "200"
    sealedcode             = "200"
    uninitcode             = "200"
  }
  network                 = var.network
  subnetwork              = var.subnetwork

  #------------------------------------------------------------------------------
  # GCP Secret Manager installation secrets and GCP KMS unseal key
  #------------------------------------------------------------------------------
  vault_seal_type    = var.vault_seal_type
  gcp_kms_region     = var.gcp_kms_region
  gcp_kms_key_ring   = var.gcp_kms_key_ring
  gcp_kms_crypto_key = var.gcp_kms_crypto_key
  vault_tls_cert_sm_secret_name      = var.vault_tls_cert_sm_secret_name
  vault_tls_privkey_sm_secret_name   = var.vault_tls_privkey_sm_secret_name
  vault_license_sm_secret_name       = var.vault_license_sm_secret_name
  vault_tls_ca_bundle_sm_secret_name = var.vault_tls_ca_bundle_sm_secret_name

  #------------------------------------------------------------------------------
  # GCS bucket to use for Vault Enterprise snapshots
  #------------------------------------------------------------------------------
  vault_snapshot_gcs_bucket_name = var.vault_snapshot_gcs_bucket_name
}
