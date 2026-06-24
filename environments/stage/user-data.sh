#!/bin/bash
# User Data Script for EC2 Instance - Staging Environment
# This script runs on instance startup

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
    <title>Multi-Env Infrastructure - Staging</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
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
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
        }
        .badge {
            background: #f5576c;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 14px;
        }
        .info {
            margin-top: 20px;
            text-align: left;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎯 Multi-Environment Infrastructure</h1>
        <span class="badge">Staging Environment</span>
        <div class="info">
            <p><strong>Environment:</strong> ${environment}</p>
            <p><strong>S3 Bucket:</strong> ${s3_bucket_name}</p>
            <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
            <p><strong>Region:</strong> <span id="region">Loading...</span></p>
        </div>
    </div>
    <script>
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(r => r.text())
            .then(id => document.getElementById('instance-id').textContent = id);
        fetch('http://169.254.169.254/latest/meta-data/placement/region')
            .then(r => r.text())
            .then(region => document.getElementById('region').textContent = region);
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

[Install]
WantedBy=multi-user.target
SERVICE

# Start web application
systemctl daemon-reload
systemctl enable webapp
systemctl start webapp

# Create a test file in S3
echo "Instance initialized at $(date)" > /tmp/init-log.txt
aws s3 cp /tmp/init-log.txt s3://${s3_bucket_name}/logs/$(hostname)-init.txt

# Log completion
echo "User data script completed successfully at $(date)" >> /var/log/user-data.log
