# Example `HVD Default with KMS`

Example deployment using the `terraform-google-vault-enterprise` module.
Review the main [README](https://github.com/hashicorp/terraform-google-vault-enterprise-hvd/blob/0.2.0/README.md) for general usage and prerequisites.

## usage

Rename or copy and rename `terraform.auto.tfvars.example` file and populate as you require.

### debug

The `var.debug` feature is verbose output from the underlying module. The intended usage is `terraform apply -refresh -var debug=true`. This will populate additional outputs for review.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.33 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_terraform_google_vault_default"></a> [terraform\_google\_vault\_default](#module\_terraform\_google\_vault\_default) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_dns_managed_zone"></a> [cloud\_dns\_managed\_zone](#input\_cloud\_dns\_managed\_zone) | Zone name to create TFE Cloud DNS record in if `create_cloud_dns_record` is set to `true`. | `string` | `null` | no |
| <a name="input_create_cloud_dns_record"></a> [create\_cloud\_dns\_record](#input\_create\_cloud\_dns\_record) | Boolean to create Google Cloud DNS record for `vault_leader_tls_servername` resolving to load balancer IP. `cloud_dns_managed_zone` is required when `true`. | `bool` | `false` | no |
| <a name="input_debug"></a> [debug](#input\_debug) | [Optional bool] Enable additional outputs available module outputs for debug purposes. | `bool` | `false` | no |
| <a name="input_gcp_kms_crypto_key"></a> [gcp\_kms\_crypto\_key](#input\_gcp\_kms\_crypto\_key) | (optional) The name of the KMS crypto key | `string` | `"vault-key"` | no |
| <a name="input_gcp_kms_key_ring"></a> [gcp\_kms\_key\_ring](#input\_gcp\_kms\_key\_ring) | (optional) The name of the KMS key ring | `string` | `"vault"` | no |
| <a name="input_gcp_kms_project"></a> [gcp\_kms\_project](#input\_gcp\_kms\_project) | (optional) The project the KMS key ring is in. Can be left blank if project is the same as provider | `string` | `null` | no |
| <a name="input_gcp_kms_region"></a> [gcp\_kms\_region](#input\_gcp\_kms\_region) | (optional) The region the KMS key ring is in. Can be left blank if region is the same as main region | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | (optional) The VPC network to host the cluster in | `string` | `"default"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | (optional) The number of nodes to create in the pool | `number` | `6` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | (required) The project ID to host the cluster in (required) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (optional) The region to host the cluster in | `string` | `"us-central1"` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | (optional) The subnet in the VPC network to host the cluster in | `string` | `"default"` | no |
| <a name="input_vault_leader_tls_servername"></a> [vault\_leader\_tls\_servername](#input\_vault\_leader\_tls\_servername) | (optional) TLS servername to use when trying to connect to the Raft cluster with HTTPS | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_debug"></a> [debug](#output\_debug) | n/a |
| <a name="output_loadbalancer_ip"></a> [loadbalancer\_ip](#output\_loadbalancer\_ip) | The load balancer IP address. |
<!-- END_TF_DOCS -->
