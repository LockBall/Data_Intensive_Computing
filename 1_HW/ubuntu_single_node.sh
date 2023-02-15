#!/bin/bash

# John Lutz - 15 Feb 2023
# chmod a+x <filename> to set execute permissions for this file

# run me using this command, where ???? is the ID of the ubuntu node e.g., apt099, pc127
# ssh -t LutzD00D@??????.cloudlab.umass.edu < ubuntu_single_node.sh
# ssh -t LutzD00D@??????.apt.emulab.net < ubuntu_single_node.sh

# https://www.geeksforgeeks.org/bash-scripting-how-to-check-if-file-exists/
# https://www.digitalocean.com/community/tutorials/how-to-install-hadoop-in-stand-alone-mode-on-ubuntu-20-04
# https://sparkbyexamples.com/hadoop/apache-hadoop-installation/

DataNodes_id_ary=("147" "139" "138"); # workers
reset_workers=0 # set to 1 to delete and regenerate workers file

echo -e "____________________ connected to target ____________________";

# ____________________ add nodes to hosts ____________________
# these ip must be manually edited and be the same as in ubuntu_multi_nodes.sh
echo -e "____________________ processing hosts file ____________________" ;
ip_3="10.10.1.";
NN0="1"; #NameNode
DN1="2"; #DataNode
DN2="3";
DN3="4";

#if grep -q NameNode0 /etc/hosts;
#then
#    echo -e " ******** node IP's already in /etc/hosts ******** \n";
#else
#    echo -e " ******** adding node IP's to /etc/hosts ******** ";
#    sudo -- sh -c -e "echo '
#$ip_3$NN0    NameNode0
#$ip_3$DN1    DataNode1
#$ip_3$DN2    DataNode2
#$ip_3$DN3    DataNode3
#' >> /etc/hosts
#";
#fi
# ____________________ add nodes to hosts ____________________

echo -e " ******** updating & upgrading ******** ";
sudo apt-get update -y;
sudo apt-get upgrade -y;

echo -e "\n ******** installing ssh & pdsh ******** \n";
sudo apt-get install -y ssh;
sudo apt-get install -y pdsh;

echo -e "\n ******** installing java ******** ";
sudo apt install -y default-jdk;
java -version;

echo -e "\n ____________________ handling hadoop ____________________ ";
if test -d "/usr/local/hadoop";
then
    echo " ******** hadoop has already been extracted and moved ******** ";
else
    echo " /usr/local/hadoop folder missing";
    if test -f "hadoop-3.3.4.tar.gz";
    then
        echo " file exists";
    else
        echo " file not found, downloading hadoop";
        wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz;
    fi
    
    echo " ******** extracting & moving hadoop ******** ";
    tar xvfz hadoop-3.3.4.tar.gz;
    sudo mv hadoop-3.3.4 /usr/local/hadoop; # same same
fi

search_for='# export JAVA_HOME=';
replace_with='export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")';
#replace_with='export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/';
sed -i "s@$search_for@$replace_with@" /usr/local/hadoop/etc/hadoop/hadoop-env.sh;

# ____________________ add hadoop paths to ~/.bashrc ____________________
if grep -q hadoop ~/.bashrc;
then
    echo -e " ******** hadoop paths already in ~/.bashrc ******** \n";
else
    echo " ******** adding hadoop paths to ~/.bashrc ******** \n"; # same same ↓↓
    echo -e '\n
export HADOOP_HOME=/usr/local/hadoop;
export PATH=$PATH:$HADOOP_HOME/bin;
export PATH=$PATH:$HADOOP_HOME/sbin;
export PATH=$PATH:$HADOOP_HOME/sbin;
export HADOOP_MAPRED_HOME=${HADOOP_HOME};
export HADOOP_COMMON_HOME=${HADOOP_HOME};
export HADOOP_HDFS_HOME=${HADOOP_HOME};
export YARN_HOME=${HADOOP_HOME};
' >> ~/.bashrc;
fi
source ~/.bashrc;
# ____________________ add hadoop paths to ~/.bashrc ____________________

# ____________________ modify core-site.xml ____________________
echo -e "____________________ Processing .xml files ____________________ ";

if grep -q 9000 /usr/local/hadoop/etc/hadoop/core-site.xml;
then
    echo -e " ******** core-site.xml already modified ******** ";
else
    echo -e " ******** setting core-site.xml ******** ";
    search_for='<configuration>';
    replace_with=" <!-- added by NameNode script --> \n \
    <property> \n \
        <name>fs.defaultFS</name> \n \
        <value>hdfs://$ip_3$NN0 :9000</value> \n \
    </property>
    ";
    sed -i "/$search_for/a $replace_with" /usr/local/hadoop/etc/hadoop/core-site.xml;
fi #NameNode
# ____________________ modify core-site.xml ____________________

# ____________________ modify hdfs-site.xml ____________________
if grep -q hadoop /usr/local/hadoop/etc/hadoop/hdfs-site.xml;
then
    echo -e " ******** hdfs-site.xml already modified ******** ";
else
    echo -e " ******** setting hdfs-site.xml ******** ";
    search_for='<configuration>';
    replace_with=" <!-- added by NameNode script --> \n \
    <property> \n \
        <name>dfs.replication</name> \n \
        <value>3</value> \n \
    </property> \n \
    <property> \n \
        <name>dfs.namenode.name.dir</name> \n \
        <value>file:///usr/local/hadoop/hdfs/data</value> \n \
    </property> \n \
    <property> \n \
        <name>dfs.datanode.data.dir</name> \n \
        <value>file:///usr/local/hadoop/hdfs/data</value> \n \
    </property>
    ";
    sed -i "/$search_for/a $replace_with" /usr/local/hadoop/etc/hadoop/hdfs-site.xml;
fi
# ____________________ modify hdfs-site.xml ____________________

# ____________________ modify yarn-site.xml ____________________
if grep -q hadoop /usr/local/hadoop/etc/hadoop/yarn-site.xml;
then
    echo -e " ******** yarn-site.xml already modified ******** ";
else
    echo -e " ******** setting yarn-site.xml ******** ";
    search_for='<configuration>';
    replace_with=" <!-- added by NameNode script --> \n \
    <property> \n \
        <name>yarn.nodemanager.aux-services</name> \n \
        <value>mapreduce_shuffle</value> \n \
    </property> \n \
    <property> \n \
        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name> \n \
        <value>org.apache.hadoop.mapred.ShuffleHandler</value> \n \
    </property> \n \
    <property> \n \
       <name>yarn.resourcemanager.hostname</name> \n \
       <value>$ip_3$NN0</value> \n \
    </property>
    ";
    sed -i "/$search_for/a $replace_with" /usr/local/hadoop/etc/hadoop/yarn-site.xml;
fi #NameNode
# ____________________ modify yarn-site.xml ____________________

# ____________________ modify mapred-site.xml ____________________
# [Note: This configuration required only on name node however, 
# it will not harm if you configure it on datanodes]

if grep -q mapred /usr/local/hadoop/etc/hadoop/mapred-site.xml;
then
    echo -e " ******** mapred-site.xml already modified ******** ";
else
    echo -e " ******** setting mapred-site.xml ******** ";
    search_for='<configuration>';
    replace_with=" <!-- added by NameNode script --> \n \
    <property> \n \
        <name>mapreduce.jobtracker.address</name> \n \
        <value>$ip_3$NN0 :54311</value> \n \
    </property> \n \
    <property> \n \
        <name>mapreduce.framework.name</name> \n \
        <value>mapred</value> \n \
    </property>
    ";
    sed -i "/$search_for/a $replace_with" /usr/local/hadoop/etc/hadoop/mapred-site.xml;
fi #NameNode
# ____________________ modify mapred-site.xml ____________________

# ____________________ create data folder ____________________
echo -e "\n ____________________ process data dir ____________________ ";
if test -d "/usr/local/hadoop/hdfs/data";
then
    echo " ******** data folder already exists ******** ";
else
    echo " ******** making data dir ******** ";
    mkdir -p /usr/local/hadoop/hdfs/data;
    #sudo chown ubuntu:ubuntu -R /usr/local/hadoop/hdfs/data;
    #sudo chown -R $(id -u):$(id -g) /usr/local/hadoop/hdfs/data;
    #chmod 700 /usr/local/hadoop/hdfs/data;
fi
# ____________________ create data folder ____________________

# ____________________ create masters file ____________________
# NameNode
echo -e "\n ____________________ process masters file ____________________ ";
if test -f "/usr/local/hadoop/etc/hadoop/masters";
then
    echo " ******** masters file exists ******** ";
else
    echo " ******** masters file not found, creating it ******** ";
    touch /usr/local/hadoop/etc/hadoop/masters;
    echo "$ip_3$NN0" >> /usr/local/hadoop/etc/hadoop/masters;
fi #NameNode
# ____________________ create masters file ____________________

# ____________________ create workers file ____________________
# DataNodes
echo -e "\n ____________________ process workers file ____________________ ";

if [ $reset_workers -eq 1 ];
then
    echo " ******** workers reset enabled ******** ";
    rm /usr/local/hadoop/etc/hadoop/workers;
else
    echo " ******** workers reset disabled ******** ";
fi

if test -f "/usr/local/hadoop/etc/hadoop/workers";
then
    echo -e " ******** workers file exists ******** \n";
else
    echo -e " ******** workers file not found, creating it ******** \n";
    touch /usr/local/hadoop/etc/hadoop/workers;

    for data_node_id in ${DataNodes_id_ary[@]};
    do 
        echo "$ip_3$data_node_id" >> /usr/local/hadoop/etc/hadoop/workers;
    done
fi
# ____________________ create workers file ____________________


echo -e "____________________ Running Example ____________________ \n";
cd $HOME
rm -r -f ~/input;
mkdir ~/input;
cp /usr/local/hadoop/etc/hadoop/*.xml ~/input;
/usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar grep ~/input ~/grep_example 'allowed[.]*';
echo -e "\n";
cat ~/grep_example/*;


# should return
# 22    allowed.
# 1    allowed

#ip=$(hostname -i);
#echo -e "$ip\n" > ip_list.txt;
#echo -e "\n $ip";

$SHELL