#!/bin/bash

set -eo pipefail

export ETCD_PORT=${ETCD_PORT:-2379}
export HOST_IP=${HOST_IP:-localhost}
export ETCD=$HOST_IP:$ETCD_PORT

echo "[nginx] booting container. ETCD: $ETCD."

# Try to make initial configuration every 5 seconds until successful
until confd --onetime --log-level debug  --backend etcdv3 --node http://$ETCD ; do
    echo "[nginx] waiting for confd to create initial nginx configuration."
    sleep 5
done

# Put a continual polling `confd` process into the background to watch
# for changes every 10 seconds
confd --log-level debug  --backend etcdv3 --node http://$ETCD --watch  &
echo "[nginx] confd is now monitoring etcd for changes..."

# Start the Nginx service using the generated config
echo "[nginx] starting nginx service..."
service nginx start

# Follow the logs to allow the script to continue running
tail -f /var/log/nginx/*.log