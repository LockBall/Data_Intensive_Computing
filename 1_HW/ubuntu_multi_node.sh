#!/bin/bash
# John Lutz - 16 Feb 2023
# chmod a+x <filename> to set execute permissions for this file
# run this script using:
# $ sh ubuntu_multi_node.sh
# which requires ubuntu_single_node.sh
# must add git folder to environment variables
# https://github.com/Robert923/vscode-start-git-bash/issues/1

#$ ssh -o StrictHostKeyChecking=no -t LutzD00D@apt112.apt.emulab.net

# update me with node ids. this is also the last digits of the ip address
#set -o pipefail

config_file="config.sh"
directory=$(pwd)

if test -f $config_file; then
    # Config File Exists execute it
    . $config_file
else
    echo "Config File Template Copied"
    echo "ENTER USRER VALUES INTO LOCAL config.sh"
    cp config_template.sh config.sh
    exit
fi

if (( $windows == 1 )) ; then
    shell_cmd="git-bash -e";
else
    shell_cmd="gnome-terminal --command ";
fi

cmd_str="ssh -o StrictHostKeyChecking=no -t "; # -o StrictHostKeyChecking no
script_str=" < ubuntu_single_node.sh";
current_date=$(date);

if test -f "ssh_master.sh"; then
    echo "Removing SSH Master shell"
    rm ssh_master.sh
fi
echo "Executing Key Generation"
cmd="ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa -y"
echo $cmd >> ssh_master.sh
cmd="cat .ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
echo $cmd >> ssh_master.sh
echo "echo ssh -o StrictHostKeyChecking=no -t $user_str@$server_str${node_id_ary[0]}$suffix_str;" >> ssh_master.sh;
echo '$SHELL' >> ssh_master.sh;
chmod +x ssh_master.sh;
$shell_cmd "ssh -o StrictHostKeyChecking=no -t $user_str@$server_str${node_id_ary[0]}$suffix_str 'bash -s' << $directory/ssh_master.sh" & # & to run in background

echo "Executing SCP Copy"
$shell_cmd "scp $user_str@$server_str${node_id_ary[0]}$suffix_str:.ssh/authorized_keys tmp_keys"
$shell_cmd "scp tmp_keys $user_str@$server_str${node_id_ary[1]}$suffix_str:.ssh/authorized_keys"
$shell_cmd "scp tmp_keys $user_str@$server_str${node_id_ary[2]}$suffix_str:.ssh/authorized_keys"
$shell_cmd "scp tmp_keys $user_str@$server_str${node_id_ary[3]}$suffix_str:.ssh/authorized_keys"


for node_id in ${node_id_ary[@]}; do
    echo " ******** processing commands for node $node_id ******** ";
    echo "# $current_date" > $node_id.sh;
    final_cmd_str="$cmd_str$user_str@$server_str$node_id$suffix_str$script_str";
    echo -e "generated:    $final_cmd_str \n";
    echo "$final_cmd_str;" >> $node_id.sh;
    echo "echo results from node $node_id;" >> $node_id.sh;
    echo "echo ssh -o StrictHostKeyChecking=no -t $user_str@$server_str$node_id$suffix_str;" >> $node_id.sh;
    echo '$SHELL' >> $node_id.sh;
    chmod +x $node_id.sh;
    $shell_cmd "$directory/$node_id.sh" & # & with no ; to run in background
done

# only on NameNode
#hdfs namenode -format