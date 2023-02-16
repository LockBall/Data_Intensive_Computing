ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa -y
cat .ssh/id_rsa.pub >> ~/.ssh/authorized_keys
echo ssh -o StrictHostKeyChecking=no -t aroberge@node0.hw1node4.dic-uml-s23-pg0.wisc.cloudlab.us;
$SHELL
