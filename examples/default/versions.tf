# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.33"
    }
    # tls = {
    #   source  = "hashicorp/tls"
    #   version = "~> 4.0"
    # }
  }

}

provider "google" {
  region  = var.region
  project = var.project_id
}

# provider "tls" {}
