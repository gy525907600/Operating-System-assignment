#!/bin/bash

function error_exit()
{
echo $1
echo "exiting..."
exit 1
}

# main function for copy tar.gz to remote server
function run()
{
#compressed file
filename=${input##*/}
echo "will comprese file"
tar -cvf $filename.tar.gz $input
if [ $? -eq 0 ];
then
	echo "==== compress successfully ===="
else
	error_exit "==== compress unsuccessfully ===="
fi

#read input
echo "Please input IP address or URL of the remote server"
read remoteserve

#check whether the IP address exists	
if nc -z $remoteserve 22 2>/dev/null; then
	echo " "
else
	error_exit "==== can not found $remoteserve ===="
	
fi
	
echo "Please input port number of the remote serve"
read port
echo "Please input the path of target directory"
read target

#Check wheter the target directory exist
echo "will check wheter the target directory exist"
if ssh $remoteserve test -d $target;
then
	echo "==== $target exists, will transfer the file ===="
else
	error_exit "==== can not found $target ===="	
fi

#transfer file to remote serve
scp -P $port $filename.tar.gz $USER@$remoteserve:"$target"
if [ $? -eq 0 ];then
	echo " "
else
	error_exit "transfer unseccussfully"
fi

#check whether this file transsfer successfully"	
echo "will check whether the file on the remote server"
sshhost="server"
file="$target/$filename.tar.gz"
if ssh $remoteserve test -e $file;	
then
	echo "==== correct ===="
else	
	error_exit "$file transferred unsuccessfully"
fi

echo "finished..."
}

function checkInput()
{

     	if [[ -d $input || -f $input ]]; then
		run
	else
		error_exit "No such file or directory"
	fi
}

#check whether input argument
if [ "$1" != "" ]; then
	input=$1
	checkInput
else 
	echo "Please input a directory name: "
	read input
	checkInput
fi

