#!/bin/sh
set -u

instance_name="testy-test"
disk_name="testy-test-disk"
ip_name="testy-test-ip"
instance_zone="us-central1"

gcloud compute addresses delete $ip_name \
  --region $instance_zone
gcloud compute instances delete $instance_name \
  --zone "$instance_zone-a"
gcloud compute disks delete $disk_name \
  --zone "$instance_zone-a"
