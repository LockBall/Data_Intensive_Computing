#!/bin/bash

# John Lutz - 13 Feb 2023
# chmod a+x <filename> to set execute permissions for this file
# run me using this command, where pc?? is the ID of the ubuntu node
# ssh -t LutzD00D@pc07.cloudlab.umass.edu < ubuntu_single_node.sh
# ssh LutzD00D@apt099.apt.emulab.net < ubuntu_single_node.sh

# https://www.geeksforgeeks.org/bash-scripting-how-to-check-if-file-exists/

echo -e " connected to target";

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

#which java ;
#readlink -f $(which java) ;

search_for='# export JAVA_HOME=' ;
replace_with='export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")'
#replace_with='export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/'
sed -i "s@$search_for@$replace_with@" /usr/local/hadoop/etc/hadoop/hadoop-env.sh ;

#/usr/local/hadoop/bin/hadoop

cd '$HOME'
mkdir ~/input
cp /usr/local/hadoop/etc/hadoop/*.xml ~/input
/usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar grep ~/input ~/grep_example 'allowed[.]*'
cat ~/grep_example/*

# should return
# 22    allowed.
# 1    allowed
