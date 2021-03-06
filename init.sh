#!/bin/bash

# set variables
ACCESS_IP=$1

# install software
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent

# apt-get adds this to init.d/ so it will restart on boot
docker pull vulnerables/web-dvwa

# secure box
iptables -I INPUT 1 -s $ACCESS_IP -j ACCEPT
iptables -I INPUT 2 -j DROP
iptables -I OUTPUT 1 -d $ACCESS_IP -j ACCEPT
iptables -I OUTPUT 2 -j DROP
iptables -I FORWARD 1 -s $ACCESS_IP -j ACCEPT
iptables -I FORWARD 2 -d $ACCESS_IP -j ACCEPT
iptables -I FORWARD 3 -j DROP
iptables --policy INPUT DROP
iptables --policy OUTPUT DROP
iptables --policy FORWARD DROP
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

# use the --restart always so this container auto-runs everytime docker starts
# which combined with the init.d command above should mean container runs on every reboot
docker run --restart always -p 80:80 vulnerables/web-dvwa
