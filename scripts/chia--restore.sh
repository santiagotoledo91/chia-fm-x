#!/usr/bin/env bash

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

DOCKER_COMPOSE="docker-compose -f ${HOME}/chia/docker-compose.yml -f ${HOME}/chia/docker-compose.override.yml"

DB_BACKUP_FILE="${HOME}/chia/disks/chia-fd-1/blockchain_v2_mainnet.sqlite"
DB_CURRENT_FILE="${HOME}/chia/.chia/mainnet/db/blockchain_v2_mainnet.sqlite"

if ! test -f "${DB_BACKUP_FILE}"; then
  echo "$(date) | ${RED}Whoops! Looks like ${DB_BACKUP_FILE} doesn't exist${NC}"
  exit 1
fi

echo "$(date) | ${GREEN}Starting restore${NC}"

echo "$(date) | ${GREEN}-> Stopping chia${NC}"
${DOCKER_COMPOSE} stop chia

echo "$(date) | ${GREEN}-> Clearing current db${NC}"
rm -f "${DB_CURRENT_FILE}*"

echo "$(date) | ${GREEN}-> Restoring backup from ${DB_BACKUP_FILE} to ${DB_CURRENT_FILE}${NC}"
cp "${DB_BACKUP_FILE}" "${DB_CURRENT_FILE}"

echo "$(date) | ${GREEN}-> Starting chia${NC}"
${DOCKER_COMPOSE} start chia

echo "$(date) | ${GREEN}Done!${NC}"
