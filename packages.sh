#!/bin/bash

update_and_upgrade() {
    print_status "Checking for system updates..."
    if apt list --upgradable 2>/dev/null | grep -q installed; then
        print_status "Upgrading system packages..."
        apt update
        apt safe-upgrade -y
        apt autoremove -y
    else
        print_status "System is up-to-date, no upgrades needed."
    fi
}

install_packages() {
    print_status "Installing essential packages..."
    apt install -y \
        curl \
        wget \
        git \
        ufw \
        fail2ban \
        htop \
        net-tools \
        unzip \
        sudo \
        software-properties-common \
        iptables-persistent
}