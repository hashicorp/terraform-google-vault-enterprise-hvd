# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Firewall rules (for GCP Health Check Probes)
#------------------------------------------------------------------------------
resource "google_compute_firewall" "allow_vault_health_checks" {
  count = var.load_balancing_scheme == "NONE" ? 0 : 1

  name        = format("%s-health-check-fw", var.application_prefix)
  network     = data.google_compute_network.network.self_link
  project     = var.network_project_id == null ? var.project_id : var.network_project_id
  description = "Allow Google LB HC IP ranges to poll Vault Instance"
  direction   = "INGRESS"

  source_ranges = concat(
    data.google_netblock_ip_ranges.legacy.cidr_blocks_ipv4,
    data.google_netblock_ip_ranges.new.cidr_blocks_ipv4
  )

  allow {
    protocol = "tcp"
    ports    = [var.vault_port_api]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

#------------------------------------------------------------------------------
# Backend
#------------------------------------------------------------------------------
resource "google_compute_region_backend_service" "vault_bs" {
  count = var.load_balancing_scheme == "NONE" ? 0 : 1

  name    = format("%s-backend-service", var.application_prefix)
  project = var.project_id
  region  = var.region

  protocol              = "TCP"
  load_balancing_scheme = var.load_balancing_scheme
  timeout_sec           = 60

  backend {
    group = google_compute_region_instance_group_manager.vault.instance_group
  }

  health_checks = [google_compute_region_health_check.vault_hc[0].self_link]
}

resource "google_compute_region_health_check" "vault_hc" {
  count = var.load_balancing_scheme == "NONE" ? 0 : 1

  name    = format("%s-regional-health-check", var.application_prefix)
  project = var.project_id
  region  = var.region

  check_interval_sec = var.health_check_interval
  timeout_sec        = var.health_timeout

  https_health_check {
    port               = var.vault_port_api
    port_specification = "USE_FIXED_PORT"

    request_path = format("/v1/sys/health?standbyok=%s&perfstandbyok=%s&activecode=%s&standbycode=%s&drsecondarycode=%s&performancestandbycode=%s&sealedcode=%s&uninitcode=%s",
      var.vault_health_endpoints["standbyok"],
      var.vault_health_endpoints["perfstandbyok"],
      var.vault_health_endpoints["activecode"],
      var.vault_health_endpoints["standbycode"],
      var.vault_health_endpoints["drsecondarycode"],
      var.vault_health_endpoints["performancestandbycode"],
      var.vault_health_endpoints["sealedcode"],
    var.vault_health_endpoints["uninitcode"])
  }

  log_config {
    enable = true
  }
}

#------------------------------------------------------------------------------
# Frontend
#------------------------------------------------------------------------------
resource "google_compute_forwarding_rule" "vault_fr" {
  count = var.load_balancing_scheme == "NONE" ? 0 : 1

  name       = format("%s-forwarding-rule", var.application_prefix)
  region     = var.region
  project    = var.project_id
  network    = var.load_balancing_scheme == "INTERNAL" ? data.google_compute_network.network.self_link : null
  subnetwork = var.load_balancing_scheme == "INTERNAL" ? data.google_compute_subnetwork.subnetwork.self_link : null

  backend_service       = google_compute_region_backend_service.vault_bs[0].id
  ports                 = [var.vault_port_api, var.vault_port_cluster]
  load_balancing_scheme = var.load_balancing_scheme
}