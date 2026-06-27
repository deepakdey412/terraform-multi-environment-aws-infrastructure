#!/bin/bash
# Application Instance User Data Script - Dev Environment
# Runs on application instances in Private Subnet (Auto Scaling Group)

set -e

# Update system packages
yum update -y

# Install essential packages
yum install -y \
    aws-cli \
    git \
    htop \
    wget \
    curl \
    vim \
    amazon-cloudwatch-agent

# Configure CloudWatch Agent
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/messages"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/secure"
          },
          {
            "file_path": "/var/log/webapp.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/webapp"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "CustomApp/${environment}",
    "metrics_collected": {
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MemoryUtilization",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {
            "name": "used_percent",
            "rename": "DiskUtilization",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      }
    }
  }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json

# Create application directory
mkdir -p /opt/app
cd /opt/app

# Create a simple web application
cat <<'WEBAPP' > /opt/app/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Multi-Env Infrastructure - Dev (Private Subnet)</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            text-align: center;
            max-width: 600px;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
        }
        .badge {
            background: #667eea;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 14px;
        }
        .subnet-badge {
            background: #28a745;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            margin-left: 10px;
        }
        .info {
            margin-top: 20px;
            text-align: left;
        }
        .architecture {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            font-size: 12px;
            text-align: left;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Multi-Environment Infrastructure</h1>
        <span class="badge">Development Environment</span>
        <span class="subnet-badge">Private Subnet</span>
        <div class="info">
            <p><strong>Environment:</strong> ${environment}</p>
            <p><strong>S3 Bucket:</strong> ${s3_bucket_name}</p>
            <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
            <p><strong>Private IP:</strong> <span id="private-ip">Loading...</span></p>
            <p><strong>Availability Zone:</strong> <span id="az">Loading...</span></p>
        </div>
        <div class="architecture">
            <strong>Architecture:</strong><br>
            Internet → ALB (Public Subnet) → This Instance (Private Subnet)<br>
            Outbound: This Instance → NAT Gateway → Internet<br>
            SSH Access: Bastion Host (Public) → This Instance (Private)
        </div>
    </div>
    <script>
        const metadataBase = 'http://169.254.169.254/latest/meta-data/';
        
        fetch(metadataBase + 'instance-id')
            .then(r => r.text())
            .then(id => document.getElementById('instance-id').textContent = id)
            .catch(() => document.getElementById('instance-id').textContent = 'N/A');
            
        fetch(metadataBase + 'local-ipv4')
            .then(r => r.text())
            .then(ip => document.getElementById('private-ip').textContent = ip)
            .catch(() => document.getElementById('private-ip').textContent = 'N/A');
            
        fetch(metadataBase + 'placement/availability-zone')
            .then(r => r.text())
            .then(az => document.getElementById('az').textContent = az)
            .catch(() => document.getElementById('az').textContent = 'N/A');
    </script>
</body>
</html>
WEBAPP

# Install and configure simple web server (Python)
cat <<'SERVICE' > /etc/systemd/system/webapp.service
[Unit]
Description=Simple Web Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 -m http.server 80
Restart=always
StandardOutput=append:/var/log/webapp.log
StandardError=append:/var/log/webapp.log

[Install]
WantedBy=multi-user.target
SERVICE

# Start web application
systemctl daemon-reload
systemctl enable webapp
systemctl start webapp

# Create a test file in S3
echo "App instance initialized at $(date) in Private Subnet" > /tmp/init-log.txt
aws s3 cp /tmp/init-log.txt s3://${s3_bucket_name}/logs/$(hostname)-init.txt || true

# Log completion
echo "Application instance initialization completed at $(date)" >> /var/log/user-data.log
