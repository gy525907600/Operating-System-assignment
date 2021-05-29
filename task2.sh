#!/bin/bash

# A function of transferring tar.gz to remote servea
function transfer()
{
#generate a compressed tarball archive of the target directory
	tar -cvf $dir.tar.gz $dir

#prompt the user during execution for the following details
	echo "Please input IP address or URL of the remote server"
	read remoteserve

#check whether the IP address exists	
	if nc -z $remoteserve 22 2>/dev/null; then
		echo "$remoteserve exists"
	else
		echo "Not found $remoteserve"
		exit 1
	fi
	
	echo "Please input port number of the remote serve"
	read port
	echo "Please input the path of target directory"
	read target
	echo "Chcking wheter the target directory exists>>>>>>"
	if ssh $remoteserve test -d $target;
	then
		echo "$target exists"
	else
		echo "Not found $target, exiting..."
		exit 1
	fi

#transfer file to remote serve
	echo "transferring the file..."
	scp -P $port $dir.tar.gz $USER@$remoteserve:"$target"

	echo "Checking whether this file transsfer successfully>>>>>>"	
	sshhost="server"
	file="$target/$dir.tar.gz"
	if ssh $remoteserve test -e $file;	
	then
		echo "$file exists, transferred successfully!"
	else	
		echo "$file does not exist, exiting..."
		exit 1
	fi
}


#check whether the argument is Null or not
if [ "$1" != "" ]; then
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	if [ -d $1 ]; then
		dir=$1
		transfer
	else
		echo "No such file or directory, please try again!"
		echo "exit....................."
		exit 1	
	fi
else 
	echo "Please input a directory name: "
	read dir
	if [[ ! -d $dir ]]; then
		echo "No such file or directory, please try again!"
		echo "exit....................."
		exit 1
	else
		transfer
	fi
fi

