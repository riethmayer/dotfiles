#!/bin/bash

# source $HOME/.profile

COLOR_BLUE="\033[0;34m"
COLOR_RESET="\033[0m"

for file in $(dirname "$0")/../.system-bootstrap.d/*; do
  echo -e "${COLOR_BLUE}==> Processing $(basename $file)...${COLOR_RESET}"
  source $file
done
