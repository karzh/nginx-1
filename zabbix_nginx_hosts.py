#!/usr/bin/env python

import urllib2
import json
import re
import socket 
import socket
import fcntl
import struct
 
def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  
        struct.pack('256s', ifname[:15])
    )[20:24])

url = 'http://localhost:10010/domain_status?domain=getlist'

all_hosts = urllib2.urlopen(url).read()
hosts_list = all_hosts.split('\n')

data = {}
data['data'] = []

ip_m = re.compile(r'(10\.(\d+\.){2}\d+)\-(\d+)$')
url_m = re.compile(r'(?i)^([a-z0-9]+(-[a-z0-9]+)*\.)+(btime|btv)\.[a-z]{2,}\-\d+$')
in_IP = get_ip_address('eth0')
for host in hosts_list:
    if in_IP in host:
        continue
    else:
        ip = ip_m.match(host);
        url = url_m.match(host);
        if   ip or url:
            data['data'].append({"{#NGINXHOST}":host})


print json.dumps(data)
