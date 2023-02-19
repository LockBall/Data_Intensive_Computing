# ssh -o StrictHostKeyChecking=no -t LutzD00D@apt099.apt.emulab.net < wordcount_example_namenode.sh

echo " **** Performing HDFS format **** ";
hdfs namenode -format;

echo " **** start-all Apache Hadoop daemons**** ";
# this will also add the other nodes to the list of knwon hosts
start-all.sh

echo " **** creating tmp dir & upload txt file**** "
hadoop fs -mkdir /tmp/
hadoop fs -put around_the_world.txt /tmp/around_the_world.txt

echo " ****  Run wordcount <in> <outdir> **** "; 
hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar wordcount /tmp/around_the_world.txt /tmp/out

#Get output from wordcount
hadoop fs -get /tmp/out local_out

#Output is at local_out/part-r-xxxx
nano ~/local_out/part-r-00000 _SUCCESS