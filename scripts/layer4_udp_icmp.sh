#!/bin/bash
echo "=== Applying Layer 4: UDP and ICMP flood defense ==="

# UDP rate limiting — allow 100 packets/sec per source IP, drop excess
sudo iptables -A INPUT -p udp \
  -m hashlimit \
  --hashlimit-name udp_limit \
  --hashlimit-above 100/sec \
  --hashlimit-burst 200 \
  --hashlimit-mode srcip \
  -j LOG --log-prefix '[UDP-FLOOD] '

sudo iptables -A INPUT -p udp \
  -m hashlimit \
  --hashlimit-name udp_limit \
  --hashlimit-above 100/sec \
  --hashlimit-burst 200 \
  --hashlimit-mode srcip \
  -j DROP

# ICMP rate limiting — allow 10 pings/sec, drop excess
sudo iptables -A INPUT -p icmp \
  --icmp-type echo-request \
  -m limit --limit 10/sec --limit-burst 20 \
  -j ACCEPT

sudo iptables -A INPUT -p icmp \
  --icmp-type echo-request \
  -j LOG --log-prefix '[ICMP-FLOOD] '

sudo iptables -A INPUT -p icmp \
  --icmp-type echo-request -j DROP

echo "=== Layer 4 done ==="
sudo iptables -L INPUT -n -v --line-numbers
