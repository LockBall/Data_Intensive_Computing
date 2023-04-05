#!/bin/bash
config_file="multi_config.sh";
directory=$(pwd);

# ____________________ PromCeph ____________________
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

# run the per node files
for ext_node_id in ${ext_node_id_ary[@]};
    do
    echo " **** running file $ext_node_id$repo_name.sh"; 
    $shell_cmd "$directory/$ext_node_id$repo_name.sh" & # & with no ; to run in background
done


