#!/bin/bash
#
# This script serves as iperf client.
# Author: Srikanth M
# Email	: v-srm@microsoft.com
#

if [[ $# == 3 ]]
then
	server_ip=$1
	username=$2
	testtype=$3
	if [[ $testtype == "UDP" ]]
	then
		testtype=" -u"
	else
		testtype=""
	fi
else
	echo "Usage: bash $0 <server_ip> <vm_loginuser>"
	exit -1
fi

code_path="/home/$username/code/"
. $code_path/azuremodules.sh

if [[ `which iperf3` == "" ]]
then
    echo "iperf3 not installed\n Installing now..."
    install_package "iperf3"
fi

echo "Sleeping 5 mins to get the server ready.."
sleep 300
port_number=8001
duration=300
code_path="/home/$username/code/"
for number_of_connections in 1 2 4 8 16 32 64 128 256 512 1024
do
	bash $code_path/sar-top.sh $duration $number_of_connections $username&

	echo "Starting client with $number_of_connections connections"
	while [ $number_of_connections -gt 64 ]; do
		number_of_connections=$(($number_of_connections-64))
		iperf3 -c $server_ip -p $port_number -P 64 -t $duration $testtype > /dev/null &
		port_number=$((port_number+1))
	done
	if [ $number_of_connections -ne 0 ]
	then
		iperf3 -c $server_ip -p $port_number -P $number_of_connections -t $duration $testtype > /dev/null &
	fi

	connections_count=`netstat -natp | grep iperf | grep ESTA | wc -l`
	echo "$connections_count iperf clients are connected to server"
	sleep $(($duration+10))
done

logs_dir=logs-`hostname`-`uname -r`-`get_lis_version`/

collect_VM_properties $code_path/$logs_dir/VM_properties.csv

bash $code_path/generate_csvs.sh $code_path/$logs_dir
mv /etc/rc.d/after.local.bkp /etc/rc.d/after.local
mv /etc/rc.local.bkp /etc/rc.local
mv /etc/rc.d/rc.local.bkp /etc/rc.d/rc.local
