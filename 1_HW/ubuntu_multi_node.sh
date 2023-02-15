#!/bin/bash
# John Lutz - 15 Feb 2023
# chmod a+x <filename> to set execute permissions for this file
# run this script using:
# $ sh ubuntu_multi_node.sh
# which requires ubuntu_single_node.sh
# must add git folder to environment variables
# https://github.com/Robert923/vscode-start-git-bash/issues/1

#$ ssh -o StrictHostKeyChecking=no -t LutzD00D@apt112.apt.emulab.net

cmd_str="ssh -o StrictHostKeyChecking=no -t "; # -o StrictHostKeyChecking no
user_str="LutzD00D"; # update me with your username
server_str="@apt"; # update me with your server

# update me with node ids. this is also the last digits of the ip address
node_id_ary=("150" "147" "139" "138"); 

suffix_str=".apt.emulab.net";
script_str=" < ubuntu_single_node.sh";
current_date=$(date);

cmd="ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
echo $cmd >> ssh_master.sh
cmd="cat .ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
echo $cmd >> ssh_master.sh
echo "echo ssh -o StrictHostKeyChecking=no -t LutzD00D@apt$node_id_ary[0].apt.emulab.net;" >> $ssh_master.sh;
chmod +x $ssh_master.sh;
git-bash -e $ssh_master.sh & # & to run in background

echo "scp LutzD00D@apt$node_id_ary[0].apt.emulab.net:.ssh/authorized_keys ~/tmp_keys"
echo "scp ~/tmp_keys LutzD00D@apt$node_id_ary[1].apt.emulab.net:.ssh/authorized_keys"
echo "scp ~/tmp_keys LutzD00D@apt$node_id_ary[2].apt.emulab.net:.ssh/authorized_keys"
echo "scp ~/tmp_keys LutzD00D@apt$node_id_ary[3].apt.emulab.net:.ssh/authorized_keys"


for node_id in ${node_id_ary[@]};
do
    echo " ******** processing commands for node $node_id ******** ";
    echo "# $current_date" > $node_id.sh;
    final_cmd_str="$cmd_str$user_str$server_str$node_id$suffix_str$script_str";
    echo -e "generated:    $final_cmd_str \n";
    echo "$final_cmd_str;" >> $node_id.sh;
    echo "echo results from node $node_id;" >> $node_id.sh;
    echo "echo ssh -o StrictHostKeyChecking=no -t LutzD00D@apt$node_id.apt.emulab.net;" >> $node_id.sh;
    echo '$SHELL' >> $node_id.sh;
    chmod +x $node_id.sh;
    git-bash -e $node_id.sh & # & to run in background
done

# only on NameNode
#hdfs namenode -format