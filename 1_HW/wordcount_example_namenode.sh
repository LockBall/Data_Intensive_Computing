# ssh -o StrictHostKeyChecking=no -t LutzD00D@apt099.apt.emulab.net < wordcount_example_namenode.sh
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

echo " **** Performing HDFS format **** ";
hdfs namenode -format;

echo " **** start-all **** ";
start-all.sh


hadoop fs -mkdir -p /tmp/

hadoop fs -put around_the_world.txt /tmp/around_the_world.txt

# echo " ****  Run wordcount <in> <outdir> **** "; 
hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar wordcount /tmp/around_the_world.txt /tmp/out

#Get output from wordcount
hadoop fs -get /tmp/out local_out
#Output is at local_out/part-r-xxxx