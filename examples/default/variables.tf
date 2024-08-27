# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#-----------------------------------------------------------------------------------
# Debug
#-----------------------------------------------------------------------------------
variable "debug" {
  type        = bool
  description = "[Optional bool] Enable additional outputs available module outputs for debug purposes."
  default     = false
}

#-----------------------------------------------------------------------------------
# Common
#-----------------------------------------------------------------------------------
variable "project_id" {
  type        = string
  description = "(required) The project ID to host the cluster in (required)"
}

variable "region" {
  type        = string
  description = "(optional) The region to host the cluster in"
  default     = "us-central1"
}

variable "vault_fqdn" {
  type        = string
  description = "Fully qualified domain name to use for joining peer nodes and optionally DNS"
  nullable    = false
}

variable "tags" {
  type        = list(string)
  description = "(optional) A list containing tags to assign to all resources"
  default     = ["vault"]
}

variable "common_labels" {
  type        = map(string)
  description = "(optional) Common labels to apply to GCP resources."
  default     = {}
}

variable "application_prefix" {
  type        = string
  description = "(optional) The prefix to give to cloud entities"
  default     = "vault"
}

#------------------------------------------------------------------------------
# prereqs
#------------------------------------------------------------------------------
variable "vault_license_sm_secret_name" {
  type        = string
  description = "Name of Secret Manager secret containing Vault license."
}

variable "vault_tls_cert_sm_secret_name" {
  type        = string
  description = "Name of Secret Manager containing Vault TLS certificate."
}

variable "vault_tls_privkey_sm_secret_name" {
  type        = string
  description = "Name of Secret Manager containing Vault TLS private key."
}

variable "vault_tls_ca_bundle_sm_secret_name" {
  type        = string
  description = "Name of Secret Manager containing Vault TLS custom CA bundle."
  nullable    = true
}

variable "gcp_kms_project" {
  type        = string
  description = "(optional) The project the KMS key ring is in. Can be left blank if project is the same as provider"
  default     = null
}

variable "gcp_kms_region" {
  type        = string
  description = "(optional) The region the KMS key ring is in. Can be left blank if region is the same as main region"
  default     = null
}

variable "gcp_kms_key_ring" {
  type        = string
  description = "(optional) The name of the KMS key ring if it exists"
  default     = null
}

variable "gcp_kms_crypto_key" {
  type        = string
  description = "(optional) The name of the KMS crypto key"
  default     = null
}

#------------------------------------------------------------------------------
# Vault configuration settings
#------------------------------------------------------------------------------
variable "vault_version" {
  type        = string
  description = "(optional) The version of Vault to use"
  default     = "1.16.0+ent"
}

variable "vault_disable_mlock" {
  type        = bool
  description = "(optional) Disable the server from executing the `mlock` syscall"
  default     = true
}

variable "vault_enable_ui" {
  type        = bool
  description = "(optional) Enable the Vault UI"
  default     = true
}

variable "vault_default_lease_ttl_duration" {
  type        = string
  description = "The default lease TTL expressed as a time duration in hours, minutes and/or seconds (e.g. `4h30m10s`)"
  default     = "1h"

  validation {
    condition     = can(regex("^([[:digit:]]+h)*([[:digit:]]+m)*([[:digit:]]+s)*$", var.vault_default_lease_ttl_duration))
    error_message = "Value must be a combination of hours (h), minutes (m) and/or seconds (s). e.g. `4h30m10s`"
  }
}

variable "vault_max_lease_ttl_duration" {
  type        = string
  description = "The max lease TTL expressed as a time duration in hours, minutes and/or seconds (e.g. `4h30m10s`)"
  default     = "768h"

  validation {
    condition     = can(regex("^([[:digit:]]+h)*([[:digit:]]+m)*([[:digit:]]+s)*$", var.vault_max_lease_ttl_duration))
    error_message = "Value must be a combination of hours (h), minutes (m) and/or seconds (s). e.g. `4h30m10s`"
  }
}

variable "vault_port_api" {
  type        = number
  description = "TCP port for Vault API listener"
  default     = 8200
}

variable "vault_port_cluster" {
  type        = number
  description = "TCP port for Vault cluster address"
  default     = 8201
}

variable "vault_tls_disable_client_certs" {
  type        = bool
  description = "Disable client authentication for the Vault listener. Must be enabled when tls auth method is used."
  default     = true
}

variable "vault_tls_require_and_verify_client_cert" {
  type        = bool
  description = "(optional) Require a client to present a client certificate that validates against system CAs"
  default     = false
}

variable "vault_seal_type" {
  type        = string
  description = "(optional) The seal type to use for Vault"
  default     = "gcpckms"

  validation {
    condition     = var.vault_seal_type == "shamir" || var.vault_seal_type == "gcpckms"
    error_message = "The seal type must be shamir or gcpckms."
  }
}

variable "auto_join_tag" {
  type        = list(string)
  description = "(optional) A list of a tag which will be used by Vault to join other nodes to the cluster. If left blank, the module will use the first entry in `tags`"
  default     = null
}

#------------------------------------------------------------------------------
# System paths and settings
#------------------------------------------------------------------------------
variable "additional_package_names" {
  type        = set(string)
  description = "List of additional repository package names to install"
  default     = []
}

variable "vault_user_name" {
  type        = string
  description = "Name of system user to own Vault files and processes"
  default     = "vault"
}

variable "vault_group_name" {
  type        = string
  description = "Name of group to own Vault files and processes"
  default     = "vault"
}

variable "systemd_dir" {
  type        = string
  description = "Path to systemd directory for unit files"
  default     = "/lib/systemd/system"
}

variable "vault_dir_bin" {
  type        = string
  description = "Path to install Vault Enterprise binary"
  default     = "/usr/bin"
}

variable "vault_dir_config" {
  type        = string
  description = "Path to install Vault Enterprise binary"
  default     = "/etc/vault.d"
}

variable "vault_dir_home" {
  type        = string
  description = "Path to hold data, plugins and license directories"
  default     = "/opt/vault"
}

variable "vault_dir_logs" {
  type        = string
  description = "Path to hold Vault file audit device logs"
  default     = "/var/log/vault"
}

variable "vault_plugin_urls" {
  type        = list(string)
  default     = []
  description = "(optional list) List of Vault plugin fully qualified URLs (example [\"https://releases.hashicorp.com/terraform-provider-oraclepaas/1.5.3/terraform-provider-oraclepaas_1.5.3_linux_amd64.zip\"] for deployment to Vault plugins directory)"
  # validation {
  #   condition     = "is url"
  #   error_message = "value is not url"
  # }
}

#-----------------------------------------------------------------------------------
# Networking
#-----------------------------------------------------------------------------------
variable "network" {
  type        = string
  description = "(optional) The VPC network to host the cluster in"
  default     = "default"
}

variable "subnetwork" {
  type        = string
  description = "(optional) The subnet in the VPC network to host the cluster in"
  default     = "default"
}

variable "network_project_id" {
  type        = string
  description = "(optional) The project that the VPC network lives in. Can be left blank if network is in the same project as provider"
  default     = null
}

variable "network_region" {
  type        = string
  description = "(optional) The region that the VPC network lives in. Can be left blank if network is in the same region as provider"
  default     = null
}

variable "cidr_ingress_https_allow" {
  type        = list(string)
  description = "CIDR ranges to allow HTTPS traffic inbound to Vault instance(s)."
  default     = ["0.0.0.0/0"]
}

#-----------------------------------------------------------------------------------
# DNS
#-----------------------------------------------------------------------------------
variable "create_cloud_dns_record" {
  type        = bool
  description = "Boolean to create Google Cloud DNS record for `vault_fqdn` resolving to load balancer IP. `cloud_dns_managed_zone` is required when `true`."
  default     = false
}

variable "cloud_dns_managed_zone" {
  type        = string
  description = "Zone name to create TFE Cloud DNS record in if `create_cloud_dns_record` is set to `true`."
  default     = null
}

#-----------------------------------------------------------------------------------
# Compute
#-----------------------------------------------------------------------------------
variable "node_count" {
  type        = number
  description = "(optional) The number of nodes to create in the pool"
  default     = 6
}

variable "vault_user_data_template" {
  type        = string
  description = "(optional) Alternative template file to provide for instance template metadata script. place the file in your local `./templates folder` no path required"
  default     = "google_vault_metadata.sh.tpl"
  validation {
    condition     = can(fileexists("../../templates/${var.vault_user_data_template}") || fileexists("./templates/${var.vault_user_data_template}"))
    error_message = "File `../../templates/${var.vault_user_data_template}` or `./templates/${var.vault_user_data_template} not found or not readable"
  }
}

variable "compute_image_family" {
  type        = string
  description = "(optional) The family name of the image, https://cloud.google.com/compute/docs/images/os-details,defaults to `Ubuntu`"
  default     = "ubuntu-2204-lts"
}

variable "compute_image_project" {
  type        = string
  description = "(optional) The project name of the image, https://cloud.google.com/compute/docs/images/os-details, defaults to `Ubuntu`"
  default     = "ubuntu-os-cloud"
}

# Rename to vm_custom_image_name (or similar)
variable "packer_image" {
  type        = string
  description = "(optional) The packer image to use"
  default     = null
}

variable "boot_disk_type" {
  type        = string
  description = "(optional) The disk type to use to create the boot disk"
  default     = "pd-balanced"

  validation {
    condition     = var.boot_disk_type == "pd-ssd" || var.boot_disk_type == "local-ssd" || var.boot_disk_type == "pd-balanced" || var.boot_disk_type == "pd-standard"
    error_message = "The value must be either pd-ssd, local-ssd, pd-balanced, pd-standard."
  }
}

variable "boot_disk_size" {
  type        = number
  description = "(optional) The disk size (GB) to use to create the boot disk"
  default     = 30
}

variable "vault_data_disk_type" {
  type        = string
  description = "(optional) The disk type to use to create the Vault data disk"
  default     = "pd-ssd"

  validation {
    condition     = var.vault_data_disk_type == "pd-ssd" || var.vault_data_disk_type == "local-ssd" || var.vault_data_disk_type == "pd-balanced" || var.vault_data_disk_type == "pd-standard"
    error_message = "The value must be either pd-ssd, local-ssd, pd-balanced, pd-standard."
  }
}

variable "vault_data_disk_size" {
  type        = number
  description = "(optional) The disk size (GB) to use to create the Vault data disk"
  default     = 100
}

variable "vault_audit_disk_type" {
  type        = string
  description = "(optional) The disk type to use to create the Vault audit log disk"
  default     = "pd-balanced"

  validation {
    condition     = var.vault_audit_disk_type == "pd-ssd" || var.vault_audit_disk_type == "local-ssd" || var.vault_audit_disk_type == "pd-balanced" || var.vault_audit_disk_type == "pd-standard"
    error_message = "The value must be either pd-ssd, local-ssd, pd-balanced, pd-standard."
  }
}

variable "vault_audit_disk_size" {
  type        = number
  description = "(optional) The disk size (GB) to use to create the Vault audit log disk"
  default     = 50
}

variable "machine_type" {
  type        = string
  description = "(optional) The machine type to use for the Vault nodes"
  default     = "n2-standard-2"
}

variable "metadata" {
  type        = map(string)
  description = "(optional) Metadata to add to the Compute Instance template"
  default     = null
}

variable "enable_auto_healing" {
  type        = bool
  description = "(optional) Enable auto-healing on the Instance Group"
  default     = false
}

variable "initial_auto_healing_delay" {
  type        = number
  description = "(optional) The time, in seconds, that the managed instance group waits before it applies autohealing policies"
  default     = 1200 #300

  validation {
    condition     = var.initial_auto_healing_delay >= 0 && var.initial_auto_healing_delay <= 3600
    error_message = "The value must be greater than or equal to 0 and less than or equal to 3600s."
  }
}

variable "enable_iap" {
  type        = bool
  default     = true
  description = "(Optional bool) Enable https://cloud.google.com/iap/docs/using-tcp-forwarding#console, defaults to `true`. "
}

#-----------------------------------------------------------------------------------
# IAM variables
#-----------------------------------------------------------------------------------
variable "google_service_account_iam_roles" {
  type        = list(string)
  description = "(optional) List of IAM roles to give to the Vault service account"
  default = [
    "roles/compute.viewer",
    "roles/secretmanager.secretAccessor",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  ]
}

#------------------------------------------------------------------------------
# GCS
#------------------------------------------------------------------------------
variable "vault_snapshot_gcs_bucket_name" {
  type        = string
  description = "Name of Google Cloud Storage bucket to hold Vault snapshots"
  nullable    = true
}

#-----------------------------------------------------------------------------------
# Load Balancer variables
#-----------------------------------------------------------------------------------
variable "load_balancing_scheme" {
  type        = string
  description = "(optional) Type of load balancer to use (INTERNAL, EXTERNAL, or NONE)"
  default     = "INTERNAL"

  validation {
    condition     = var.load_balancing_scheme == "INTERNAL" || var.load_balancing_scheme == "EXTERNAL" || var.load_balancing_scheme == "NONE"
    error_message = "The load balancing scheme must be INTERNAL, EXTERNAL, or NONE."
  }
}

variable "vault_health_endpoints" {
  type        = map(string)
  description = "(optional) The status codes to return when querying Vault's sys/health endpoint"
  default = {
    standbyok              = "true"
    perfstandbyok          = "true"
    activecode             = "200"
    standbycode            = "429"
    drsecondarycode        = "472"
    performancestandbycode = "473"
    sealedcode             = "503"

    # Allow unitialized clusters to be considered healthy. Default is 501.
    uninitcode = "200"
  }
}

variable "health_check_interval" {
  type        = number
  description = "(optional) How often, in seconds, to send a health check"
  default     = 30
}

variable "health_timeout" {
  type        = number
  description = "(optional) How long, in seconds, to wait before claiming failure"
  default     = 15
}
