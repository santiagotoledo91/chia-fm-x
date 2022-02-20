#!/usr/bin/env bash

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

DOCKER_COMPOSE="docker-compose -f ${HOME}/chia/docker-compose.yml -f ${HOME}/chia/docker-compose.override.yml"

echo "$(date) | ${GREEN}-> Updating S.M.A.R.T data${NC}"
${DOCKER_COMPOSE} exec scrutiny scrutiny-collector-metrics run
