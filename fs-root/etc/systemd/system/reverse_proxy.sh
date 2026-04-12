#!/bin/bash
set -euo pipefail

# The destination server should have done;
# useradd -r -m -d /home/sshtunnel -s /usr/sbin/nologin sshtunnel
# mkdir -p /home/sshtunnel/.ssh
# vim /home/sshtunnel/.ssh/known_hosts # /home/sshtunnel/.ssh/id_rsa.pub from this machine goes into known_hosts, the line should start with;
# command="echo 'tunnel only'",no-agent-forwarding,no-X11-forwarding,no-pty ssh-rsa
TUNNEL_ADDRESS=tunnel.lent.ink
TUNNEL_PORT=8080 # this should be different for each device on your network
. /host.env # source TUNNEL_PORT

AUTOSSH_GATETIME=0
TUNNEL_USER=sshtunnel
#exec /usr/bin/ssh \
exec autossh -M 0 \
    -o "ServerAliveInterval 30" \
    -o "ServerAliveCountMax 3" \
    -o ExitOnForwardFailure=yes \
    -o StrictHostKeyChecking=accept-new \
    -p 22
    -R $TUNNEL_PORT:localhost:22 \
    -N \
    -i $HOME/.ssh/id_rsa \
    $TUNNEL_USER@$TUNNEL_ADDRESS
