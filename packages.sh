#!/bin/bash

update_and_upgrade() {
    print_status "Updating and upgrading system packages..."
    apt update
    apt full-upgrade -y
    apt autoremove -y
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
        software-properties-common
}