# Chia raspberry farmer machine

This guide will help you to set up a Raspberry Pi 4 8GB to run as a Chia farmer

## Prerequisites

### Hardware
- Raspberry Pi 4 8GB
- 120GB SSD or more connected over USB
#### Software
- Raspberry Pi imager

## OS Install

### Setup Raspberry Pi to boot from USB
- Open **Raspberry pi imager**
- Flash the `USB Boot` image the into the SSD
- Connect the SSD to the Raspberry Pi 
- Turn it on and wait ~20 seconds, it will be automatically setup for you
- Done

### Install Raspberry Pi OS Lite (64-BIT)
- Open **Raspberry pi imager**
- Click on the cog icon and configure your OS settings (username and password, etc)
- Flash the configured `Raspberry Pi OS Lite (64-BIT)` image the into the SSD
- Connect the SSD to the Raspberry Pi
- Turn it on and wait for it to boot (up to 5 min)

### Execute the install script
- Login via ssh as `pi` (Defaults password is `raspberrypi`)
- Make sure you have **git** installed, otherwise install with `sudo apt install -y git`
- Clone this repository
  ```shell
  git clone https://github.com/santiagotoledo91/chia-raspberry-farmer-machine.git ~/chia && cd ~/chia
  ```
- And run the installation script
  ```shell
  bash install.sh
  ```
- Customize your `config docker-compose.override.yml` and .`chiadog/config.yaml`
- Start containers
  ```shell
  docker-compose up -d
  ```
- Chown the chia folders
  ```shell
  sudo chown -R pi:pi .chia*
  ```
- Add your keys
  ```shell
  ${chia} keys add
  ```
- Restore your backup (Make sure it exists )
  ```shell
  chia--restore true true
  ```
### Set up the crons
- Open the crontab
  ```shell
  crontab -e
  ```
- Add the following entries
  ```shell
  0 7 * * 1 ~/chia/scripts/backup.sh >> ~/chia/logs/backup.log 2>&1
  0 * * * 1 ~/chia/scripts/scrutiny-update.sh >> ~/chia/logs/scrutiny-update.log 2>&1
  ```
## Monitoring
### Scrutini (S.M.A.R.T)
- Go to `http://x.x.x.x:81`
### Netdata (Performance)
- Go to `http://x.x.x.x:82`


