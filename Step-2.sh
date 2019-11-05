#!/bin/bash
sudo -s <<EOF
chown ducc.ducc -Rf /home/ducc/
chmod 700 /home/ducc/ducc_runtime/admin/

# Create res folder to store the results
mkdir /tmp/res
chown ducc.ducc -Rf /tmp/res/
# Run check_ducc to check if UIMA is properly installed
export LOGNAME="ducc"
su - ducc -c "/home/ducc/ducc_runtime/admin/check_ducc"
EOF

# Install NFS (Filesystem Sharing)
apt-get update
apt install nfs-kernel-server

# Update list of nodes to share the folder with and restart service
echo "/home/ducc/ducc_runtime 1.1.1.1(rw,sync,no_subtree_check)" >> /etc/exports
exportfs –a
systemctl restart nfs-kernel-server

# Add Worker Node IP in hosts
# nano /etc/hosts
sudo -s <<EOF
#Start DUCC
su - ducc -c "/home/ducc/ducc_runtime/admin/start_ducc" 
EOF
