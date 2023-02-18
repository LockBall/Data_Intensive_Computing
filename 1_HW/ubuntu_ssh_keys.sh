#!/bin/bash
#NOTE: you should only need to run this once
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


# ____________________ copy remote NameNode key to local machine ____________________
# __________ create local key directory & key comment file __________
if test -d "./remote_key/";
    then echo " **** local key directory already exists **** ";
    if (( $local_key_reset == 1 )) ;
        then echo " **** key reset enabled **** ";
        rm -r -f ./remote_key/;
        echo " **** re-making local key directory **** ";
        mkdir -p remote_key/
    fi
else
    echo " **** making local key directory **** ";
    mkdir -p remote_key/
fi

if test -f "./comment.txt";
    then echo " **** comment file already exists **** ";
else
    echo " **** making comment file **** ";
    touch comment.txt;
    echo ' # **** default keys above this line **** ' >> comment.txt;
    echo " # **** keys after this appended by ubuntu_ssh_keys $(date) **** " >> comment.txt;
fi
# __________ create local key directory & key comment file __________


# ____________________ The Keymaker ____________________
if test -f "./remote_key/id_rsa.pub";
    then echo " **** id_rsa.pub already exists **** ";
else
    echo " **** scp copy of remote NameNode to local machine **** ";
    scp $user_str@$server_str${ext_node_id_ary[0]}$suffix_str:/users/$user_str/.ssh/id_rsa.pub ./remote_key/
    #scp LutzD00D@apt136.apt.emulab.net:/users/LutzD00D/.ssh/id_rsa.pub ./remote_key/
fi


echo " **** copy remote NameNode key from local machine to remote DataNodes **** "
# https://stackoverflow.com/questions/23591083/how-to-append-authorized-keys-on-the-remote-server-with-id-rsa-pub-key
# cat ~/.ssh/id_rsa.pub | (ssh user@host "cat >> ~/.ssh/authorized_keys")

if test -f "./name_login_others.sh";
    then echo " **** removing old name_login_others file **** ";
    rm name_login_others.sh;
fi
echo " **** making name_login_others.sh **** ";
touch name_login_othersmment.sh;


if test -f "./remote_key/id_rsa.pub";
    then
    for ext_node_id_ary_pos in ${!ext_node_id_ary[@]};
        do
        ext_node_id=${ext_node_id_ary[$ext_node_id_ary_pos]};

        if (( $ext_node_id_ary_pos > 0 )); # nodes other than 0
            then echo " **** sending NameNode publickey to node $ext_node_id **** ";
            cat ./comment.txt | (ssh $user_str@$server_str$ext_node_id$suffix_str "cat >> ~/.ssh/authorized_keys");
            cat ./remote_key/id_rsa.pub | (ssh $user_str@$server_str$ext_node_id$suffix_str "cat >> ~/.ssh/authorized_keys");
            # cat ./comment.txt | (ssh LutzD00D@apt131.apt.emulab.net "cat >> ~/.ssh/authorized_keys");
            # cat ./remote_key/id_rsa.pub | (ssh LutzD00D@apt131.apt.emulab.net "cat >> ~/.ssh/authorized_keys");

            echo " **** populating name_login_others.sh for node $ext_node_id **** " ;
            echo "echo ssh -o StrictHostKeyChecking=no -t $user_str@$server_str$ext_node_id$suffix_str;" >> name_login_others.sh;
        else
            echo " **** skipping node $ext_node_id **** ";
        fi
    done
else
    echo " **** id_rsa.pub missing **** ";
fi
# ____________________ The Keymaker ____________________


# ____________________ Node0 (NameNode) initial login to DataNodes ____________________
ssh -o StrictHostKeyChecking=no -t $user_str@$server_str${ext_node_id_ary[0]}$suffix_str < name_login_others.sh;

# ____________________ Node0 (NameNode) wordcount example ____________________
ssh -o StrictHostKeyChecking=no -t $user_str@$server_str${ext_node_id_ary[0]}$suffix_str < wordcount_example_namenode.sh;
