#!/bin/bash
# John Lutz - 13 Feb 2023
# chmod a+x <filename> to set execute permissions for this file
# run this script using:
# $ sh ubuntu_multi_node.sh
# which requires ubuntu_single_node.sh
# must add git folder to environment variables
# https://github.com/Robert923/vscode-start-git-bash/issues/1

#$ ssh -o StrictHostKeyChecking=no -t LutzD00D@apt112.apt.emulab.net

#set -o pipefail

# update me with node ids. this is also the last digits of the ip address
ext_node_id_ary=("137" "144" "149" "148"); # end of ip of machines we need to ssh to

cmd_str="ssh -o StrictHostKeyChecking=no -t "; # -o StrictHostKeyChecking no
user_str="LutzD00D";
server_str="apt"; # update me with your server
suffix_str=".apt.emulab.net";
script_str=" < ubuntu_single_node.sh";
current_date=$(date);

for node_id in ${ext_node_id_ary[@]}; do
    echo " ******** processing commands for node $node_id ******** ";
    echo "# $current_date" > $node_id.sh;
    final_cmd_str="$cmd_str$user_str@$server_str$node_id$suffix_str$script_str";
    echo -e "generated:    $final_cmd_str \n";
    echo "$final_cmd_str;" >> $node_id.sh;
    echo "echo results from node $node_id;" >> $node_id.sh;
    echo "echo ssh -o StrictHostKeyChecking=no -t LutzD00D@apt$node_id.apt.emulab.net;" >> $node_id.sh;
    
    #echo 'set -o pipefail' >> $node_id.sh;
    echo '$SHELL' >> $node_id.sh; #important
    chmod +x $node_id.sh;
    git-bash -e $node_id.sh & # & with no ;to run in background
done

# only on NameNode
#hdfs namenode -format
#ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
# need to send publick key to all nodes