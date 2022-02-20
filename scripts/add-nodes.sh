#!/usr/bin/env bash

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

echo "$(date) | ${GREEN}Adding nodes${NC}"

NODES=$(curl -s 'https://chia.keva.app' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

for NODE_IP in ${NODES}; do
 chia show -a "${NODE_IP}:8444"
done

echo "$(date) | ${GREEN}Done!${NC}"
