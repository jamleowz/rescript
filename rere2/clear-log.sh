#!/bin/bash
clear
echo -n > /var/log/xray/access.log
echo -n > /var/log/secure
echo -n > /var/log/auth.log
echo -n > /var/log/trojan-go/trojan-go.log
sudo sync
sudo echo 1 > /proc/sys/vm/drop_caches
sudo sync
sudo echo 2 > /proc/sys/vm/drop_caches
sudo sync
sudo echo 3 > /proc/sys/vm/drop_caches
rm -fr /var/cache/*
rm -fr ~/.cache/*
rm -fr /var/cache/.*
rm -fr ~/.cache/.*