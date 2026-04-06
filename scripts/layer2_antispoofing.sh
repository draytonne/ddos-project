#!/bin/bash
echo "=== Applying Layer 2: Anti-spoofing & ACL rules ==="
# Allow established/related connections (keeps your SSH alive)
sudo iptables -A INPUT -m state \
  --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
sudo iptables -A INPUT -i lo -j ACCEPT

# Allow SSH from your school subnet only
sudo iptables -A INPUT -p tcp --dport 22 \
  -s 192.168.1.0/24 -j ACCEPT

# Drop invalid state packets
sudo iptables -A INPUT -m state --state INVALID \
  -j LOG --log-prefix '[INVALID-STATE] '
sudo iptables -A INPUT -m state --state INVALID -j DROP

# Drop XMAS packets (all TCP flags set — attack probe)
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL \
  -j LOG --log-prefix '[XMAS-DROP] '
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# Drop NULL packets (no TCP flags — attack probe)
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE \
  -j LOG --log-prefix '[NULL-DROP] '
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# Drop spoofed loopback packets
sudo iptables -A INPUT -s 127.0.0.0/8 ! -i lo \
  -j LOG --log-prefix '[SPOOF-DROP] '
sudo iptables -A INPUT -s 127.0.0.0/8 ! -i lo -j DROP

echo "=== Layer 2 done ==="
sudo iptables -L INPUT -n -v --line-numbers
