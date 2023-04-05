#!/bin/bash
## Multi Node Config File ##
ext_node_id_ary=("000" "000" "000" "000"); # end of external ip of machines we need to ssh to
int_node_id_ary=("1" "2" "3" "4"); # end of internal ip
windows=0;
user_str="aroberge"; # update me with your username, LutzD00D    aroberge
server_str="node"; # update me with your server, apt
suffix_str=".hw1node4.dic-uml-s23-pg0.wisc.cloudlab.us";
# .apt.emulab.net
# .hw1node4.dic-uml-s23-pg0.wisc.cloudlab.us

promceph_reset=0;
repo_name="promceph";
git_access_token="";
