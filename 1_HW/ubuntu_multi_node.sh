#!/bin/bash
# John Lutz - 16 Feb 2023
# chmod a+x <filename> to set execute permissions for this file
# run this script using:
# $ sh ubuntu_multi_node.sh
# which requires ubuntu_single_node.sh
# must add git folder to environment variables
# https://github.com/Robert923/vscode-start-git-bash/issues/1

# ssh -o StrictHostKeyChecking=no -t LutzD00D@apt112.apt.emulab.net
# ssh -o StrictHostKeyChecking=no -t LutzD00D@apt099.apt.emulab.net < ubuntu_multi_node.sh

# update me with node ids. this is also the last digits of the ip address
#set -o pipefail

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

# # ____________________ The Keymaker ____________________
# if test -f "ssh_master.sh";
#     then echo "Removing SSH Master shell";
#     rm ssh_master.sh;
# fi

# if test -f "tmp_keys";
#     then echo "Removing tmp_keys Master shell";
#     rm tmp_keys;
# fi
# echo "Executing Key Generation"
# cmd="#!/bin/bash"
# echo $cmd >> ssh_master.sh
# cmd="if test -f ~/.ssh/id_rsa.pub; then"
# echo $cmd >> ssh_master.sh
# cmd="mv ~/.ssh/backup_keys ~/.ssh/authorized_keys"
# echo $cmd >> ssh_master.sh
# cmd="rm ~/.ssh/id_rsa*"
# echo $cmd >> ssh_master.sh
# cmd="fi"
# echo $cmd >> ssh_master.sh
# cmd="cp ~/.ssh/authorized_keys ~/.ssh/backup_keys"
# echo $cmd >> ssh_master.sh
# cmd="ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1"
# echo $cmd >> ssh_master.sh
# cmd="cat .ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
# echo $cmd >> ssh_master.sh
# echo "echo '$cmd_str$user_str@$server_str${ext_node_id_ary[0]}$suffix_str'" >> ssh_master.sh;

# echo '$SHELL' >> ssh_master.sh;
# chmod +x ssh_master.sh;
# if test -f exec.sh; then
#     rm exec.sh
# fi
# echo "ssh -o StrictHostKeyChecking=no -t $user_str@$server_str${ext_node_id_ary[0]}$suffix_str < $directory/ssh_master.sh;" >> exec.sh; # & to run in background
# echo '$SHELL' >> exec.sh;
# chmod +x exec.sh;
# $shell_cmd "$directory/exec.sh";

# # Sleeps are needed to wait for the scp to occur and keygen to happen
# sleep 2
# echo " **** Executing SCP Copy **** ";
# $shell_cmd "scp $user_str@$server_str${ext_node_id_ary[0]}$suffix_str:.ssh/authorized_keys tmp_keys"
# # git-bash -e scp LutzD00D@apt137.apt.emulab.net:.ssh/authorized_keys tmp_keys
# sleep 2
# $shell_cmd "scp tmp_keys $user_str@$server_str${ext_node_id_ary[1]}$suffix_str:.ssh/authorized_keys"
# $shell_cmd "scp tmp_keys $user_str@$server_str${ext_node_id_ary[2]}$suffix_str:.ssh/authorized_keys"
# $shell_cmd "scp tmp_keys $user_str@$server_str${ext_node_id_ary[3]}$suffix_str:.ssh/authorized_keys"


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
