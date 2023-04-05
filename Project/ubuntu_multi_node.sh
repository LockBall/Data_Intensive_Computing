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

# generate per-node setup script files
for ext_node_id in ${ext_node_id_ary[@]};
    do
    echo " **** generating setup script file for node $ext_node_id **** ";
    echo "# $current_date" > $ext_node_id.sh;
    final_cmd_str="$cmd_str$user_str@$server_str$ext_node_id$suffix_str$script_str";
    echo -e "generated:    $final_cmd_str \n";
    echo "$final_cmd_str;" >> $ext_node_id.sh;
    echo "echo ssh -o StrictHostKeyChecking=no -t $user_str@$server_str$ext_node_id$suffix_str;" >> $ext_node_id.sh;
    echo "echo finished setting up node $ext_node_id;" >> $ext_node_id.sh;
    echo '$SHELL' >> $ext_node_id.sh;
    chmod +x $ext_node_id.sh;
    $shell_cmd "$directory/$ext_node_id.sh" & # & with no ; to run in background
done


# ____________________ PromCeph ____________________
    promceph_single_node_str="promceph_single_node";
    #generates single file to be sent to all nodes

    echo -e "\n ____________________ PromCeph ____________________ ";

    # generate file to be executed through ssh on nodes
    echo " **** generating token auth git clone file **** ";
    echo "# $current_date" > $promceph_single_node_str.sh;

    if  (( $promceph_reset == 1 ));
        then  echo "echo -e \n ____________________ deleting PromCeph folder ____________________ ;" >> $promceph_single_node_str.sh;
        echo "sudo rm -r -f //usr/local/promceph;" >> $promceph_single_node_str.sh;
    else
        echo "echo -e \n ____________________ reset PromCeph disabled ____________________ ;" >> $promceph_single_node_str.sh;
    fi
    #echo "sudo mkdir -p /usr/local/promceph/;" >> $promceph_single_node_str.sh;
    echo "sudo chmod 777 /usr/local/;" >> $promceph_single_node_str.sh;
    echo "cd /usr/local/;" >> $promceph_single_node_str.sh;
    echo "git clone https://oauth2:$git_access_token@github.com/swson/promceph.git;" >> $promceph_single_node_str.sh; 
    echo '$SHELL' >> $promceph_single_node_str.sh;
    #echo "source /usr/local/promceph/run-prombench-base.sh";

    # generate per-node promceph files
for ext_node_id in ${ext_node_id_ary[@]};
    do
    echo " **** generating per-node promceph file for node $ext_node_id **** ";
    echo "# $current_date" > $ext_node_id$repo_name.sh
    promceph_cmd_str="$cmd_str$user_str@$server_str$ext_node_id$suffix_str < $promceph_single_node_str.sh";
    echo "$promceph_cmd_str;" >> $ext_node_id$repo_name.sh;
    echo "echo finished setting up node $ext_node_id;" >> $ext_node_id$repo_name.sh;
    chmod +x $ext_node_id$repo_name.sh;
done
# ____________________ PromCeph ____________________
