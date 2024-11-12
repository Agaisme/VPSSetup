#!/bin/bash

configure_fail2ban() {
    print_status "Configuring fail2ban..."
    cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 6
bantime = 1600
findtime = 600
EOF

    print_status "Enabling and starting fail2ban..."
    systemctl enable fail2ban
    systemctl start fail2ban
}