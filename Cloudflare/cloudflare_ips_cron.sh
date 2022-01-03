#!/bin/bash

# Source:
# https://www.cloudflare.com/ips
# https://support.cloudflare.com/hc/en-us/articles/200169166-How-do-I-whitelist-CloudFlare-s-IP-addresses-in-iptables-

# Check internet connectivity first.
wget -q --spider https://www.cloudflare.com/ips-v4 && wget -q --spider https://www.cloudflare.com/ips-v6 > /dev/null 2>&1
# keep looping 10sec until we do have a correct repsonse (0 means reachable).
while [ $? -ne 0 ]; do
  sleep 10
  wget -q --spider https://www.cloudflare.com/ips-v4 && wget -q --spider https://www.cloudflare.com/ips-v6 > /dev/null 2>&1
done

# Network is up proceed.
for i in `curl https://www.cloudflare.com/ips-v4`; do /sbin/iptables -I INPUT -p tcp -m multiport --dports http,https -s $i -j ACCEPT; done
for i in `curl https://www.cloudflare.com/ips-v6`; do /sbin/ip6tables -I INPUT -p tcp -m multiport --dports http,https -s $i -j ACCEPT; done

# Block all the others.
# WARNING: If you get attacked and CloudFlare drops you, your site(s) will be unreachable. 
/sbin/iptables -A INPUT -p tcp -m multiport --dports http,https -j DROP
/sbin/ip6tables -A INPUT -p tcp -m multiport --dports http,https -j DROP
