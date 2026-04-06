#!/bin/bash
echo "=== Applying Layer 3: SYN flood defense ==="

# Enable SYN cookies at kernel level
sudo sysctl -w net.ipv4.tcp_syncookies=1
sudo sysctl -w net.ipv4.tcp_max_syn_backlog=2048
sudo sysctl -w net.ipv4.tcp_synack_retries=2

# Persist across reboots
echo 'net.ipv4.tcp_syncookies=1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog=2048' | sudo tee -a /etc/sysctl.conf

# Rate-limit new TCP SYN packets per source IP
# Allows burst of 10, then limits to 20 new connections/second
sudo iptables -A INPUT -p tcp --syn \
  -m hashlimit \
  --hashlimit-name syn_limit \
  --hashlimit-above 20/sec \
  --hashlimit-burst 10 \
  --hashlimit-mode srcip \
  -j LOG --log-prefix '[SYN-FLOOD] '

sudo iptables -A INPUT -p tcp --syn \
  -m hashlimit \
  --hashlimit-name syn_limit \
  --hashlimit-above 20/sec \
  --hashlimit-burst 10 \
  --hashlimit-mode srcip \
  -j DROP

echo "=== Layer 3 done ==="
sudo iptables -L INPUT -n -v --line-numbers
