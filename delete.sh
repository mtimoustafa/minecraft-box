#!/bin/sh
set -u

if [ -z "${1+x}" ]; then
  echo "Format:"
  echo "./delete-instance.sh [server_name] [instance_region=\"us-east4\"]"
  exit 1
fi

instance_name="$1"
instance_region="${2:-us-east4}"

disk_name="$instance_name-disk"
ip_name="$instance_name-ip"
instance_zone="$instance_region-a"

echo "-----> Are you sure you want to delete the server $instance_name at $instance_region?"
echo "-----> This will delete the instance, its disk, and deregister its static IP address"
while true; do
  read -p "-----> [y/n]: " yn
  case $yn in
    [Yy]*) break;;
    [Nn]*) exit;;
    * ) ;;
  esac
done

echo "-----> Deregistering static IP address"
gcloud compute addresses delete "$ip_name" --region "$instance_region"
echo "-----> Deleting VM instance"
gcloud compute instances delete "$instance_name" --zone "$instance_zone"
echo "-----> Deleting virtual disk"
gcloud compute disks delete "$disk_name" --zone "$instance_zone"
