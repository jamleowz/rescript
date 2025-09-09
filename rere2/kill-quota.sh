#!/bin/bash

function send_log() {
    local user=$1
    local limit=$2
    local total=$3
    CHATID=$(cat /etc/funny/.chatid)
    KEY=$(cat /etc/funny/.keybot)
    TIME="10"
    TEXT="
<code>────────────────────</code>
<b>⚠️LIMIT QUOTA DICAPAI⚠️</b>
<code>────────────────────</code>
<code>Username  : </code><code>$user</code>
<code>Limit     : </code><code>$limit</code>
<code>Total     : </code><code>$total</code>
<code>Status    : </code><code>Deleted</code>
<code>────────────────────</code>
"
    curl -s --max-time $TIME -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" "https://api.telegram.org/bot$KEY/sendMessage" >/dev/null
}

function human_readable() {
    local -i bytes=$1
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$(( (bytes + 1023) / 1024 ))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$(( (bytes + 1048575) / 1048576 ))MB"
    else
        echo "$(( (bytes + 1073741823) / 1073741824 ))GB"
    fi
}

function check_quota() {
    local user=$1
    quota_file="/etc/xray/quota/$user"
    usage_file="/etc/xray/quota/${user}_usage"

    if [[ -f "$quota_file" && -f "$usage_file" ]]; then
        quota_limit=$(cat "$quota_file")
        usage=$(cat "$usage_file")

        if [[ $usage -ge $quota_limit ]]; then
            exp=$(grep -w "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
            sed -i "/^### $user $exp/,/^},{/d" /etc/xray/config.json
            systemctl restart xray

            readable_limit=$(human_readable "$quota_limit")
            readable_usage=$(human_readable "$usage")
            echo -e "Limit Quota Access\n=================\nUsername: $user\nLimit Quota: $readable_limit\nTotal Usage: $readable_usage\nStatus: deleted\n=================\n" >> /etc/xray/.quota.logs

            send_log "$user" "$readable_limit" "$readable_usage"

            rm -rf "$quota_file"
            rm -rf "$usage_file"
        fi
    fi
}

function process_quota() {
    users=$(grep '^###' /etc/xray/config.json | cut -d ' ' -f 2 | sort | uniq)

    for user in $users; do
        check_quota "$user"
    done
}

process_quota