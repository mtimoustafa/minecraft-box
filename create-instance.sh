#!/bin/sh
set -u

instance_name="testy-test"
disk_name="testy-test-disk"
ip_name="testy-test-ip"
disk_size="10GB"
instance_zone="us-central1"

gcloud compute addresses create $ip_name \
  --region $instance_zone

gcloud compute instances create $instance_name \
  --image-family cos-stable \
  --image-project cos-cloud \
  --shielded-secure-boot \
  --create-disk name=$disk_name,image-project=cos-cloud,size=$disk_size,type=pd-ssd,auto-delete=no \
  --zone "$instance_zone-a" \
  --address $ip_name
