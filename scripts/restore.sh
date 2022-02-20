#!/usr/bin/env bash

RESTORE_WALLET=$1
RESTORE_DB=$2

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

DOCKER_COMPOSE="docker-compose -f ${HOME}/chia/docker-compose.yml -f ${HOME}/chia/docker-compose.override.yml"

BKP1="${HOME}/chia/disks/chia-fd-1/chia-backup"

if [[ -z $RESTORE_WALLET ]] || [[ -z $RESTORE_DB ]];then
  echo "$(date) | ${RED}Whoops! Specify if you want to restore wallet and db, I.e: 'bash restore.sh true true'${NC}"
  exit 1
fi

if ! sudo test -d "${BKP1}"; then
  echo "$(date) | ${RED}Whoops! Looks like there is no backup on ${BKP1}${NC}"
  exit 1
fi

echo "$(date) | ${GREEN}Starting restore${NC}"

echo "$(date) | ${GREEN}-> Stopping chia${NC}"
${DOCKER_COMPOSE} stop chia

if [[ "${RESTORE_WALLET}" == "true" ]]; then
  echo "$(date) | ${GREEN}-> Restoring wallet backup from ${BKP1}${NC}"
  rm -rf ~/chia/.chia/mainnet/wallet
  mkdir -p ~/chia/.chia/mainnet/wallet/db
  cp -r ~/chia/disks/chia-fd-1/chia-backup/blockchain_wallet_v2_mainnet_*.sqlite ~/chia/.chia/mainnet/wallet/db/
fi

if [[ "${RESTORE_DB}" == "true" ]]; then
  echo "$(date) | ${GREEN}-> Restoring db backup from ${BKP1}${NC}"
  rm -rf ~/chia/.chia/mainnet/db
  mkdir -p ~/chia/.chia/mainnet/db
  cp -r ~/chia/disks/chia-fd-1/chia-backup/blockchain_v2_mainnet.sqlite ~/chia/.chia/mainnet/db/
fi

echo "$(date) | ${GREEN}-> Starting chia${NC}"
${DOCKER_COMPOSE} start chia

echo "$(date) | ${GREEN}-> Adding nodes to speed up the sync${NC}"
${DOCKER_COMPOSE} exec -d chia bash /scripts/add-nodes.sh

echo "$(date) | ${GREEN}Done!${NC}"

