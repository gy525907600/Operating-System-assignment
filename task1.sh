#! /bin/bash

#function for error checking
function error_exit()
{
echo $1
echo "Exiting................."
}


#function for main progress(adduser,password,group,sharefolder)
function run()
{
#get username
firstLetter=$(sed '1d' $file | cut -b 1)
lastName=$(sed '1d' $file | awk -F '[.@;]' '{print $2}')
IFS='
'
arrf=($firstLetter)
arrl=($lastName)

#get password
month=$(sed '1d' $file | awk -F";" '{print $2}' | cut -d '/' -f 2)
year=$(sed '1d' $file | awk -F";" '{print $2}' | cut -d '/' -f 1)
arrm=($month)
arry=($year)


#get groupname
groupone=$(sed '1d' $file | awk -F'[,;]' '{print $3}' )
grouptwo=$(sed '1d' $file | awk -F";" '{print $3}' | cut -d ',' -f 2)
arrgone=($groupone)
arrgtwo=($grouptwo)



#get sharefolder name
sharedFolder=$(sed '1d' $file | awk -F";" '{print $4}')
arrs=($sharedFolder)



#this loop creates a user,passwd,group,sharefolder at a time
for ((i=0;i<${#arrl[@]};i++))
do

#check whether group exist
#if group not exist create group
egrep "^${arrgone[$i]}" /etc/group >& /dev/null
#if [ $? -ne 0 ]
#then
#sudo groupadd ${arrgone[$i]}
#fi
egrep "^${arrgtwo[$i]}" /etc/group >& /dev/null
#if [ $? -ne 0 ]
#then
#sudo groupadd ${arrgtwo[$i]}
#fi

#create user and passwd
username=${arrf[$i]}${arrl[$i]}
password=${arrm[$i]}${arry[$i]}
echo "will create user: $username"
echo "password will be: $password"

#if user not exist, create user,set passwd(need change passwd when user first time login)
egrep "^$username" /etc/passwd >& /dev/null
#if [ $? -ne 0 ]
#then
#	sudo useradd -d /home/$username -m -s /bin/bash $username
#	echo -e "$password\n$password" | sudo passwd $username
#	sudo chage -d 0 $username
#fi


#add user in group
echo "will add $username in to group - ${arrgone[$i]}"
echo "will add $username in to group - ${arrgtwo[$i]}"
#sudo usermod -a -G ${arrgone[$i]} $username
#sudo usermod -a -G ${arrgtwo[$i]} $username


#sharefolder
#if directory not exist, create directory
echo "will create sharefolder /home${arrs[$i]}"
#if [ ! -n "${arrs[$i]}" ];
#then
#	if [[ ! -d "/home${arrs[$i]}" ]]
#	then
#		sudo mkdir /home${arrs[$i]}
#		echo ""
#	else
#		echo "directory exist"
#	fi

#	sudo chgrp ${arrgone[$i]} /home${arrs[$i]}
#	sudo chmod g+rwx /home${arrs[$i]}
#	sudo chmod o-rwx /home${arrs[$i]}
#fi

#alias
#if the user in sudo group
#create an alias off for systemctl poweroff
#if [[ ${arrgone[$i]} == "sudo" || ${arrgtwo[$i]} == "sudo" ]];
#then
#sudo echo 'alias off="systemctl poweroff"' > /home/${username[$i]}/.bash_aliases
#sudo source /home/${username[$i]}/.bashrc
#fi


echo "finished..........."
echo ""
done
}

#check whether the file can be read
#if file can be read, run the main function
#if file can not be read, exit
function readfile()
{
	if [ -r $file ];
	then
	run
	else
	error_exit "file can not read, please check permission"
	fi
}



function input()
{
# check whether input information is URL
http="http"
identifyUrl=$(echo ${input%%/*} | grep "${http}")

if [[ $identifyUrl != "" ]]
		then
#get the file name of URL
		file=${input##*/} 
#if file dons not exist, download file
#if file exist skip download
	if [[ ! -f "$file" ]];
		then
		wget $input
		else 
		echo "file exist, will skip download"		
	fi
#check the file permission and run
	readfile

#if argument not URL		
	else
# if local location exist, check permission and run
		file=$input
		if [ -f "$file" ];
			then 
			readfile
		else
			error_exit "file not found, please check again"
		fi
	fi
}

#check whether user input argument
if [ -n "$1" ]; then
	input=$1
	input

else
	echo "Please input a file or url:"
	read input
	input
fi

#cat users.csv | awk -F";" '{print $1}'

echo "##########################################"


