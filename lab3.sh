#!/bin/bash

# Define the path to the configure-host.sh script
configure_script="./configure-host.sh"

# Server 1
echo "Transferring configure-host.sh to server1-mgmt..."
scp "$configure_script" "remoteadmin@server1-mgmt:/root/" && \
ssh "remoteadmin@server1-mgmt" "/root/configure-host.sh -name server1-mgmt -ip 172.16.1.10 -hostentry server1 192.168.16.10"
if [ $? -eq 0 ]; then
    echo "Configuration applied successfully on server1-mgmt."
else
    echo "Failed to apply configuration on server1-mgmt."
fi

# Server 2
echo "Transferring configure-host.sh to server2-mgmt..."
scp "$configure_script" "remoteadmin@server2-mgmt:/root/" && \
ssh "remoteadmin@server2-mgmt" "/root/configure-host.sh -name server2-mgmt -ip 172.16.1.11 -hostentry server2 192.168.16.11"
if [ $? -eq 0 ]; then
    echo "Configuration applied successfully on server2-mgmt."
else
    echo "Failed to apply configuration on server2-mgmt."
fi

echo "All configurations applied."
