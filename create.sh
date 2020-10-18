#!/bin/sh
set -u

if [ -z "${1+x}" ]; then
  echo "Format:"
  echo "./create-instance.sh [server_name] [image_tag=\"\"] [disk_size=\"10GB\"] [instance_region=\"us-east4\"]"
  exit 1
fi

server_name=$1
image_tag="${2:-latest}"
disk_size="${3:-10GB}"
instance_region="${4:-us-east4}"

instance_name="$server_name"
disk_name="$server_name-disk"
ip_name="$server_name-ip"
instance_zone="$instance_region-a"

echo "-----> Creating static IP address for VM instance"
gcloud compute addresses create "$ip_name" --region "$instance_region"

echo "-----> Creating VM instance"
gcloud compute instances create-with-container "$instance_name" \
  --machine-type e2-medium \
  --image-family cos-stable \
  --image-project cos-cloud \
  --zone "$instance_zone" \
  --address "$ip_name" \
  --container-image "docker.io/mtimoustafa/minecraft-box:$image_tag" \
  --create-disk name="$disk_name",image-project=cos-cloud,size="$disk_size",type=pd-ssd,auto-delete=no \
  --container-mount-disk name="$disk_name",mount-path=/minecraft-box/minecraft \
  --container-restart-policy on-failure

# After creating a disk, we have to format and mount it inside the instance itself
# See: https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting
echo "-----> Mounting and formatting virtual disk"
command='
device_id="$(sudo lsblk | grep '"$disk_name"' | awk '\''{print $1}'\'')" &&
mnt_dir="'"$disk_name"'" &&
uuid_value="$(sudo blkid /dev/sdb | awk '\''{print $2}'\'' | sed -r '\''s/UUID=|"//g'\'')" &&
sudo mkfs.ext4 -F -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/"$device_id";
sudo mkdir -p /mnt/disks/"$mnt_dir" &&
sudo mount -o discard,defaults /dev/"$device_id" /mnt/disks/"$mnt_dir";
sudo chmod a+w /mnt/disks/"$mnt_dir" &&
sudo cp /etc/fstab /etc/fstab.backup &&
sudo blkid /dev/"$device_id" &&
echo "UUID=$uuid_value /mnt/disks/$mnt_dir ext4, discard,defaults 0 2" | sudo tee -a /etc/fstab &&
echo "Successfully formatted and mounted disk onto instance"
'
gcloud compute ssh "$instance_name" --command "$command"

echo "-----> Restarting instance for mount to take effect"
gcloud compute instances stop "$instance_name"
gcloud compute instances start "$instance_name"

external_ip="$(gcloud compute addresses list | grep "$ip_name" | awk '{print $2}')"
echo "-----> Server created successfully! Please give it some minutes to come online before using it."
echo "-----> IP address: $external_ip:25566"
