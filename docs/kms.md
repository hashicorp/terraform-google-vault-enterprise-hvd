# KMS

Based on the <https://cloud.google.com/kms/docs/create-encryption-keys> gcloud documentation.

The following will set up the default KMS variables from the example folder for illustration.

```sh
# `gcloud config list compute/region` if you want to validate your default region

gcloud kms keyrings create "vault" \
    --location "global"

gcloud kms keys create "vault-key" \
    --location "global" \
    --keyring "vault" \
    --purpose "encryption"

gcloud kms keys list \
    --location "global" \
    --keyring "vault"
```
