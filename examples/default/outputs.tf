# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "vault_cli_config" {
  value = <<-EOF
    Set the following environment variables to configure the Vault CLI:

    ${module.default_example.vault_cli_config}
  EOF
}