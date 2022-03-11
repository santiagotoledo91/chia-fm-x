#!/usr/bin/env bash

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

DB_CURRENT_FILE="${HOME}/chia/.chia/mainnet/db/blockchain_v2_mainnet.sqlite"
DB_BACKUP_1_FILE="${HOME}/chia/disks/chia-fd-1/blockchain_v2_mainnet.sqlite"
DB_BACKUP_2_FILE="${HOME}/chia/disks/chia-fd-2/blockchain_v2_mainnet.sqlite"

echo "$(date) | ${GREEN}Starting backup${NC}"

if [[ -f "${DB_BACKUP_1_FILE}" ]]; then
  echo "$(date) | ${GREEN}-> Moving ${DB_BACKUP_1_FILE} to ${DB_BACKUP_2_FILE}${NC}"
  mv "${DB_BACKUP_1_FILE}" "${DB_BACKUP_2_FILE}"
fi

echo "$(date) | ${GREEN}-> Backing up the blockchain db${NC}"
sqlite3 "${DB_CURRENT_FILE}" "VACUUM INTO '${DB_BACKUP_1_FILE}'"

echo "$(date) | ${GREEN}Backup complete!${NC}"
