output "loadbalancer_ip" {
  description = "The external ip address of the forwarding rule."
  value       = [google_compute_forwarding_rule.vault_fr.*.ip_address]
}

# output "vault_cli_config" {
#   value = "TBD"
# }

output "vault_cli_config" {
  description = "Environment variables to configure the Vault CLI"
  value       = <<-EOF
    %{ if var.load_balancing_scheme != "NONE" ~}
    export VAULT_ADDR=https://${google_compute_forwarding_rule.vault_fr.*.ip_address[0]}:8200
    %{ else ~}
    # No load balancer created; set VAULT_ADDR to the IPV4 address of any Vault instance
    export VAULT_ADDR=https://<instance-ipv4>:8200
    %{ endif ~}
    export VAULT_TLS_SERVER_NAME=${var.vault_fqdn}
    %{ if var.vault_tls_ca_bundle_sm_secret_name != null ~}
    export VAULT_CACERT=<path/to/ca-certificate>
    %{ endif ~}
  EOF
}

output "user_data_template" {
  value = var.debug != false ? google_compute_instance_template.vault.metadata_startup_script : null
}

output "zones" {
  value = slice(data.google_compute_zones.available.names, 0, 3)
}
