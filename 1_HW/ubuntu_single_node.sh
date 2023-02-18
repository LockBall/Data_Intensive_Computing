# #!/bin/bash

# # John Lutz - 13 Feb 2023
# # chmod a+x <filename> to set execute permissions for this file
# # run me using this command, where pc?? is the ID of the ubuntu node
# # ssh -t LutzD00D@pc07.cloudlab.umass.edu < ubuntu_single_node.sh
# # ssh LutzD00D@apt099.apt.emulab.net < ubuntu_single_node.sh

# # https://www.geeksforgeeks.org/bash-scripting-how-to-check-if-file-exists/

# #set -o pipefail;
current_date=$(date);
echo "running ubuntu_single_node.sh $current_date";

DataNodes_id_ary=("2" "3" "4"); # workers
ip_3="10.10.1.";
NN0="1";
DN1="2";
DN2="3";
DN3="4";

xml_modded="single_node";

masters_reset=0;
workers_reset=0;
xml_reset=0;
data_reset=0;
clean_hadoop=0;

# # namenode knows the data contains, what block it bleongs to 
# # and where it goes. Namenode also controls when someone can 
# # write and read. Data nodes talk to the name nodes to know what to do

echo -e " ____________________ connected to target ____________________ \n";

if test -f "/users/LutzD00D/.ssh/id_rsa.pub";
    then echo " **** publickey already exists **** ";
else
    echo " **** generating key pair **** ";
    ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y;
    # Your public key has been saved in /users/LutzD00D/.ssh/id_rsa.pub
    # https://stackoverflow.com/questions/43235179/how-to-execute-ssh-keygen-without-prompt
fi


# # ____________________ BEGIN add nodes to hosts ____________________
# # these ip must be manually edited and be the same as in ubuntu_multi_nodes.sh
# # echo -e "____________________ processing hosts file ____________________" ;
# # ip_3="128.110.96.";
# # NN0="126";
# # DN1="123";
# # DN2="127";
# # DN3="122";

# # if grep -q NameNode0 /etc/hosts; then
# #     echo -e " **** node IP's already in /etc/hosts **** \n";
# # else
# #     echo -e " **** adding node IP's to /etc/hosts **** ";
# #     sudo --sh -c -e "echo'
# # $ip_3$NN0    NameNode0
# # $ip_3$DN1    DataNode1
# # $ip_3$DN2    DataNode2
# # $ip_3$DN3    DataNode3' >> /etc/hosts";
# # fi
# # # ____________________ END add nodes to hosts ____________________


echo -e " ____________________ installing ____________________ ";

echo -e "\n **** updating & upgrading **** " ;
sudo apt-get update -y;
sudo apt-get upgrade -y;

echo -e "\n **** ssh & pdsh **** \n";
sudo apt-get install -y ssh;
sudo apt-get install -y pdsh;

echo -e "\n **** java **** ";
sudo apt install -y default-jdk;
java -version;


echo -e "\n ____________________ hadoop ____________________ ";

if (( $clean_hadoop == 1 ));
    then echo -e "\n **** Cleaning hadoop **** ";
        sudo rm -rd /usr/local/hadoop;
        rm ~/.bashrc;
        mv ~/.cleanbashrc .bashrc;
    else
    echo "\n **** leaving hadoop alone **** ";
fi

if test -d "/usr/local/hadoop";
    then echo " **** hadoop has already been extracted and moved **** ";
else
    echo " /usr/local/hadoop folder missing";
    if test -f "hadoop-3.3.4.tar.gz";
        then echo " file exists";
    else
        echo " file not found, downloading hadoop";
        wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz;
    fi
    
    echo " **** extracting & moving hadoop **** ";
    tar xvfz hadoop-3.3.4.tar.gz;
    sudo mv hadoop-3.3.4 /usr/local/hadoop; # same same
fi

# ____________________ BEGIN hadoop backup folder ____________________
echo -e " **** processing hadoop backup folder **** ";
if test -d "/usr/local/hadoop/backups";
    then echo -e " **** backup directory already exists **** ";
else
    echo -e " **** making backup directory **** \n";
    mkdir /usr/local/hadoop/backups;
fi
# ____________________ END hadoop backup folder ____________________


# ____________________ BEGIN JAVA_HOME ____________________
if grep -q readlink /usr/local/hadoop/etc/hadoop/hadoop-env.sh;
    then echo -e " **** JAVA_HOME already in hadoop-env.sh **** ";
else
    echo -e " **** backing up hadoop-env.sh **** \n";
    cp /usr/local/hadoop/etc/hadoop/hadoop-env.sh /usr/local/hadoop/backups/;
    echo -e " **** setting JAVA_HOME in hadoop-env.sh **** \n";
    search_for='# export JAVA_HOME=';
    replace_with='export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")';
    #replace_with='export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/'
    sed -i "s@$search_for@$replace_with@" /usr/local/hadoop/etc/hadoop/hadoop-env.sh;
fi
# ____________________ END JAVA_HOME ____________________


# ____________________ BEGIN add hadoop paths to ~/.bashrc ____________________
if grep -q hadoop ~/.bashrc;
    then echo -e " **** hadoop paths already in ~/.bashrc **** \n";
else
    echo -e " **** backing up ~/.bashrc **** ";
    cp ~/.bashrc ~/.cleanbashrc

    echo " **** adding hadoop paths to ~/.bashrc **** \n"; # same same ↓↓
    echo -e '\n
export HADOOP_HOME=/usr/local/hadoop;
export PATH=$PATH:$HADOOP_HOME/bin;
export PATH=$PATH:$HADOOP_HOME/sbin;
export PATH=$PATH:$HADOOP_HOME/sbin;
export HADOOP_MAPRED_HOME=${HADOOP_HOME};
export HADOOP_COMMON_HOME=${HADOOP_HOME};
export HADOOP_HDFS_HOME=${HADOOP_HOME};
export YARN_HOME=${HADOOP_HOME};
export PDSH_RCMD_TYPE=ssh;
' >> ~/.bashrc;
fi
source ~/.bashrc;
# ____________________ END add hadoop paths to ~/.bashrc ____________________


echo -e " ____________________ Process *.xml files ____________________ \n";

# ____________________ core-site.xml ____________________
if grep -q $xml_modded /usr/local/hadoop/etc/hadoop/core-site.xml;
    then echo -e " **** core-site.xml already modified **** \n";
else
    echo -e " **** backing up core-site.xml **** ";
    cp /usr/local/hadoop/etc/hadoop/core-site.xml /usr/local/hadoop/backups; 

    echo -e " **** modifying core-site.xml **** \n";
    core_search_for='<configuration>';
    core_replace_with=" <!-- added by $xml_modded script --> \n \
    <property> \n \
        <name>fs.defaultFS</name> \n \
        <value>hdfs://$ip_3$NN0:9000</value> \n \
    </property>
    ";
    sed -i "/$core_search_for/a $core_replace_with" /usr/local/hadoop/etc/hadoop/core-site.xml;
fi
# ____________________ core-site.xml ____________________


# ____________________ hdfs-site.xml ____________________
if grep -q $xml_modded /usr/local/hadoop/etc/hadoop/hdfs-site.xml;
    then echo -e " **** hdfs-site.xml already modified **** \n"
else
    echo -e " **** backing up hdfs-site.xml **** ";
    cp /usr/local/hadoop/etc/hadoop/hdfs-site.xml /usr/local/hadoop/backups; 

    echo -e " **** modifying hdfs-site.xml **** \n"
    hdfs_search_for='<configuration>';
    #TODO: Add the hosts file that lists the datanodes 
    hdfs_replace_with=" <!-- added by $xml_modded script --> \n \
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
    sed -i "/$hdfs_search_for/a $hdfs_replace_with" /usr/local/hadoop/etc/hadoop/hdfs-site.xml;
fi
# ____________________ hdfs-site.xml ____________________


# ____________________ yarn-site.xml ____________________
if grep -q $xml_modded /usr/local/hadoop/etc/hadoop/yarn-site.xml;
    then echo -e " **** yarn-site.xml already modified **** \n"
else
    echo -e " **** backing up yarn-site.xml **** ";
    cp /usr/local/hadoop/etc/hadoop/yarn-site.xml /usr/local/hadoop/backups; 

    echo -e " **** modifying yarn-site.xml **** \n"
    yarn_search_for='<configuration>';
    # Sets the Namenode as the resource manager
    # Sets the shuffle service for map reduce applications
    # Sets the map reduce classpath jar directory to be org.apache.hadoop.mapred.shufflehandler TODO: Maybe wrong
    yarn_replace_with=" <!-- added by $xml_modded script --> \n \
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
    sed -i "/$yarn_search_for/a $yarn_replace_with" /usr/local/hadoop/etc/hadoop/yarn-site.xml;
fi
# ____________________ yarn-site.xml ____________________

# ____________________ mapred-site.xml ____________________
# only required on NameNode, will not harm datanodes
if grep -q $xml_modded /usr/local/hadoop/etc/hadoop/mapred-site.xml;
    then echo -e " **** mapred-site.xml already modified **** ";
else
    echo -e " **** backing up mapred-site.xml **** ";
    cp /usr/local/hadoop/etc/hadoop/mapred-site.xml /usr/local/hadoop/backups;

    echo -e " **** modifying mapred-site.xml **** \n";
    mapred_search_for='<configuration>';
    #TODO: Mapreduce should be set to yarn
    #Sets the jobtracker history server to namenode
    mapred_replace_with=" <!-- added by $xml_modded script --> \n \
    <property> \n \
        <name>mapreduce.jobtracker.address</name> \n \
        <value>$ip_3$NN0:54311</value> \n \
    </property> \n \
        <property> \n \
        <name>yarn.app.mapreduce.am.env</name> \n \
        <value>HADOOP_MAPRED_HOME=/usr/local/hadoop/</value> \n \
    </property> \n \
        <property> \n \
        <name>mapreduce.map.env</name> \n \
        <value>HADOOP_MAPRED_HOME=/usr/local/hadoop/</value> \n \
    </property> \n \
    <property> \n \
        <name>mapreduce.reduce.env</name> \n \
        <value>HADOOP_MAPRED_HOME=/usr/local/hadoop/</value> \n \
    </property> \n \
    <property> \n \
        <name>mapreduce.framework.name</name> \n \
        <value>yarn</value> \n \
    </property>
    ";
    sed -i "/$mapred_search_for/a $mapred_replace_with" /usr/local/hadoop/etc/hadoop/mapred-site.xml;
fi
# ____________________ mapred-site.xml ____________________

if (($xml_reset == 1));
    then echo "resetting *.xml files to original, set xml_reset=0 to auto-re-modify";
    cp /usr/local/hadoop/backups/core-site.xml /usr/local/hadoop/etc/hadoop/; 
    cp /usr/local/hadoop/backups/hdfs-site.xml /usr/local/hadoop/etc/hadoop/; 
    cp /usr/local/hadoop/backups/yarn-site.xml /usr/local/hadoop/etc/hadoop/; 
    cp /usr/local/hadoop/backups/mapred-site.xml /usr/local/hadoop/etc/hadoop/;
fi


# ____________________ masters file ____________________
echo -e "\n ____________________ process masters file ____________________ ";
if (( $masters_reset == 1 ));
    then echo " **** masters reset enabled **** ";
    rm /usr/local/hadoop/etc/hadoop/masters;
else
    echo " **** masters reset disabled **** ";
fi

if test -f "/usr/local/hadoop/etc/hadoop/masters";
    then echo " **** masters file exists **** ";
else
    echo " **** masters file not found, creating it **** ";
    touch /usr/local/hadoop/etc/hadoop/masters;
    echo "$ip_3$NN0" >> /usr/local/hadoop/etc/hadoop/masters;
fi
# ____________________ masters file ____________________


# ____________________ workers file ____________________
echo -e "\n ____________________ process workers file ____________________ ";
if (( $workers_reset == 1 ));
    then echo " **** workers reset enabled **** ";
    rm /usr/local/hadoop/etc/hadoop/workers;
else
    echo " **** workers reset disabled **** ";
fi

if grep -q localhost /usr/local/hadoop/etc/hadoop/workers;
    then echo " **** localhost in workers, removing file **** "
    rm /usr/local/hadoop/etc/hadoop/workers;
fi

if test -f "/usr/local/hadoop/etc/hadoop/workers";
    then echo " **** workers file exists **** ";
else
    echo " **** workers file not found, creating it **** ";
    touch /usr/local/hadoop/etc/hadoop/workers;

    for data_node_id in ${DataNodes_id_ary[@]};
        do echo "$ip_3$data_node_id" >> /usr/local/hadoop/etc/hadoop/workers;
    done
fi
# ____________________ workers file ____________________


# ____________________ data dir ____________________
echo -e "\n ____________________ process data dir ____________________ ";
if (( $data_reset == 1 ));
    then echo " **** data reset enabled **** ";
    sudo rm -r -f /usr/local/hadoop/hdfs/data;
else
    echo " **** data reset disabled **** ";
fi

if test -d "/usr/local/hadoop/hdfs/data";
    then echo " **** data folder already exists **** ";
else
    echo " **** making data dir **** ";
    mkdir -p /usr/local/hadoop/hdfs/data;
    sudo chown -R $(id -u):$(id -g) /usr/local/hadoop/hdfs/data;
    chmod 700 /usr/local/hadoop/hdfs/data;
fi
# ____________________ data dir ____________________


echo -e "____________________ Running Example ____________________ \n";
cd $HOME
mkdir ~/input;
cp /usr/local/hadoop/etc/hadoop/*.xml ~/input;
/usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar grep ~/input ~/grep_example 'allowed[.]*';
echo -e "\n";
cat ~/grep_example/*;

# # should return
# # 22    allowed.
# # 1    allowed

$SHELL