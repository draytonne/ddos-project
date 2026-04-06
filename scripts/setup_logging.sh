#!/bin/bash
# Log dropped packets with prefix tags for easy grep later
sudo iptables -A INPUT -m limit --limit 5/min \
  -j LOG --log-prefix '[IPTABLES-DROP] ' --log-level 4

# Create log file
sudo touch /var/log/iptables.log
sudo chmod 644 /var/log/iptables.log

echo "Logging rules added"
sudo iptables -L INPUT -n -v
