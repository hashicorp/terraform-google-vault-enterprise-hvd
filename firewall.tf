# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

resource "google_compute_firewall" "allow_iap" {
  count = var.enable_iap == true ? 1 : 0
  #name  = "${var.friendly_name_prefix}-vault-firewall-iap-allow"
  name = "${var.application_prefix}-vault-firewall-iap-allow"

  description = "Allow https://cloud.google.com/iap/docs/using-tcp-forwarding#console traffic"
  network     = data.google_compute_network.network.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [3389, 22]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["vault-backend"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_https" {
  # name        = "${var.friendly_name_prefix}-vault-firewall-https-allow"
  name = "${var.application_prefix}-vault-firewall-https-allow"

  description = "Allow HTTPS traffic ingress to vault instances in ${data.google_compute_network.network.name} from specified CIDR ranges."
  network     = data.google_compute_network.network.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = concat(tolist([var.vault_port_api]), tolist([var.vault_port_cluster]))
  }

  source_ranges = var.cidr_ingress_https_allow
  target_tags   = ["vault-backend"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
