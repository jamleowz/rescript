#!/bin/bash
    warp -6 > /root/wgcf.conf
    clear
    echo -e "
    <= Your WARP IPv6 Wireguard Account =>
    ======================================
         Wireguard Configuration

    $(cat /root/wgcf.conf)
    ======================================
    "
    rm -fr /root/wgcf.conf