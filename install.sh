#!/usr/bin/env bash

# Colors
GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

echo "${GREEN}Installing...${NC}"

if grep -q "CONF_SWAPSIZE=100" /etc/dphys-swapfile; then
  echo "${GREEN}-> Increasing swap to 2GB (Max recommended for Raspberry Pi OS Lite 64 bits)${NC}"
  sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=4096/g' /etc/dphys-swapfile
  sudo sed -i 's/#CONF_MAXSWAP=2048/CONF_MAXSWAP=4096/g' /etc/dphys-swapfile
fi

if ! grep -q -E "^docker:" /etc/group; then
  echo "${GREEN}-> Creating the 'docker' group${NC}"
  sudo groupadd docker
fi

if ! groups | grep -q "docker"; then
  echo "${GREEN}-> Adding ${USER} to 'docker' group ${NC}"
  sudo usermod -aG docker "${USER}"
fi

if ! grep -q "# Custom config" ~/.profile; then
  echo "${GREEN}-> Configuring bash profile${NC}"
  cat <<EOT | sudo tee -a ~/.profile
# Custom config
DOCKER_COMPOSE="docker-compose -f ${HOME}/chia/docker-compose.yml -f ${HOME}/chia/docker-compose.override.yml"
CHIA="\${DOCKER_COMPOSE} exec chia venv/bin/chia"
chia=\$CHIA

alias bash-edit="vim ~/.profile"
alias bash-reload="source ~/.profile"

alias chia-enter="\${DOCKER_COMPOSE} exec chia bash"
alias chia-status="\${CHIA} show -s"
alias chia-farm-summary="\${CHIA} farm summary"
alias chia-wallet-get-address="${CHIA} wallet get_address"
alias chia-wallet-show="\${CHIA} wallet show"
alias chia-logs="\${DOCKER_COMPOSE} logs -tf --tail="50" chia"
alias chia-logs-wallet="\${DOCKER_COMPOSE} logs -tf --tail="50" chia | grep --color=never 'wallet'"
alias chia-logs-blockchain="\${DOCKER_COMPOSE} logs -tf --tail="50" chia | grep --color=never 'Added blocks'"
alias chia-logs-backup="cat ~/chia/logs/chia--backup.log"

alias chia--add-nodes="\${DOCKER_COMPOSE} exec -d chia /scripts/chia--add-nodes.sh"
alias chia--backup="bash ~/chia/scripts/chia--backup.sh"
alias chia--restore="bash ~/chia/scripts/chia--restore.sh"
alias chia--update="${DOCKER_COMPOSE} stop chia && ${DOCKER_COMPOSE} pull chia && ${DOCKER_COMPOSE} up --build -d chia"

alias scrutiny-collect-metrics="bash ~/chia/scripts/scrutiny-collect-metrics.sh"
alias scrutiny--update="${DOCKER_COMPOSE} stop scrutiny && ${DOCKER_COMPOSE} pull scrutiny && ${DOCKER_COMPOSE} up --build -d scrutiny"

alias chiadog--update="${DOCKER_COMPOSE} stop chiadog && ${DOCKER_COMPOSE} pull chiadog && ${DOCKER_COMPOSE} up --build -d chiadog"
EOT
fi

echo "${GREEN}-> Installing needed packages${NC}"

sudo apt update
sudo apt upgrade -y
sudo apt install -y vim nmap smartmontools docker.io docker-compose sqlite3 screen
sudo apt autoclean
sudo apt autoremove

# TODO secure!
#echo "${GREEN}-> Configuring Firewall${NC}"
#sudo ufw allow ${SSH_PORT} comment "SSH"
#sudo ufw allow 8444 comment "Chia daemon"
#sudo ufw allow from 192.168.31.200 to any port 55400 proto tcp comment "Chia UI @ Desktop"
#sudo ufw allow from 192.168.31.202 to any port 55400 proto tcp comment "Chia UI @ MacBook Pro"
#sudo ufw enable

if ! grep -q "cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 usb-storage.quirks=174c:1153:u,0bc2:3343:u" /boot/cmdline.txt; then
  echo "${GREEN}-> Disabling UAS (Seagate 8TB disks S.M.A.R.T problem and slow SATA/USB 3.0 adapter fix)${NC}"
  echo "cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 usb-storage.quirks=174c:1153:u,0bc2:3343:u $(cat /boot/cmdline.txt)" | sudo tee /boot/cmdline.txt
fi

if grep -q "# Overclocking and disabling Wi-Fi and Bluetooth" /boot/config.txt; then
  echo "${GREEN}-> Already overclocked to 2Ghz! Already disabled Wi-Fi and Bluetooth!${NC}"
else
  echo "${GREEN}-> Overclocking to 2Ghz${NC}"
  echo -e "\n# Overclocking and disabling Wi-Fi and Bluetooth\n\n## Overclocking\nover_voltage=6\narm_freq=2000\n\n## Wi-Fi disable\ndtoverlay=disable-wifi\n\n## Bluetooth disable\ndtoverlay=disable-bt" | sudo tee -a /boot/config.txt
fi

if [[ $(find ~/chia/disks -maxdepth 1 -name 'chia-fd-*' | wc -l | xargs ) != 6 ]]; then
  echo "${GREEN}-> Creating farmer disks mount points${NC}"
  mkdir -p ~/chia/disks/chia-fd-1
  mkdir -p ~/chia/disks/chia-fd-2
  mkdir -p ~/chia/disks/chia-fd-3
  mkdir -p ~/chia/disks/chia-fd-4
  mkdir -p ~/chia/disks/chia-fd-5
  mkdir -p ~/chia/disks/chia-fd-6

  sudo chmod -R 755 ~/chia/disks/
fi

if ! grep -q "# Chia farmer disks" /etc/fstab; then
  echo "${GREEN}-> Configuring automount, adding the entries to the /etc/fstab${NC}"
  cat <<EOT | sudo tee -a /etc/fstab
# Chia farmer disks
LABEL=chia-fd-1    /home/pi/chia/disks/chia-fd-1    ext4    defaults,nofail    0    2
LABEL=chia-fd-2    /home/pi/chia/disks/chia-fd-2    ext4    defaults,nofail    0    2
LABEL=chia-fd-3    /home/pi/chia/disks/chia-fd-3    ext4    defaults,nofail    0    2
LABEL=chia-fd-4    /home/pi/chia/disks/chia-fd-4    ext4    defaults,nofail    0    2
LABEL=chia-fd-5    /home/pi/chia/disks/chia-fd-5    ext4    defaults,nofail    0    2
LABEL=chia-fd-6    /home/pi/chia/disks/chia-fd-6    ext4    defaults,nofail    0    2
EOT
fi

if [[ ! -f "docker-compose.override.yml" ]];then
  echo "${GREEN}-> Creating docker-compose.override.yml${NC}"
  cp "docker-compose.override.example.yml" "docker-compose.override.yml"
fi

if [[ ! -f ".chiadog/config.yaml" ]];then
  echo "${GREEN}-> Creating .chiadog/config.yaml${NC}"
  cp ".chiadog/config.example.yaml" ".chiadog/config.yaml"
fi

echo "${GREEN}Installation finished!${NC}"
read -n 1 -s -r -p "${RED}-> Press any key to reboot...${NC}"
sudo reboot now
