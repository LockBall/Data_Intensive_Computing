# ssh -o StrictHostKeyChecking=no -t LutzD00D@apt099.apt.emulab.net < wordcount_example_namenode.sh

#Format the file System
hdfs namenode -format
#Start everything
start-all.sh
# Make a directory in hfds
# Run wordcount <in> <outdir> 

hadoop fs -mkdir /tmpdir
hadoop fs -put to_count /tmpdir

hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar wordcount /tmpdir/to_count /tmpdir/out
