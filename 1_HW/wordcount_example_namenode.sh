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

##### HW 2 ######
# Add permissions for /mydata
# This was a permission issue when starting the nodes
# Permission of data directory needs to be drwx aroberge dic-uml-s23-PG0 group
sudo chown aroberge /mydata
sudo chgrp dic-uml-s23-PG0 /mydata/
sudo chmod 700 /mydata

# Download the 50 gig benchmark
wget ftp://ftp.ecn.purdue.edu/puma/wikipedia_50GB.tar.bz2
# wget ftp://ftp.ecn.purdue.edu/puma/sort_30GB.tar.bz2
mv wikipedia_50GB.tar.bz2 /mydata
# Untar the 50 gig benchmark this takes a decent amount of time 
tar xjf /mydata/wikipedia_50GB.tar.bz2 -C /mydata/

# Place the 50 gig benchmark in the hadoop fs
hadoop fs -put /mydata/wikipedia_50GB /
# Generate the 30G Terasort dataset
# Teragen generates 100 bytes per a record
# We want 30GB of data so 300000000 records to generate 
hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar teragen 300000000 /teragen

# Run wordcount
hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar wordcount /wikipedia_50GB/* /wordcount_out
# Run Grep 
hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar grep /wikipedia_50GB/ /grep_out anaconda
# Run terasort
hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar terasort /teragen /teragen_sorted



# Order that stuff was done #
# Moved the data directories to /mydata due to size constraints on local disk
# Had to do a little permission fix for the /mydata directory to allow for hadoop to edit it
# Set all the tmp directories for hadoop, yarn, mapred, hdfs to be in the /mydata directory due to local disk storage
# Increased the Java memory heap size to 8Gigs from default due to failing terasort due to insufficiant heap size
# Can probably go higher on the heap size it looked like the machines had 196GB 
# Set mapreduc.map.log.level and  mapreduc.reduce.log.level to warn to quiet the logging and run faster

# Run Multi node
# Run ssh_keys
# format hdfs
# get wikipidea tar
# move wikipidea tar to /mydata
# untar wikipedia (Takes a while)
# start-all.sh ##Start Hadoop
# add wikipedia to hadoop fs
# Use teragen to generate 30GB of data
# Run tests with above commands
# Wordcount (works)
# Grep (works)
# Terasort (works)
# TODO: Figure out a way to quiet hadoop INFO's when running commands

# How to time commands
# time -p <command>