#!/usr/bin/env bash

ROTATE=$1

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

DOCKER_COMPOSE="docker-compose -f ${HOME}/chia/docker-compose.yml -f ${HOME}/chia/docker-compose.override.yml"

BKP1="${HOME}/chia/disks/chia-fd-1/chia-backup"
BKP2="${HOME}/chia/disks/chia-fd-2/chia-backup"

echo  "$(date) | ${GREEN}Starting backup${NC}"

if [[ -d "${BKP1}" ]] && ! [[ "${ROTATE}" == "false" ]]; then
  echo "$(date) | ${GREEN}-> Current backup found, rotating${NC}"
  echo "$(date) | ${GREEN}--> Removing old backup${NC}"
  rm -rf "${BKP2}"
  echo "$(date) | ${GREEN}--> Moving ${BKP1} to ${BKP2}${NC}"
  mv "${BKP1}" "${BKP2}"
fi

echo "$(date) | ${GREEN}-> Creating backup directory${NC}"
mkdir -p "${BKP1}"

echo "$(date) | ${GREEN}-> Stopping chia${NC}"
${DOCKER_COMPOSE} stop chia

sleep 10

echo "$(date) | ${GREEN}-> Starting new backup${NC}"

echo "$(date) | ${GREEN}--> Backing up the wallet db${NC}"
cp ~/chia/.chia/mainnet/wallet/db/blockchain_wallet_v2_mainnet_*.sqlite "${BKP1}/"

echo "$(date) | ${GREEN}--> Backing up the blockchain db${NC}"
cp ~/chia/.chia/mainnet/db/blockchain_v2_mainnet.sqlite "${BKP1}/"

echo "$(date) | ${GREEN}-> Starting chia${NC}"
${DOCKER_COMPOSE} start chia

echo "$(date) | ${GREEN}-> Adding nodes to speed up the sync${NC}${NC}"
${DOCKER_COMPOSE} exec -d chia bash /scripts/add-nodes.sh

echo "$(date) | ${GREEN}Backup complete!${NC}"
