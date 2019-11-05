#!/bin/bash
#Download & Install Oracle Java
mkdir /usr/lib/jvm
cd /usr/lib/jvm
wget http://dcubeservice_ftp@dcubeservices.com/www/typhon/jdk-8u231-linux-x64.tar.gz -P /home/usr/lib/jvm

#Extract the downloaded file 
tar -xvzf /usr/lib/jvm/jdk-8u231-linux-x64.tar.gz

#Delete the tar file
rm -Rf /usr/lib/jvm/jdk-8u231-linux-x64.tar.gz

#Update the existing PATH variable
echo "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/jvm/jdk1.8.0_231/bin:/usr/lib/jvm/jdk1.8.0_231/db/bin:/usr/lib/jvm/jdk1.8.0_231/jre/bin\"" >> /etc/environment
echo "J2SDKDIR=\"/usr/lib/jvm/jdk1.8.0_231\"" >> /etc/environment
echo "J2REDIR=\"/usr/lib/jvm/jdk1.8.0_231/jre*\"" >> /etc/environment
echo "JAVA_HOME=\"/usr/lib/jvm/jdk1.8.0_231\"" >> /etc/environment
echo "DERBY_HOME=\"/usr/lib/jvm/jdk1.8.0_231/db\"" >> /etc/environment

#Use update-alternatives to inform Ubuntu about the installed java paths.
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_231/bin/java" 0
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0_231/bin/javac" 0
sudo update-alternatives --set java /usr/lib/jvm/jdk1.8.0_231/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/jdk1.8.0_231/bin/javac

#Give the location of java and javac
update-alternatives --list java
update-alternatives --list javac

#Set JAVA_HOME
echo "export JAVA_HOME=\"/usr/lib/jvm/jdk1.8.0_231\"" >> /etc/profile
echo "export PATH=$JAVA_HOME/bin:$PATH" >> /etc/profile
source /etc/profile

# Install OpenSSH
apt-get update && apt-get install -y make gcc net-tools openssh-server

# Create ducc user & copy ssh credentials
useradd -m ducc -s /bin/bash
mkdir /home/ducc 
mkdir /home/ducc/.ssh
wget https://raw.githubusercontent.com/aleksey-hariton/uima-ducc-docker/master/ducc-head/id_rsa -P /home/ducc/.ssh/
wget https://raw.githubusercontent.com/aleksey-hariton/uima-ducc-docker/master/ducc-head/id_rsa.pub -P /home/ducc/.ssh/

# Download Uima-DUCC 3
wget http://ftp.halifax.rwth-aachen.de/apache//uima//uima-ducc-3.0.0/uima-ducc-3.0.0-bin.tar.gz -P /home/ducc

# Start SSH service
service ssh start
#Set Permissions
chmod 700 /home/ducc/.ssh
chmod 600 /home/ducc/.ssh/id_rsa
chmod +r /home/ducc/.ssh/id_rsa.pub
cp /home/ducc/.ssh/id_rsa.pub /home/ducc/.ssh/authorized_keys
echo "StrictHostKeyChecking=no" > /home/ducc/.ssh/config

# The same for root user
cp -Rf /home/ducc/.ssh/ /root/
chown -Rf root.root /home/ducc/.ssh/

# UIMA DUCC installation
mkdir /home/ducc/ducc_runtime
cd /home/ducc/ && tar xzf /home/ducc/uima-ducc-3.0.0-bin.tar.gz && mv apache-uima-ducc-3.0.0/* /home/ducc/ducc_runtime/
rm -Rf /home/ducc/apache-uima-ducc-3.0.0/
cd /home/ducc/ducc_runtime/admin/ && /home/ducc/ ducc_runtime/admin/ducc_post_install
chown ducc.ducc -Rf /home/ducc/
chmod 700 /home/ducc/apache-uima-ducc/admin/

# Create res folder to store the results
mkdir /tmp/res
chown ducc.ducc -Rf /tmp/res/
# Run check_ducc to check if UIMA is properly installed
export LOGNAME="ducc"
su - ducc -c "/home/ducc/ducc_runtime/admin/check_ducc"

# Install NFS (Filesystem Sharing)
apt-get update
apt install nfs-kernel-server

# Update list of nodes to share the folder with and restart service
echo "/home/ducc/ducc_runtime 1.1.1.1(rw,sync,no_subtree_check)" >> /etc/exports
exportfs –a
systemctl restart nfs-kernel-server

# Add Worker Node IP in hosts
# nano /etc/hosts

#Start DUCC
su - ducc -c "/home/ducc/ducc_runtime/admin/start_ducc" 

