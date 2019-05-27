#!/bin/bash

cd /tmp

echo ${ssh_keys} > /tmp/ssh_keys
cat /tmp/ssh_keys | while read ssh ; do
    echo $ssh >> /home/centos/.ssh/authorized_keys
done
rm /tmp/ssh_keys

sed -i 's/^\(PasswordAuthentication\).*/\1 yes/g' /etc/ssh/sshd_config
systemctl restart sshd

echo 'AnsibleLabs' | passwd centos --stdin
