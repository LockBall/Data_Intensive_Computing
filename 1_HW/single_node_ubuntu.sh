#!/bin/bash
# John Lutz
# 11 Feb 2023

# chmod a+x <filename> to set execute permissions
echo -e " initiating ssh connection";

echo -e "\n updating & upgrading" ;
sudo apt update ;
sudo apt upgrade ;

echo -e "\n installing ssh & pdsh \n" ;
sudo apt-get install ssh ;
sudo apt-get install pdsh ;

echo -e "\n installing java" ;
sudo apt install default-jdk ;
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





# ssh -t LutzD00D@pc07.cloudlab.umass.edu < single_node_ubuntu.sh
