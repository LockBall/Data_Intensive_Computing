#!/bin/bash

# John Lutz - 13 Feb 2023
# chmod a+x <filename> to set execute permissions for this file
# run me using this command, where pc?? is the ID of the ubuntu node
# ssh -t LutzD00D@pc07.cloudlab.umass.edu < ubuntu_single_node.sh
# ssh LutzD00D@apt099.apt.emulab.net < ubuntu_single_node.sh

# https://www.geeksforgeeks.org/bash-scripting-how-to-check-if-file-exists/

echo -e "____________________ connected to target ____________________";

# ____________________ add nodes to hosts ____________________
# these ip must be manually edited and be the same as in ubuntu_multi_nodes.sh
echo -e "____________________ processing hosts file ____________________" ;
ip_3="128.110.96.";
NN0="127";
DN1="123";
DN2="121";
DN3="126";

if grep -q NameNode0 /etc/hosts
    then echo -e " ******** node IP's already in /etc/hosts ******** \n";
else
    echo -e " ******** adding node IP's to /etc/hosts ******** ";
    sudo -- sh -c -e "echo '
$ip_3$NN0    NameNode0
$ip_3$DN1    DataNode1
$ip_3$DN2    DataNode2
$ip_3$DN3    DataNode3
' >> /etc/hosts";
fi
# ____________________ add nodes to hosts ____________________

echo -e " ******** updating & upgrading ******** " ;
sudo apt-get update -y;
sudo apt-get upgrade -y;

echo -e "\n ******** installing ssh & pdsh ******** \n";
sudo apt-get install -y ssh;
sudo apt-get install -y pdsh;

echo -e "\n ******** installing java ******** ";
sudo apt install -y default-jdk;
java -version;

echo -e "\n ____________________ installing hadoop ____________________ ";
if test -d "/usr/local/hadoop";
    then echo " ******** hadoop has already been extracted and moved ******** ";
else
    echo " /usr/local/hadoop folder missing";
    if test -f "hadoop-3.3.4.tar.gz";
        then echo " file exists";
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
#replace_with='export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/'
sed -i "s@$search_for@$replace_with@" /usr/local/hadoop/etc/hadoop/hadoop-env.sh;

# ____________________ add hadoop paths to ~/.bashrc ____________________
if grep -q hadoop ~/.bashrc
    then echo -e " ******** hadoop paths already in ~/.bashrc ******** \n";
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
echo -e "____________________ Processing .xml files ____________________ \n";

if grep -q 9000 /usr/local/hadoop/etc/hadoop/core-site.xml
    then echo -e " ******** core-site.xml already modified ******** \n"
else
    echo -e " ******** setting core-site.xml ******** "
    search_for='<configuration>';
    replace_with=" <!-- added by NameNode script --> \n \
    <property> \n \
        <name>fs.defaultFS</name> \n \
        <value>hdfs://$ip_3$NN0:9000</value> \n \
    </property>
    ";
    sed -i "/$search_for/a $replace_with" /usr/local/hadoop/etc/hadoop/core-site.xml;
fi
# ____________________ modify core-site.xml ____________________

# ____________________ modify hdfs-site.xml ____________________
if grep -q hadoop /usr/local/hadoop/etc/hadoop/hdfs-site.xml
    then echo -e " ******** hdfs-site.xml already modified ******** \n"
else
    echo -e " ******** setting hdfs-site.xml ******** "
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
if grep -q hadoop /usr/local/hadoop/etc/hadoop/yarn-site.xml
    then echo -e " ******** yarn-site.xml already modified ******** \n"
else
    echo -e " ******** setting yarn-site.xml ******** "
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
fi
# ____________________ modify yarn-site.xml ____________________

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


