#!/bin/sh

service nginx start
service php7.2-fpm start
/sbin/ifconfig lo down 

docker_gateway=`ip route | grep -o "via [^ ]*" | cut -d" " -f2`

ufw enable
ufw reject out to 10.0.0.0/8
ufw reject out to 169.254.0.0/16
ufw reject out to 172.16.0.0/12
ufw reject out to 192.168.0.0/16
ufw insert 1 allow out to $docker_gateway 
ufw allow from $docker_gateway to any port 80
ufw allow from $docker_gateway to any port 443

#Further hardening
tcpports=`cat /netstat_output | grep ^tcp | grep LISTEN | awk '{print $4}' | grep -v "^127\|^::1" | awk -F: '{print $NF}' | sort | uniq | tr "\n" " "`
udpports=`cat /netstat_output | grep ^udp | grep LISTEN | awk '{print $4}' | grep -v "^127\|^::1" | awk -F: '{print $NF}' | sort | uniq | tr "\n" " "`

for port in $tcpports
	do ufw insert 1 deny out to $docker_gateway port $port proto tcp
done 

for port in $udpports
	do ufw insert 1 deny out to $docker_gateway port $port proto udp
done 

#Setting DNS server
echo nameserver 8.8.8.8 > /etc/resolv.conf
