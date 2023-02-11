#!/bin/bash
# John Lutz
# 11 Feb 2023

# chmod a+x <filename> to set execute permissions
echo -e " connected to target";

echo -e "\n making yum cache" ;
sudo yum makecache

echo -e "\n installing ssh & pdsh \n" ;
sudo yum -y install openssh-server openssh-clients
sudo yum -y install pdsh

echo -e "\n installing java" ;
sudo yum -y install java-devel
java -version ;

echo -e "\n installing hadoop" ;
# https://www.geeksforgeeks.org/bash-scripting-how-to-check-if-file-exists/

if test -d "/usr/local/hadoop"; then
    echo "hadoop has already been extracted and moved"
else
    echo " /usr/local/hadoop folder missing"
    if test -f "hadoop-3.3.4.tar.gz" ; then
        echo " file exists" ;
    else
        echo " file not found, downloading hadoop" ;
        wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz ;
    fi
        echo " extracting & moving hadoop" ;
        tar xvfz hadoop-3.3.4.tar.gz ;
        sudo mv hadoop-3.3.4 /usr/local/hadoop ;
fi

which java ;
readlink -f $(which java) ;

#sudo nano /usr/local/hadoop/etc/hadoop/hadoop-env.sh ;
#Under the line
# export JAVA_HOME
#Add the line
#export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")




# run me using this command
# ssh -t LutzD00D@pc88.cloudlab.umass.edu < centos_single_node.sh
