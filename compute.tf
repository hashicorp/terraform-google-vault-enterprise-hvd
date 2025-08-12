# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  vault_user_data_template = fileexists("${path.cwd}/templates/${var.vault_user_data_template}") ? "${path.cwd}/templates/${var.vault_user_data_template}" : "${path.module}/templates/${var.vault_user_data_template}"
  vault_user_data_template_vars = {
    # system paths and settings
    systemd_dir              = var.systemd_dir,
    vault_dir_bin            = var.vault_dir_bin,
    vault_dir_config         = var.vault_dir_config,
    vault_dir_home           = var.vault_dir_home,
    vault_dir_logs           = var.vault_dir_logs,
    vault_user_name          = var.vault_user_name,
    vault_group_name         = var.vault_group_name,
    additional_package_names = join(" ", var.additional_package_names)

    # installation secrets
    vault_license_sm_secret_name       = var.vault_license_sm_secret_name
    vault_tls_cert_sm_secret_name      = var.vault_tls_cert_sm_secret_name
    vault_tls_privkey_sm_secret_name   = var.vault_tls_privkey_sm_secret_name
    vault_tls_ca_bundle_sm_secret_name = var.vault_tls_ca_bundle_sm_secret_name == null ? "NONE" : var.vault_tls_ca_bundle_sm_secret_name,

    #Vault settings
    vault_fqdn    = var.vault_fqdn == null ? "" : var.vault_fqdn,
    vault_version = var.vault_version,
    #vault_install_url                        = format("https://releases.hashicorp.com/vault/%s/vault_%s_linux_amd64.zip", var.vault_version, var.vault_version),
    vault_disable_mlock                      = var.vault_disable_mlock,
    vault_enable_ui                          = var.vault_enable_ui,
    vault_default_lease_ttl_duration         = var.vault_default_lease_ttl_duration,
    vault_max_lease_ttl_duration             = var.vault_max_lease_ttl_duration,
    vault_port_api                           = var.vault_port_api,
    vault_port_cluster                       = var.vault_port_cluster,
    vault_telemetry_config                   = var.vault_telemetry_config == null ? {} : var.vault_telemetry_config,
    vault_tls_require_and_verify_client_cert = var.vault_tls_require_and_verify_client_cert,
    vault_tls_disable_client_certs           = var.vault_tls_disable_client_certs,
    vault_seal_type                          = var.vault_seal_type,
    vault_seal_attributes                    = local.vault_seal_attributes,
    vault_plugin_urls                        = var.vault_plugin_urls
    auto_join_tag_value                      = var.auto_join_tag == null ? var.tags[0] : var.auto_join_tag[0]
    auto_join_zone_pattern                   = "${var.region}-[[:alpha:]]{1}"
    vault_raft_performance_multiplier        = var.vault_raft_performance_multiplier
  }
}

#------------------------------------------------------------------------------
# Compute
#------------------------------------------------------------------------------
resource "google_compute_instance_template" "vault" {
  name_prefix = format("%s-instance-template-", var.application_prefix)
  project     = var.project_id

  machine_type   = var.machine_type
  can_ip_forward = true

  tags   = concat(["vault-backend"], var.tags)
  labels = var.common_labels

  disk {
    source_image = var.packer_image == null ? format("%s/%s", var.compute_image_project, var.compute_image_family) : var.packer_image
    auto_delete  = true
    boot         = true
    disk_type    = var.boot_disk_type
    disk_size_gb = var.boot_disk_size
  }

  disk {
    auto_delete  = true
    boot         = false
    disk_type    = var.vault_data_disk_type
    disk_size_gb = var.vault_data_disk_size
  }

  disk {
    auto_delete  = true
    boot         = false
    disk_type    = var.vault_audit_disk_type
    disk_size_gb = var.vault_audit_disk_size
  }

  network_interface {
    //network    = data.google_compute_network.network.self_link
    subnetwork = data.google_compute_subnetwork.subnetwork.self_link
  }

  metadata = var.metadata

  metadata_startup_script = templatefile(local.vault_user_data_template, local.vault_user_data_template_vars)

  service_account {
    email  = google_service_account.vault_sa.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "vault" {
  name    = "${var.application_prefix}-vault-ig-mgr"
  project = var.project_id

  base_instance_name = "${var.application_prefix}-vault-vm"
  #distribution_policy_zones = data.google_compute_zones.available.names
  #this change limits the serversprawl to 3 zones ensuring voters and none voters after first 3 instances
  distribution_policy_zones = slice(data.google_compute_zones.available.names, 0, 3)
  target_size               = var.node_count
  region                    = var.region

  version {
    name              = google_compute_instance_template.vault.name
    instance_template = google_compute_instance_template.vault.self_link
  }

  update_policy {
    type = "OPPORTUNISTIC"
    //type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = length(data.google_compute_zones.available.names)
    max_unavailable_fixed        = 0
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "auto_healing_policies" {
    for_each = var.enable_auto_healing == true ? [true] : []
    content {
      health_check      = google_compute_health_check.vault_auto_healing[0].self_link
      initial_delay_sec = var.initial_auto_healing_delay
    }
  }

}

resource "google_compute_health_check" "vault_auto_healing" {
  count = var.enable_auto_healing == true ? 1 : 0

  name    = format("%s-autohealing-health-check", var.application_prefix)
  project = var.project_id

  check_interval_sec = var.health_check_interval
  timeout_sec        = var.health_timeout

  https_health_check {
    port               = var.vault_port_api
    port_specification = "USE_FIXED_PORT"

    request_path = "/v1/sys/health?standbyok=true&perfstandbyok=true&activecode=200&standbycode=200&drsecondarycode=200&performancestandbycode=200&sealedcode=200&uninitcode=200"
  }

  log_config {
    enable = true
  }
}
