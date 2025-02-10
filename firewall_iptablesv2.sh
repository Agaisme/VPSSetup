#!/bin/bash

configure_firewall_iptables() {
    print_status "Configuring iptables firewall..."
    print_status "This Script will Only Accept Traffic from Cloudflare..."

    # Flush existing rules
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT

    # Set default policies
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    # Allow established and related connections
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Allow SSH
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT

    # Allow Cloudflare IPs
    print_status "Retrieving Cloudflare IP ranges..."
    curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips_v4
    curl -s https://www.cloudflare.com/ips-v6 -o /tmp/cf_ips_v6

    while read ip; do
        iptables -A INPUT -s $ip -p tcp --dport 80 -j ACCEPT
        iptables -A INPUT -s $ip -p tcp --dport 443 -j ACCEPT
        iptables -A INPUT -s $ip -p tcp --dport 3000 -j ACCEPT
    done < /tmp/cf_ips_v4

    while read ip; do
        iptables -A INPUT -s $ip -p tcp --dport 80 -j ACCEPT
        iptables -A INPUT -s $ip -p tcp --dport 443 -j ACCEPT
        iptables -A INPUT -s $ip -p tcp --dport 3000 -j ACCEPT
    done < /tmp/cf_ips_v6

    # Save iptables rules
    iptables-save > /etc/iptables/rules.v4
    sudo iptables-save > /etc/iptables/rules.v4
    sudo ip6tables-save > /etc/iptables/rules.v6

    print_status "iptables firewall configuration complete."
}