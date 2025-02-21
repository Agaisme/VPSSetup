#!/bin/bash
#  NEED TO SUDO SU FIRST (FOR DOCKER)

echo "[+] Checking if iptables-persistent is installed..."
if ! dpkg -l | grep -q iptables-persistent; then
    echo "[+] iptables-persistent not found. Installing..."
    sudo apt update
    sudo apt install -y iptables-persistent
else
    echo "[+] iptables-persistent is already installed."
fi

echo "[+] Checking if netfilter-persistent service is enabled..."
if sudo systemctl is-enabled netfilter-persistent.service >/dev/null 2>&1; then
    echo "[+] netfilter-persistent service is enabled."
else
    echo "[+] netfilter-persistent service is not enabled."
fi

echo "[+] Fill the rule configuration..."
iptables -F
#iptables -X
#iptables -t nat -F
#iptables -t nat -X
#iptables -t mangle -F
#iptables -t mangle -X

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 123 -j ACCEPT


iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 123 -j ACCEPT

iptables -L DOCKER-USER >/dev/null 2>&1 || iptables -N DOCKER-USER
iptables -A DOCKER-USER -s 172.17.0.0/16 -d 172.17.0.0/16 -j RETURN
iptables -A DOCKER-USER -s 172.18.0.0/16 -d 172.18.0.0/16 -j RETURN
iptables -A DOCKER-USER -s 172.19.0.0/16 -d 172.19.0.0/16 -j RETURN
iptables -A DOCKER-USER -s 172.20.0.0/16 -d 172.20.0.0/16 -j RETURN
iptables -A DOCKER-USER -s 10.0.1.0/24 -d 10.0.1.0/24 -j RETURN

# Fetch latest Cloudflare IPv4 & IPv6 lists
# CLOUDFLARE_IPS_V4=$(curl -s https://www.cloudflare.com/ips-v4)

# Allow Cloudflare IPs Only
# for ipc in $CLOUDFLARE_IPS_V4; do
#    iptables -A DOCKER-USER -s "$ipc" -p tcp -m multiport --dports http,https,3000 -j RETURN
# done

# Allow All IPs
iptables -A DOCKER-USER -p tcp -m multiport --dports 80,443,3000 -j RETURN


iptables -A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN
iptables -A DOCKER-USER -j DROP

echo "[+] Saving firewall rules..."
sudo netfilter-persistent save 