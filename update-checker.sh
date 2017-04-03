#!/bin/bash
set -e

if [ $# -lt 1 ]; then
cat << EOF
Usage: $0 172.18.1.2 machineA0 10.0.0.42
  Call this script with a bunch of machines or IPs it can SSH to
  You could pipe all your /etc/hosts entries to this script
  or strip hosts from ~/.ssh/config
EOF
exit 0
fi

TESTS="
if [ -f /etc/debian_version ]; then echo -n '  debian_verstion ';  cat /etc/debian_version; else echo Not a debian based os; exit 1; fi;
if apt-get update 2>&1 | grep -q ailed; then (echo '  Fetching failed'; exit 1) fi;
if apt-get --assume-no dist-upgrade | grep upgraded | grep -q '.*[1-9]..*'; then echo '  Updates available'; fi;
"
#echo -n 'last_updated '; tail -1 /var/log/apt/history.log | awk '{print \$2}';

for host in $@; do
  echo $host
  ssh -q -o PasswordAuthentication=no -o StrictHostKeyChecking=no $host "$TESTS" 2> /dev/null || true
done

exit 0
