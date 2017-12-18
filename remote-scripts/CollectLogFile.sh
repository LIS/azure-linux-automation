#!/bin/bash

dmesg > `hostname`-dmesg.txt
cp /var/log/waagent.log `hostname`-waagent.log.txt
uname -r > `hostname`-kernelVersion.txt
uptime -s > `hostname`-uptime.txt