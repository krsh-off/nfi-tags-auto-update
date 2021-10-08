#!/bin/bash

TG_TOKEN="1921275641:AAHQaw3w7VoY21P1el1TbBn2REUe2VEnuwI"
TG_CHAT_ID="943472491"
TG_FT_BOT_ID="omacoder_freqtrade_bot"
ROOT_PATH="/root"

NFI_PATH="${ROOT_PATH}/NostalgiaForInfinity/NostalgiaForInfinityNextGen.py"
FT_PATH="${ROOT_PATH}/freqtrade/user_data/strategies/NostalgiaForInfinityNextGen.py"
GIT_URL="https://github.com/iterativv/NostalgiaForInfinity"

# Go to NFI directory
cd $(dirname ${NFI_PATH})

# Fetch latest tags
git fetch --tags

# Get tags names
latest_tag=$(git describe --tags `git rev-list --tags --max-count=1`)
current_tag=$(git describe --tags)

# Create a new branch with the latest tag name and copy the new version of the strategy
if [ "$latest_tag" != "$current_tag" ]; then

        # Checkout to latest tag and update the NFI in Freqtrade folder
        git checkout tags/$latest_tag -b $latest_tag || git checkout $latest_tag 
        cp $NFI_PATH $FT_PATH

        # Get tag to which the latest tag is pointing
        latest_tag_commit=$(git rev-list -n 1 tags/${latest_tag})

        # Compose the main message send by the bot
        message="NFI is updated to tag: *${latest_tag}*"
        message+="%0A%0A"
        message+="Please [/reload_config](https://t.me/${TG_FT_BOT_ID}) to get it loaded."

        # Compose buttons for showing git changes and backtesting results
        keyboard="{\"inline_keyboard\":[[{\"text\":\"Changes\", \"url\":\"${GIT_URL}/compare/${current_tag}...${latest_tag}\"},{\"text\":\"Backtesting\", \"url\":\"${GIT_URL}/commit/${latest_tag_commit}\"}]]}"

        # Send the message
        curl -s --data "text=${message}" \
                --data "reply_markup=${keyboard}" \
                --data "chat_id=$TG_CHAT_ID" \
                --data "parse_mode=markdown" \
                "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
fi