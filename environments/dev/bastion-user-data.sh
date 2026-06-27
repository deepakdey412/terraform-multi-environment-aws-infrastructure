#!/bin/bash
# Bastion Host User Data Script - Ubuntu 22.04
# This script runs on Bastion Host startup

set -e

# Update system packages
apt-get update
apt-get upgrade -y

# Install essential packages for bastion
apt-get install -y \
    awscli \
    htop \
    wget \
    curl \
    vim \
    tmux \
    netcat

# Configure SSH settings for better security
cat <<EOF >> /etc/ssh/sshd_config
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
EOF

# Restart SSH service
systemctl restart sshd

# Create a message of the day
cat <<EOF > /etc/motd
========================================
   BASTION HOST - Dev Environment
========================================
Ubuntu 22.04 LTS
This is a jump host for accessing
private subnet resources.

Use this host to SSH into private
application instances only.
========================================
EOF

# Log completion
echo "Bastion Host initialization completed at $(date)" >> /var/log/user-data.log
