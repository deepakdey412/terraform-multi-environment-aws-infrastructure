#!/bin/bash
# Bastion Host User Data Script
# This script runs on Bastion Host startup

set -e

# Update system packages
yum update -y

# Install essential packages for bastion
yum install -y \
    aws-cli \
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
This is a jump host for accessing
private subnet resources.

Use this host to SSH into private
application instances only.
========================================
EOF

# Log completion
echo "Bastion Host initialization completed at $(date)" >> /var/log/user-data.log
