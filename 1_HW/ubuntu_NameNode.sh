#run me once
# ssh -t LutzD00D@apt127.apt.emulab.net < ubuntu_NameNode.sh
# these ip must be manually edited and be the same as in ubuntu_multi_nodes.sh

ip_3="128.110.96."
NN0="127";
DN1="123";
DN2="121";
DN3="126";


if grep -q NameNode0 /etc/hosts
    then echo -e "node IP's already in /etc/hosts \n";
else
    echo -e "adding node IP's to /etc/hosts";
    sudo -- sh -c -e "echo '
$ip_3$NN0    NameNode0
$ip_3$DN1    DataNode1
$ip_3$DN2    DataNode2
$ip_3$DN3    DataNode3
' >> /etc/hosts";
fi

if grep -q 9000 /usr/local/hadoop/etc/hadoop/core-site.xml
    then echo -e "core-site.xml already modified \n"
else
    echo -e "setting core-site.xml"
    search_for='<configuration>';
    replace_with=" <!-- added by NameNode script --> \n \
    <property> \n \
        <name>fs.defaultFS</name> \n \
        <value>hdfs://128.110.96.$NN0:9000</value> \n \
    </property>
    ";
    sed -i "/$search_for/a $replace_with" /usr/local/hadoop/etc/hadoop/core-site.xml;
fi
