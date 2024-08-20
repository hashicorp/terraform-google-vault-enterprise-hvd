# Troubleshooting

## Metadata script

GCP uses a go app called `google_metadata_scrpt_runner`. **GCP DOES NOT support CLOUD-INIT (even under RHEL) without help generally if your setting CLOUD init you need a custom image**

<https://cloud.google.com/compute/docs/instances/startup-scripts/linux>
<https://pkg.go.dev/github.com/GoogleCloudPlatform/guest-agent/google_metadata_script_runner#section-sourcefiles>

The script can be run locally from the instance

```sh
sudo google_metadata_script_runner startup
```

and you can view logs with;

```sh
sudo journalctl -u google-startup-scripts.service -f
```

<https://cloud.google.com/compute/docs/instances/startup-scripts/linux#rerunning>
under LFS the scripts can be found at

The most consistent method to review the script is the following

```shell
# see all the metadata of the instance
curl "http://metadata.google.internal/computeMetadata/v1/?recursive=true&alt=text" -H "Metadata-Flavor: Google"
# review the startup-script
curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/startup-script" -H "Metadata-Flavor: Google"
# pipe the script to a file and interrogate it with your editor of choice (vim etc)
curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/startup-script" -H "Metadata-Flavor: Google" > init.sh
```

You can edit and rerun the script remember to do so with `sudo`

To monitor the progress of the install (_user_data_ script/cloud-init process), SSH (or other similarly method of connectivity) into the EC2 instance and run `journalctl -xu cloud-final -f` to tail the logs (or remove the `-f` if the cloud-init process has finished).  If the operating system is Ubuntu, logs can also be viewed via `tail -f /var/log/cloud-init-output.log`.

### Remote access

you can do all the troubleshooting steps remotely with IAP access (enabled by default)

Discover the instances in your instance group.

```bash
gcloud compute instance-groups list-instances `${var.application_prefix}-vault-ig-mgr`
```
Sample Output:
```bash
NAME        ZONE           STATUS
vault-0jg7  us-central1-c  RUNNING
...

# tail the install log during deployment
gcloud compute ssh --zone "<your-zone>" "vault-ojg7" --tunnel-through-iap --project "<your-project>" -- sudo journalctl -u google-startup-scripts.service -f

# check the service status
gcloud compute ssh --zone "<your-zone>" "vault-ojg7" --tunnel-through-iap --project "<your-project>" -- sudo systemctl status vault.service

# review the vault config
gcloud compute ssh --zone "<your-zone>" "vault-ojg7" --tunnel-through-iap --project "<your-project>" -- sudo cat /etc/vault.d/vault.hcl

# manually start the vault server to observe errors
gcloud compute ssh --zone "<your-zone>" "vault-ojg7" --tunnel-through-iap --project "<your-project>" -- sudo vault server --config=/etc/vault.d/vault.hcl

# ssh to the instance
gcloud compute ssh --zone "<your-zone>" "vault-ojg7" --tunnel-through-iap --project "<your-project>"
```

## Autojoin

<https://support.hashicorp.com/hc/en-us/articles/11473152855955-Troubleshooting-Auto-Join-Issues-in-GCP>
