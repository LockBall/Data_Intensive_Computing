#!/bin/bash
#NOTE: you should only need to run this once
config_file="multi_config.sh";
local_place="./promceph/.";
remote_place="/usr/local/promceph/";

if test -f $config_file;
    then echo " **** Config File Exists, source it. **** ";
    source ./$config_file;
else
    echo " **** Config File Template Copied **** ";
    echo " **** ENTER USER VALUES INTO MULTI LOCAL $config_file **** ";
    cp multi_config_template.sh $config_file;
    exit
fi


echo -e " **** sending PromCeph $local_place to $remote_place **** ";

for ext_node_id in ${ext_node_id_ary[@]};
    do
    echo " **** to node $ext_node_id **** ";
    scp -r $local_place $user_str@$server_str${ext_node_id}$suffix_str:$remote_place;
done

