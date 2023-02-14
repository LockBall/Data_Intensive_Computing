
#!/bin/bash
# John Lutz - 13 Feb 2023
# chmod a+x <filename> to set execute permissions for this file
# run this script using:
# ssh LutzD00D@apt099.apt.emulab.net < ubuntu_multi_node.sh
# which requires ubuntu_single_node.sh
# must add git folder to environment variables
# https://github.com/Robert923/vscode-start-git-bash/issues/1
    
cmd_str="ssh -t ";
user_str="LutzD00D";
server_str="@apt"; # update me with your server
node_id_ary=("099" "116" "106" "102"); # update me with your node ids
suffix_str=".apt.emulab.net";
script_str=" < ubuntu_single_node.sh";
current_date=$(date);

for node_id in ${node_id_ary[@]}; do
    echo "processing commands for node $node_id";
    echo "# $current_date" > $node_id.sh;
    final_cmd_str="$cmd_str$user_str$server_str$node_id$suffix_str$script_str";
    echo -e "generated $final_cmd_str \n";
    echo "$final_cmd_str" >> $node_id.sh;
    echo '$SHELL' >> $node_id.sh;
    git-bash -e $node_id.sh & # & to run in background
done