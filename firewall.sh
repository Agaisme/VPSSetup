#!/bin/bash

configure_firewall() {
    print_status "Configuring UFW..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp

    print_status "Creating Cloudflare UFW script..."
    cat > /usr/local/bin/update-cloudflare-ips.sh << 'EOF'
#!/bin/bash

# Download Cloudflare IPs
curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips
curl -s https://www.cloudflare.com/ips-v6 >> /tmp/cf_ips

# Delete existing Cloudflare rules
ufw status numbered | grep "Cloudflare IP" | cut -d "[" -f2 | cut -d "]" -f1 | tac | xargs -I {} ufw --force delete {}

# Add new rules
for cfip in $(cat /tmp/cf_ips); do
    ufw allow proto tcp from $cfip to any port 80,443 comment 'Cloudflare IP'
done

# Cleanup
rm /tmp/cf_ips

# Reload UFW
ufw reload > /dev/null
EOF

    chmod +x /usr/local/bin/update-cloudflare-ips.sh

    print_status "Running initial Cloudflare IP update..."
    /usr/local/bin/update-cloudflare-ips.sh

    print_status "Setting up cron job for Cloudflare IP updates..."
    (crontab -l 2>/dev/null; echo "0 0 * * * /usr/local/bin/update-cloudflare-ips.sh") | crontab -

    print_status "Enabling and starting UFW..."
    ufw --force enable
}