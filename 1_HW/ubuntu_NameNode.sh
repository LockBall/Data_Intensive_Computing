#run me once
# ssh -o StrictHostKeyChecking=no -t LutzD00D@apt159.apt.emulab.net < ubuntu_NameNode.sh
# these ip must be manually edited and be the same as in ubuntu_multi_nodes.sh

echo "adding node IP's to /etc/hosts";
sudo -- sh -c -e "echo '
128.110.96.159 NameNode0
128.110.96.138 DataNode1
128.110.96.144 DataNode2
128.110.96.137 DataNode3
' >> /etc/hosts";

