#!/bin/bash

# Set color codes
NC='\e[0m'
GB='\e[32;1m'
YB='\e[33;1m'
RED='\e[31;1m'

# Read JSON input from stdin
read INPUT_DATA

# Parse JSON input using jq
User=$(echo "$INPUT_DATA" | jq -r '.username')
NewPassword=$(echo "$INPUT_DATA" | jq -r '.password')

# Check if the username exists
if id -u "$User" >/dev/null 2>&1; then

    # Change the user password
    echo -e "$NewPassword\n$NewPassword" | passwd "$User" >/dev/null 2>&1

    # Respond with success JSON
    OUTPUT=$(jq -n \
      --arg username "$User" \
      --arg password "$NewPassword" \
      '{message: "Password changed successfully", username: $username, new_password: $password}')

else
    # Respond with error JSON
    OUTPUT=$(jq -n \
      --arg error "Username does not exist" \
      '{error: $error}')
fi

# Detail Bot Notification via Telegram
CHATID=$(cat /etc/funny/.chatid)
KEY=$(cat /etc/funny/.keybot)
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
curl -s --max-time $TIME --data-urlencode "chat_id=$CHATID" --data-urlencode "text=$OUTPUT" $URL >/dev/null 2>&1

# Print the output JSON
clear
echo "$OUTPUT" | jq .