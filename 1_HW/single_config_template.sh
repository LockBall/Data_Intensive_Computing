#!/bin/bash
## Single Node Config File ##
DataNodes_id_ary=("2" "3" "4"); # workers
ip_3="10.10.1.";
NN0="1";
DN1="2";
DN2="3";
DN3="4";

clean_hadoop=0
xml_modded="single_node";
xml_reset=0;
masters_reset=0;
workers_reset=0;
data_reset=0;