# minecraft-box

Docker Hub Status 🐋 [![Build Status](https://cloud.drone.io/api/badges/mtimoustafa/minecraft-box/status.svg?ref=refs/heads/master)](https://cloud.drone.io/mtimoustafa/minecraft-box)

## Description
This is a proof-of-concept for a Minecraft server running on Google Cloud Platform (GCP). It uses [PaperMC](https://papermc.io/) and comes preloaded with [Dynmap](https://dev.bukkit.org/projects/dynmap), [EssentialsX Core and Protect](https://essentialsx.net/wiki/Module-Breakdown.html), and a pretty cool seed 😉

This can be run locally using Docker, or hosted on a [Compute Engine](https://cloud.google.com/compute) for more available access.

All you need is:
* Basic knowledge of bash
* Willingness to pay for hosting 💸 (optional - it's not much either)

I previously tried to host this on Heroku and AWS. The former had too little RAM on the lower tiers, and the latter is overkill for running one Docker container. GCP was a nice in-between, providing simplicity and flexibility at a fair cost. Feel free to try other deployment strategies, and let me know if you find anything better!

## Usage

### Run locally

First, [install Docker](https://www.docker.com/get-started), then clone this repository and navigate to it.

To spin up the server, run:
```bash
./start.sh
```
This will create a docker container tagged as `minecraft-box`, which will run the server, then sync all world and configuration files to a newly created folder, `minecraft/`. This will be used on all subsequent starts to persist server state. (If you ever need to reset the server, just delete `minecraft/`)

To connect to the server, use `localhost:25566` in your Minecraft client. Dynmap can be accessed through your browser at `localhost:8123`. You can check the server's logs using:
```bash
docker logs -f minecraft-box
```
To stop the server, simply run:
```bash
./stop.sh
```
This will shut the server down gracefully, then spin down the container.

### Run on Google Cloud Platform

[Sign up for GCP](https://cloud.google.com/) if you haven't already, then add your billing information. This is necessary to be able to create a VM instance and pay to keep it running.

Navigate to the Compute Engine page, then [create a new VM instance](https://cloud.google.com/compute/docs/quickstart-linux) using the [image on Docker Hub](https://hub.docker.com/r/mtimoustafa/minecraft-box) as a container image: `docker.io/mtimoustafa/minecraft-box`. An `e2-medium` machine on a default boot disk should be enough for a small server! Make sure to set the restart policy to "on failure", and to allow HTTP and HTTPS traffic.

In order to persist server state, [create, format, and mount a persistent disk](https://cloud.google.com/compute/docs/containers/configuring-options-to-run-containers#mounting_a_persistent_disk_as_a_data_volume) to your instance, then [mount it to Docker as a volume](https://cloud.google.com/compute/docs/disks/add-persistent-disk#attachdiskrunninginstance). The mount path should be `/minecraft-box/minecraft`, and mode should be "read/write".

Start/restart the VM instance, and check the logs to make sure the server is running. Note the instance's external IP, and use it to connect through the Minecraft client at `<external_ip>:25566`, or Dynmap through your browser at `<external_ip>:8123`.

For convenience, you can [reserve a static IP address](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address) on the instance so you don't have to note it every time. You can even tie it to a domain name and share it with your friends, family, pets, or anyone else 😄

### Configuration

All relevant MC server configuration files can be found under `minecraft-properties/`. At runtime, these are copied into the server files.

Similarly, use `plugins/` to add any plugin `.jar` files you'd like to run. Config files can be added in a `<plugin_name>/` folder. (To get the correct `plugin_name`, run the server, and check the folder that the plugin creates in `minecraft/plugins`. Use the config files in there as a template.) `plugins/` is also copied at runtime into the server files.

_Please do not edit files in `minecraft/` directly, as they will get overwritten! Instead, use the files in `minecraft-properties` and `plugins` as the ultimate source of truth._

## Future plans
In the future, I hope to turn this into an easy clone-and-deploy project, so anyone can create a GCP account, run a couple of scripts, and get a Minecraft server running in the cloud. Specifically, here's my laundry list:

* Use a configuration YAML file to set the server `.jar`, Java memory allocation, etc.
* Make an automation script for creating a GCP instance, instead of having to manually configure one.
* Smooth out the configuration and plugin management experience. (With docs!)
* Turn this into a VM image, so it can be pulled directly from GCP.
