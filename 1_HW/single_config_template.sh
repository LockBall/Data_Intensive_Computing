#!/bin/bash
## Single Node Config File ##
DataNodes_id_ary=("2" "3" "4"); # workers
reset_workers=0 # set to 1 to delete and regenerate workers file
clean_hadoop=1
ip_3="10.10.1.";
NN0="1";
DN1="2";
DN2="3";
DN3="4";

xml_modded="single_node";
masters_reset=0;
workers_reset=0;
data_reset=0;