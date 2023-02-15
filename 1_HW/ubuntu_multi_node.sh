
#!/bin/bash
# John Lutz - 13 Feb 2023
# chmod a+x <filename> to set execute permissions for this file
# run this script using:
# $ sh ubuntu_multi_node.sh
# which requires ubuntu_single_node.sh
# must add git folder to environment variables
# https://github.com/Robert923/vscode-start-git-bash/issues/1

#$ ssh -o StrictHostKeyChecking=no -t LutzD00D@apt112.apt.emulab.net

cmd_str="ssh -o StrictHostKeyChecking=no -t "; # -o StrictHostKeyChecking no
user_str="LutzD00D";
server_str="@apt"; # update me with your server
node_id_ary=("159" "138" "144" "137"); # update me with your node ids. these are also the last digits of the ip address
suffix_str=".apt.emulab.net";
script_str=" < ubuntu_single_node.sh";
current_date=$(date);

for node_id in ${node_id_ary[@]}; do
    echo "processing commands for node $node_id";
    echo "# $current_date" > $node_id.sh;
    final_cmd_str="$cmd_str$user_str$server_str$node_id$suffix_str$script_str";
    echo -e "generated:    $final_cmd_str \n";
    echo "$final_cmd_str;" >> $node_id.sh;
    echo "echo results from node $node_id;" >> $node_id.sh;
    echo "echo ssh -o StrictHostKeyChecking=no -t LutzD00D@apt$node_id.apt.emulab.net;" >> $node_id.sh;
    echo '$SHELL' >> $node_id.sh;
    chmod +x $node_id.sh;

    # put additional tasks here to be written to
    git-bash -e $node_id.sh & # & to run in background
done
