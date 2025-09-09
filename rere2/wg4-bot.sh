#!/bin/bash
    warp -4 > /root/wgcf.conf
    clear
    echo -e "
    <= Your WARP IPv4 Wireguard Account =>
    ======================================
         Wireguard Configuration

    $(cat /root/wgcf.conf)
    ======================================
    "
    rm -fr /root/wgcf.conf