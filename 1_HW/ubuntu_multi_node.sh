
#!/bin/bash
# John Lutz - 13 Feb 2023
# chmod a+x <filename> to set execute permissions for this file
# ssh LutzD00D@apt099.apt.emulab.net < ubuntu_single_node.sh
    
cmd_str="ssh -t ";
user_str="LutzD00D";
server_str="@apt";
node_id_ary=("099" "106"); # "102" "116"
suffix_str=".apt.emulab.net";
script_str=" < ubuntu_single_node.sh";

for node_id in ${node_id_ary[@]}; do
    final_cmd_str="$cmd_str$user_str$server_str$node_id$suffix_str$script_str";    
    echo $final_cmd_str;
    eval $final_cmd_str;
done