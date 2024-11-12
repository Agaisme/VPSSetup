#!/bin/bash

setup_python_uv() {
    print_status "Setting up Python and UV package installer..."
    apt install -y \
        python3 \
        python3-dev

    print_status "Installing UV package manager..."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    print_status "Setting up Python and UV aliases..."
    cat > /etc/profile.d/python.sh << 'EOF'
alias python=python3
EOF
    chmod +x /etc/profile.d/python.sh

    print_status "Installing Python packages with UV..."
    uv install \
        requests \
        pandas \
        numpy \
        ipython
}