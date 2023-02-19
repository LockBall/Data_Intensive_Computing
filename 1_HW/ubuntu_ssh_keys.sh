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


# __________ create local key directory & key comment file __________
if test -f "./comment.txt";
    then echo " **** comment file already exists **** ";
else
    echo " **** making comment file **** ";
    touch comment.txt;
    echo ' # **** default keys above this line **** ' >> comment.txt;
    echo " # **** keys after this appended by ubuntu_ssh_keys $(date) **** " >> comment.txt;
fi


if test -d "./remote_key/";
    then echo " **** local key directory already exists **** ";
        echo " **** removing local key directory **** ";
        rm -r -f ./remote_key/;
fi
echo " **** making local key directory **** ";
mkdir -p remote_key/


if test -f "./name_login_others.sh";
    then echo " **** removing old name_login_others file **** ";
    rm name_login_others.sh;
fi
echo " **** making name_login_others.sh **** ";
touch name_login_othersmment.sh;
# __________ create local key directory & key comment file __________

# send the NameNode a good read
scp around_the_world.txt $user_str@$server_str${ext_node_id_ary[0]}$suffix_str:~/around_the_world.txt

# ____________________ The Keymaker ____________________
if test -d "./remote_key/";
    then echo " **** scp copy of remote NameNode id_rsa.pub to local machine **** ";
    scp $user_str@$server_str${ext_node_id_ary[0]}$suffix_str:/users/$user_str/.ssh/id_rsa.pub ./remote_key/
    #scp LutzD00D@apt136.apt.emulab.net:/users/LutzD00D/.ssh/id_rsa.pub ./remote_key/
else
    echo " **** remote_key directory missing **** ";

fi

echo " **** copy remote NameNode key from local machine to remote DataNodes **** "
# https://stackoverflow.com/questions/23591083/how-to-append-authorized-keys-on-the-remote-server-with-id-rsa-pub-key
# cat ~/.ssh/id_rsa.pub | (ssh user@host "cat >> ~/.ssh/authorized_keys")

if test -f "./remote_key/id_rsa.pub";
    then
    for ext_node_id in ${ext_node_id_ary[@]};
        do
        echo " **** sending NameNode publickey to node $ext_node_id **** ";
        cat ./comment.txt | (ssh $user_str@$server_str$ext_node_id$suffix_str "cat >> ~/.ssh/authorized_keys");
        cat ./remote_key/id_rsa.pub | (ssh $user_str@$server_str$ext_node_id$suffix_str "cat >> ~/.ssh/authorized_keys");
        # cat ./comment.txt | (ssh LutzD00D@apt131.apt.emulab.net "cat >> ~/.ssh/authorized_keys");
        # cat ./remote_key/id_rsa.pub | (ssh LutzD00D@apt131.apt.emulab.net "cat >> ~/.ssh/authorized_keys");

        echo " **** populating name_login_others.sh for node $ext_node_id **** " ;
        echo "echo ssh -o StrictHostKeyChecking=no -t node$ext_node_id_ary_pos;" >> name_login_others.sh;
    done
else
    echo " **** id_rsa.pub missing **** ";
fi
# ____________________ The Keymaker ____________________


# ____________________ Node0 (NameNode) initial login to DataNodes ____________________
ssh -o StrictHostKeyChecking=no -t $user_str@$server_str${ext_node_id_ary[0]}$suffix_str < name_login_others.sh;

