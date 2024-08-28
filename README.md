# Vault Enterprise HVD on GCP GCE

Terraform module aligned with HashiCorp Validated Designs (HVD) to deploy Vault Enterprise on Google Cloud Platform (GCP) using Compute Engine instances. This module deploys Vault Enterprise with integrated storage.

![HVD Vault Architecture diagram](https://raw.githubusercontent.com/hashicorp/terraform-aws-vault-enterprise-hvd/main/docs/images/080-hvd-vault-networking-diagram.png "HVD Vault Architecture diagram")

## Prerequisites

This module requires the following to already be in place in GCP:
- [A Google Cloud project](https://cloud.google.com/storage/docs/projects) with the following:
  - [A VPC network](https://cloud.google.com/vpc/docs/vpc)
  - [A Cloud NAT gateway](https://cloud.google.com/nat/docs/overview)
  - [Secret Manager API enabled](https://cloud.google.com/secret-manager/docs/overview)
  - [Cloud Key Management Service API enabled](https://cloud.google.com/kms/docs) with a Key Ring and Key created (if using auto-unseal)
  - [Cloud Resource Manager API enabled](https://cloud.google.com/resource-manager/docs)
- A [principal](https://cloud.google.com/iam/docs/overview) with the [Compute Admin](https://cloud.google.com/compute/docs/access/iam#compute.admin) role or equivalent

## Authentication to GCP

It is recommended to authenticate to GCP via the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) tool. If running Terraform non-interactively, you can use a Google Cloud Service Account.

### With the Google Cloud SDK

With the SDK installed locally, authenticate to GCP by running `gcloud auth application-default login`. You can then set the project for the module by setting the `GOOGLE_PROJECT` environment variable.

### With a Service Account

Create a dedicated GCP service account in the target project and download the key file. You can then set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to be used by Terraform along with the `GOOGLE_PROJECT` variable to set the appropriate project.

## Deployment

Upon first deployment, Vault servers will auto-join and form a fresh cluster. The cluster will be in an uninitialized, sealed state. An operator must then connect to the cluster to initialize Vault. If using Shamir seal, the operator must manually unseal each node. If auto-unseal is used via Google KMS, the Vault nodes will automatically unseal upon initialization.

## Examples

Example deployment scenarios can be found in the `examples` directory of this repo [here](examples/README.md). These examples cover multiple capabilities of the module and are meant to serve as a starting point for operators.

## Deployment Options

This module by default deploys on `ubuntu-os-cloud` this can be changed by updating the following;

- `var.compute_image_family`
- `var.compute_image_project`

or by creating  packer image and providing the `var.packer_image` see the [Packer](./docs/packer.md) for additional detail.

## TLS

There is a helper doc for tls cert generation should you need it [TLS](./docs/tls.md).

## Load Balancing

This module supports the deployment of Google's TCP Layer 4 load balancer to sit in front of the Vault cluster. The load balancer can be external (public IP) or internal (private IP) and is configured to use Vault's `sys/health` API endpoint to determine health status of Vault to ensure clients are always directed to a healthy instance when possible.

The variable `load_balancing_scheme` is used to dictate the type of load balancer that should be used and can be set as one of the following values:

- `INTERNAL` - Load balancer should receive an IP address on a private subnet
- `EXTERNAL` - Load balancer should receive a public IP address
- `NONE` - No load balancer should be provisioned

## KMS

This module supports both the Shamir and Auto Unseal (via Google Cloud KMS) seal mechanism. By default, the module will assume the Shamir method should be used. In the event Auto Unseal should be used, set the variable `vault_seal_type` to `gcp_kms` and set the following two additional variables:

- `gcp_kms_key_ring` - The name of the cryptographic key ring to use
- `gcp_kms_crypto_key` - The name of the cryptographic key to use

See [KMS](./docs/kms.md) docs for helper material on producing the required KMS inputs.

## Terraform configuration

[![Terraform Module Test](https://github.com/hashicorp-services/terraform-google-vault-enterprise/actions/workflows/terraform.yml/badge.svg)](https://github.com/hashicorp-services/terraform-google-vault-enterprise/actions/workflows/terraform.yml)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.33 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.34.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_iap](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_vault_health_checks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.vault_fr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_health_check.vault_auto_healing](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_instance_template.vault](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_region_backend_service.vault_bs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_compute_region_health_check.vault_hc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check) | resource |
| [google_compute_region_instance_group_manager.vault](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |
| [google_dns_record_set.vault](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_project_iam_member.vault_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.vault_iam_kms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.vault_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_network.network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_subnetwork.subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_dns_managed_zone.vault](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone) | data source |
| [google_netblock_ip_ranges.legacy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges) | data source |
| [google_netblock_ip_ranges.new](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_prefix"></a> [application\_prefix](#input\_application\_prefix) | (optional) The prefix to give to cloud entities | `string` | `"vault"` | no |
| <a name="input_auto_join_tag"></a> [auto\_join\_tag](#input\_auto\_join\_tag) | (optional) A list of a tag which will be used by Vault to join other nodes to the cluster. If left blank, the module will use the first entry in `tags` | `list(string)` | `null` | no |
| <a name="input_cidr_ingress_https_allow"></a> [cidr\_ingress\_https\_allow](#input\_cidr\_ingress\_https\_allow) | CIDR ranges to allow HTTPS traffic inbound to Vault instance(s). | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cloud_dns_managed_zone"></a> [cloud\_dns\_managed\_zone](#input\_cloud\_dns\_managed\_zone) | Zone name to create TFE Cloud DNS record in if `create_cloud_dns_record` is set to `true`. | `string` | `null` | no |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | (optional) Common labels to apply to GCP resources. | `map(string)` | `{}` | no |
| <a name="input_compute_image_family"></a> [compute\_image\_family](#input\_compute\_image\_family) | (optional) The family name of the image, https://cloud.google.com/compute/docs/images/os-details,defaults to `Ubuntu` | `string` | `"ubuntu-2204-lts"` | no |
| <a name="input_compute_image_project"></a> [compute\_image\_project](#input\_compute\_image\_project) | (optional) The project name of the image, https://cloud.google.com/compute/docs/images/os-details, defaults to `Ubuntu` | `string` | `"ubuntu-os-cloud"` | no |
| <a name="input_create_cloud_dns_record"></a> [create\_cloud\_dns\_record](#input\_create\_cloud\_dns\_record) | Boolean to create Google Cloud DNS record for `vault_leader_tls_servername` resolving to load balancer IP. `cloud_dns_managed_zone` is required when `true`. | `bool` | `false` | no |
| <a name="input_debug"></a> [debug](#input\_debug) | [Optional bool] Enable additional outputs available module outputs for debug purposes. | `bool` | `false` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | (optional) The disk size (GB) to use to create the disk | `number` | `100` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | (optional) The disk type to use to create the disk | `string` | `"pd-ssd"` | no |
| <a name="input_enable_auto_healing"></a> [enable\_auto\_healing](#input\_enable\_auto\_healing) | (optional) Enable auto-healing on the Instance Group | `bool` | `false` | no |
| <a name="input_enable_iap"></a> [enable\_iap](#input\_enable\_iap) | (Optional bool) Enable https://cloud.google.com/iap/docs/using-tcp-forwarding#console, defaults to `true`. | `bool` | `true` | no |
| <a name="input_gcp_kms_crypto_key"></a> [gcp\_kms\_crypto\_key](#input\_gcp\_kms\_crypto\_key) | (optional) The name of the KMS crypto key | `string` | `"vault-key"` | no |
| <a name="input_gcp_kms_key_ring"></a> [gcp\_kms\_key\_ring](#input\_gcp\_kms\_key\_ring) | (optional) The name of the KMS key ring | `string` | `"vault"` | no |
| <a name="input_gcp_kms_project"></a> [gcp\_kms\_project](#input\_gcp\_kms\_project) | (optional) The project the KMS key ring is in. Can be left blank if project is the same as provider | `string` | `null` | no |
| <a name="input_gcp_kms_region"></a> [gcp\_kms\_region](#input\_gcp\_kms\_region) | (optional) The region the KMS key ring is in. Can be left blank if region is the same as main region | `string` | `null` | no |
| <a name="input_google_service_account_iam_roles"></a> [google\_service\_account\_iam\_roles](#input\_google\_service\_account\_iam\_roles) | (optional) List of IAM roles to give to the Vault service account | `list(string)` | <pre>[<br>  "roles/compute.viewer",<br>  "roles/secretmanager.secretAccessor",<br>  "roles/cloudkms.cryptoKeyEncrypterDecrypter"<br>]</pre> | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | (optional) How often, in seconds, to send a health check | `number` | `30` | no |
| <a name="input_health_timeout"></a> [health\_timeout](#input\_health\_timeout) | (optional) How long, in seconds, to wait before claiming failure | `number` | `15` | no |
| <a name="input_initial_auto_healing_delay"></a> [initial\_auto\_healing\_delay](#input\_initial\_auto\_healing\_delay) | (optional) The time, in seconds, that the managed instance group waits before it applies autohealing policies | `number` | `1200` | no |
| <a name="input_load_balancing_scheme"></a> [load\_balancing\_scheme](#input\_load\_balancing\_scheme) | (optional) Type of load balancer to use (INTERNAL, EXTERNAL, or NONE) | `string` | `"INTERNAL"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | (optional) The machine type to use for the Vault nodes | `string` | `"e2-standard-2"` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | (optional) Metadata to add to the Compute Instance template | `map(string)` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | (optional) The VPC network to host the cluster in | `string` | `"default"` | no |
| <a name="input_network_project_id"></a> [network\_project\_id](#input\_network\_project\_id) | (optional) The project that the VPC network lives in. Can be left blank if network is in the same project as provider | `string` | `null` | no |
| <a name="input_network_region"></a> [network\_region](#input\_network\_region) | (optional) The region that the VPC network lives in. Can be left blank if network is in the same region as provider | `string` | `null` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | (optional) The number of nodes to create in the pool | `number` | `6` | no |
| <a name="input_packer_image"></a> [packer\_image](#input\_packer\_image) | (optional) The packer image to use | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | (required) The project ID to host the cluster in (required) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (optional) The region to host the cluster in | `string` | `"us-central1"` | no |
| <a name="input_skip_install_tools"></a> [skip\_install\_tools](#input\_skip\_install\_tools) | (optional) Skips installing required packages (unzip, jq, wget) | `bool` | `false` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | (optional) The subnet in the VPC network to host the cluster in | `string` | `"default"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (optional) A list containing tags to assign to all resources | `list(string)` | <pre>[<br>  "vault"<br>]</pre> | no |
| <a name="input_vault_api_port"></a> [vault\_api\_port](#input\_vault\_api\_port) | (optional) The port the Vault API will listen on | `string` | `"8200"` | no |
| <a name="input_vault_backend_storage"></a> [vault\_backend\_storage](#input\_vault\_backend\_storage) | (optional) The backend storage type to use, defaults to consul | `string` | `"integrated"` | no |
| <a name="input_vault_bin_directory"></a> [vault\_bin\_directory](#input\_vault\_bin\_directory) | (optional) The bin directory for the Vault binary | `string` | `"/usr/bin"` | no |
| <a name="input_vault_ca_bundle_secret"></a> [vault\_ca\_bundle\_secret](#input\_vault\_ca\_bundle\_secret) | (required) The name of the CA bundle secret in Secret Manager | `string` | n/a | yes |
| <a name="input_vault_cluster_port"></a> [vault\_cluster\_port](#input\_vault\_cluster\_port) | (optional) The port the Vault cluster port will listen on | `string` | `"8201"` | no |
| <a name="input_vault_data_directory"></a> [vault\_data\_directory](#input\_vault\_data\_directory) | (optional) The data directory for the Vault raft data | `string` | `"/opt/vault"` | no |
| <a name="input_vault_disable_mlock"></a> [vault\_disable\_mlock](#input\_vault\_disable\_mlock) | (optional) Disable the server from executing the `mlock` syscall | `bool` | `true` | no |
| <a name="input_vault_enable_ui"></a> [vault\_enable\_ui](#input\_vault\_enable\_ui) | (optional) Enable the Vault UI | `bool` | `true` | no |
| <a name="input_vault_health_endpoints"></a> [vault\_health\_endpoints](#input\_vault\_health\_endpoints) | (optional) The status codes to return when querying Vault's sys/health endpoint | `map(string)` | <pre>{<br>  "activecode": "200",<br>  "drsecondarycode": "472",<br>  "performancestandbycode": "473",<br>  "perfstandbyok": "true",<br>  "sealedcode": "503",<br>  "standbycode": "429",<br>  "standbyok": "true",<br>  "uninitcode": "501"<br>}</pre> | no |
| <a name="input_vault_home_directory"></a> [vault\_home\_directory](#input\_vault\_home\_directory) | (optional) The home directory for the Vault user | `string` | `"/etc/vault.d"` | no |
| <a name="input_vault_leader_tls_servername"></a> [vault\_leader\_tls\_servername](#input\_vault\_leader\_tls\_servername) | (optional) TLS servername to use when trying to connect to the Raft cluster with HTTPS | `string` | `null` | no |
| <a name="input_vault_license_secret"></a> [vault\_license\_secret](#input\_vault\_license\_secret) | (optional) The ARN of the license secret in AWS Secrets Manager | `string` | `null` | no |
| <a name="input_vault_private_key_secret"></a> [vault\_private\_key\_secret](#input\_vault\_private\_key\_secret) | (required) The name of the signed certificate's private key secret in Secret Manager | `string` | n/a | yes |
| <a name="input_vault_seal_type"></a> [vault\_seal\_type](#input\_vault\_seal\_type) | (optional) The seal type to use for Vault | `string` | `"shamir"` | no |
| <a name="input_vault_signed_cert_secret"></a> [vault\_signed\_cert\_secret](#input\_vault\_signed\_cert\_secret) | (required) The name of the signed certificate secret in Secret Manager | `string` | n/a | yes |
| <a name="input_vault_systemd_directory"></a> [vault\_systemd\_directory](#input\_vault\_systemd\_directory) | (optional) The directory for the systemd unit | `string` | `"/lib/systemd/system"` | no |
| <a name="input_vault_tls_disable_client_certs"></a> [vault\_tls\_disable\_client\_certs](#input\_vault\_tls\_disable\_client\_certs) | (optional) Disable client authentication for the Vault listener | `bool` | `true` | no |
| <a name="input_vault_tls_require_and_verify_client_cert"></a> [vault\_tls\_require\_and\_verify\_client\_cert](#input\_vault\_tls\_require\_and\_verify\_client\_cert) | (optional) Require a client to present a client certificate that validates against system CAs | `bool` | `false` | no |
| <a name="input_vault_user_data_template"></a> [vault\_user\_data\_template](#input\_vault\_user\_data\_template) | (optional) Alternative template file to provide for instance template metadata script. place the file in your local `./templates folder` no path required | `string` | `"google_vault_metadata.sh.tpl"` | no |
| <a name="input_vault_version"></a> [vault\_version](#input\_vault\_version) | (optional) The version of Vault to use | `string` | `"1.16.0+ent"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_loadbalancer_ip"></a> [loadbalancer\_ip](#output\_loadbalancer\_ip) | The external ip address of the forwarding rule. |
| <a name="output_user_data_template"></a> [user\_data\_template](#output\_user\_data\_template) | n/a |
| <a name="output_vault_data"></a> [vault\_data](#output\_vault\_data) | Vault utility output for first Vault connection and init. |
<!-- END_TF_DOCS -->
