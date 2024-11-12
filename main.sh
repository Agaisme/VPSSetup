#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}[*] $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root"
    exit 1
fi

# Source the other script files
. packages.sh
. python_setup.sh
. firewall_iptables.sh
. security_updates.sh
. fail2ban.sh

# Run the functions from the other scripts
update_and_upgrade
install_packages
setup_python_uv
configure_firewall_iptables
enable_security_updates
configure_fail2ban

# Final message
print_status "VPS setup complete! Please make note of the following:"
echo "1. SSH access is now key-based only"
echo "2. Root login is disabled"
echo "3. UFW is enabled with Cloudflare IPs whitelisted"
echo "4. Fail2ban is active"
echo "5. Automatic security updates are enabled"
echo "6. Python 3 and UV are installed with common packages"
echo "7. Basic tmux configuration is set up"
echo -e "\nPlease log out and log back in as $USERNAME to apply all changes"

# Cleanup
print_status "Cleaning up..."
apt autoremove -y
apt clean