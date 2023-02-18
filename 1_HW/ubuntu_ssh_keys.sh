#!/bin/bash

config_file="multi_config.sh";

if test -f $config_file;
    then echo " **** Config File Exists, source it. **** ";
    source ./$config_file;
else
    echo " **** Config File Template Copied **** ";
    echo " **** ENTER USER VALUES INTO MULTI LOCAL $config_file **** ";
    cp multi_config_template.sh $config_file;
    exit
fi

NameNode_id="${ext_node_id_ary[0]}";

# ____________________ BEGIN copy remote NameNode key to local machine ____________________

# create local key directory
if test -d "./remote_key/";
    then echo " **** local key directory already exists **** ";
else
    echo " **** making local key directory **** ";
    mkdir -p remote_key/
fi

# scp <remote_user_name>@remote_IP:./<remote_file_name> ./
# scp LutzD00D@apt007.apt.emulab.net:./test.txt ./;
# scp LutzD00D@apt007.apt.emulab.net:/users/LutzD00D/.ssh/id_rsa.pub ./remote_key/;

if test -f "/users/$user_str/.ssh/id_rsa.pub";
    then echo " id_rsa.pub already exists";
else
    echo "scp "
scp $user_str@$server_str$NameNode_id$suffix_str:/users/$user_str/.ssh/id_rsa.pub ./remote_key/;

