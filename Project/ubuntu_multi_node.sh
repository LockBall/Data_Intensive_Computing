#!/bin/bash
# John Lutz - 18 Feb 2023
# chmod a+x <filename> to set execute permissions for this file
# run this script using:
# $ sh ubuntu_multi_node.sh
# which requires ubuntu_single_node.sh, and a config file that it will make but you must modify
# must add git folder to environment variables
# https://github.com/Robert923/vscode-start-git-bash/issues/1

# ssh -o StrictHostKeyChecking=no -t LutzD00D@apt112.apt.emulab.net
# ssh -o StrictHostKeyChecking=no -t LutzD00D@apt099.apt.emulab.net < ubuntu_multi_node.sh

config_file="multi_config.sh";
directory=$(pwd);
cmd_str="ssh -o StrictHostKeyChecking=no -t "; # -o StrictHostKeyChecking no
script_str=" < ubuntu_single_node.sh";
current_date=$(date);

if test -f $config_file;
    then echo " **** Config File Exists, source it. **** ";
    source ./$config_file;
else
    echo " **** Config File Template Copied **** ";
    echo " **** ENTER USER VALUES INTO MULTI LOCAL $config_file **** ";
    cp multi_config_template.sh $config_file;
    exit
fi


if (( $windows == 1 )) ;
    then shell_cmd="git-bash -e";
else
    shell_cmd="gnome-terminal --command ";
fi


for ext_node_id in ${ext_node_id_ary[@]};
    do
    echo " **** processing commands for node $ext_node_id **** ";
    echo "# $current_date" > $ext_node_id.sh;
    final_cmd_str="$cmd_str$user_str@$server_str$ext_node_id$suffix_str$script_str";
    echo -e "generated:    $final_cmd_str \n";
    echo "$final_cmd_str;" >> $ext_node_id.sh;
    echo "echo finished setting up node $ext_node_id;" >> $ext_node_id.sh;
    echo "echo ssh -o StrictHostKeyChecking=no -t $user_str@$server_str$ext_node_id$suffix_str;" >> $ext_node_id.sh;
    echo '$SHELL' >> $ext_node_id.sh;
    chmod +x $ext_node_id.sh;
    $shell_cmd "$directory/$ext_node_id.sh" & # & with no ; to run in background
done
