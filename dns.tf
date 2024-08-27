# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "google_dns_managed_zone" "vault" {
  count = var.create_cloud_dns_record == true ? 1 : 0

  name = var.cloud_dns_managed_zone
}

resource "google_dns_record_set" "vault" {
  count = var.create_cloud_dns_record == true ? 1 : 0

  managed_zone = data.google_dns_managed_zone.vault[0].name
  name         = "${var.vault_fqdn}."
  type         = "A"
  ttl          = 60
  rrdatas      = [google_compute_forwarding_rule.vault_fr[0].ip_address]
}
