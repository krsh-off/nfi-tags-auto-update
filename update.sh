#!/bin/bash

ROOT_PATH="/home/ubuntu"
NFI_PATH="${ROOT_PATH}/NostalgiaForInfinity/NostalgiaForInfinityNext.py"
FT_PATH="${ROOT_PATH}/freqtrade/user_data/strategies/NostalgiaForInfinityNext.py"
TG_API_KEY=""
TG_CHAT_ID=""

# Go to NFI directory
cd $(dirname ${NFI_PATH})

# Fetch latest tags
git fetch --tags

# Get tags names
latest_tag=$(git describe --tags `git rev-list --tags --max-count=1`)
current_tag=$(git describe --tags)

# Create a new branch with the latest tag name and copy the new version of the strategy
if [ "$latest_tag" != "$current_tag" ]; then
        git checkout tags/$latest_tag -b $latest_tag || git checkout $latest_tag 
        cp $NFI_PATH $FT_PATH

        curl -s --data "text=NFI is updated to tag: *${latest_tag}*%0A%0APlease \`/reload_config\` to get it loaded." \
                --data "parse_mode=markdown" \
                --data "chat_id=$TG_CHAT_ID" \
                "https://api.telegram.org/bot${TG_API_KEY}/sendMessage"
fi