#!/bin/bash
#Download & Install Oracle Java
echo "==========Making JVM Directory=========="
mkdir /usr/lib/jvm
#cd /usr/lib/jvm
echo "==========JVM Directory Created Successfully=========="

echo "==========Downloading Oracle Java 8=========="
wget http://dcubeservices.com/typhon/jdk-8u231-linux-x64.tar.gz -P /usr/lib/jvm
echo "==========Java Downloaded Successfully=========="

#Extract the downloaded file 
echo "==========Extracting JAVA TAR File=========="
tar -xvzf /usr/lib/jvm/jdk-8u231-linux-x64.tar.gz -C /usr/lib/jvm
echo "==========Tar File Successfully Extracted=========="

#Delete the tar file
rm -Rf /usr/lib/jvm/jdk-8u231-linux-x64.tar.gz

#Update the existing PATH variable
echo "==================Updating PATH Variable===================="
sed -i "s/PATH =\".*/PATH=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/usr\/games:\/usr\/local\/games:\/usr\/lib\/jvm\/jdk1.8.0_231\/bin:\/usr\/lib\/jvm\/jdk1.8.0_231\/db\/bin:\/usr\/lib\/jvm\/jdk1.8.0_231\/jre\/bin\"/g" /etc/environment
echo "J2SDKDIR=\"/usr/lib/jvm/jdk1.8.0_231\"" >> /etc/environment
echo "J2REDIR=\"/usr/lib/jvm/jdk1.8.0_231/jre*\"" >> /etc/environment
echo "JAVA_HOME=\"/usr/lib/jvm/jdk1.8.0_231\"" >> /etc/environment
echo "DERBY_HOME=\"/usr/lib/jvm/jdk1.8.0_231/db\"" >> /etc/environment
echo "==================PATH Variable Updated Successfully===================="

#Use update-alternatives to inform Ubuntu about the installed java paths.
echo "==================Updating Alternatives===================="
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_231/bin/java" 0
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0_231/bin/javac" 0
sudo update-alternatives --set java /usr/lib/jvm/jdk1.8.0_231/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/jdk1.8.0_231/bin/javac
echo "==================Alternatives Updated Successfully===================="

#Give the location of java and javac
update-alternatives --list java
update-alternatives --list javac

#Set JAVA_HOME
echo "==================SETTING JAVA HOME===================="
echo "export JAVA_HOME=\"/usr/lib/jvm/jdk1.8.0_231\"" >> /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
source /etc/profile
sleep 5
echo "==================JAVA HOME SET SUCCESSFULLY===================="

# Install OpenSSH
echo "==================INSTALLING OPEN-SSH===================="
apt-get update && apt-get install -y make gcc net-tools openssh-server
echo "==================OPEN-SSH INSTALLED SUCCESSFULLY===================="

# Create ducc user & copy ssh credentials
echo "==================ADDING DUCC USER WITH SSH CREDENTIALS===================="
useradd -m ducc -s /bin/bash
mkdir /home/ducc 
mkdir /home/ducc/.ssh
wget https://raw.githubusercontent.com/Salmation/typhon-pre-reqs/master/id_rsa -P /home/ducc/.ssh/
wget https://raw.githubusercontent.com/Salmation/typhon-pre-reqs/master/id_rsa.pub -P /home/ducc/.ssh/
echo "==================ADDING DUCC USER: SUCCESSFULL===================="

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

# Install NFS-Client (Filesystem Sharing)
apt-get update
apt-get install nfs-common

echo "============ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ================"
echo "============ Perform the following tasks to COMPLETE CONFIGURATION PROCESS ================"
echo "============ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ================"

echo "Mount Shared folder: mount serverIP:/home/ducc/ducc_runtime /home/ducc/ducc_runtime"
echo "Add Head Node IP in hosts: nano /etc/hosts"

echo "=================================== SETUP COMPLETE ======================================="
