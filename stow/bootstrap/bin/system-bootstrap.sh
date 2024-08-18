#!/bin/bash

# source $HOME/.profile

COLOR_BLUE="\033[0;34m"
COLOR_RESET="\033[0m"

dir=$(dirname "$0")/../.system-bootstrap.d

for file in "$dir"/*; do
  echo -e "${COLOR_BLUE}==> Processing $(basename "$file")...${COLOR_RESET}"
  bash "$file"
done
