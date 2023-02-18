# ssh -o StrictHostKeyChecking=no -t LutzD00D@apt099.apt.emulab.net < wordcount_example_namenode.sh

echo " **** Performing HDFS format **** ";
hdfs namenode -format;

echo " **** start-all **** ";
start-all.sh

# echo " **** make tmp and to_count dir **** ";
# hadoop fs -mkdir -p /tmp/to_count

# echo " ****  Run wordcount <in> <outdir> **** "; 
# hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar wordcount /tmpdir/to_count /tmpdir/out
