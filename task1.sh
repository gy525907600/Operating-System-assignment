#! /bin/bash

#function for error checking
function error_exit()
{
echo $1
echo "Exiting................."
exit 1
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
groupone=$(sed '1d' $file | awk -F'[,;]' '{if($3 == "") {print "empty";} else {print $3;}}' )
grouptwo=$(sed '1d' $file | awk -F";" '{if($3 == "") {print "empty";} else {print $3;}}' | cut -d ',' -f 2)
arrgone=($groupone)
arrgtwo=($grouptwo)


#get sharefolder name
sharedFolder=$(sed '1d' $file | awk -F";" '{if($4 == "") {print "empty";} else {print $4;}}')
arrs=($sharedFolder)

echo ""
# ask user whether they want to continue
echo "Totally will add ${#arrl[@]} user. Please input [yes] or [no] to continue..."
read continue
if [[ $continue = "yes" ]];
then


#this loop creates a user,passwd,group,sharefolder at a time
for ((i=0;i<${#arrl[@]};i++))
do

#set the number for each user
num=$(($i+1))

#check whether group exist
#if group not exist, create group
echo ">>>>>>      $num         >>>>>>"
if [ ${arrgone[$i]} != "empty" ];
then
	egrep "^${arrgone[$i]}" /etc/group >& /dev/null
	if [ $? -ne 0 ]
	then
		echo "will create group - ${arrgone[$i]}"
		sudo groupadd ${arrgone[$i]}
		if [ $? -eq 0 ];
		then
			echo "==== group create successfully ===="
		else
			error_exit "==== group create successfully ===="
		fi
	fi
	echo " "
fi



if [ ${arrgtwo[$i]} != "empty" ];
then
	egrep "^${arrgtwo[$i]}" /etc/group >& /dev/null
	if [ $? -ne 0 ]
	then
	echo "will create group - ${arrgone[$i]}"
	sudo groupadd ${arrgtwo[$i]}
		if [ $? -eq 0 ];
		then
			echo "==== group create successfully ===="
		else
			error_exit "==== group create successfully ===="
		fi
	fi
	echo " "
fi


#create user and passwd
username=${arrf[$i]}${arrl[$i]}
password=${arrm[$i]}${arry[$i]}

#if user not exist, create user,set passwd(need change passwd when user first time login)
echo "will create user: $username"
echo "password will be: $password"
egrep "^$username" /etc/passwd >& /dev/null
if [ $? -ne 0 ]
then
	
	sudo useradd -d /home/$username -m -s /bin/bash $username
	if [ $? -eq 0 ];
	then
		echo "==== user create successfully ===="	
	else
		error_exit "==== user create unsuccessfully ===="
	fi
	echo -e "$password\n$password" | sudo passwd $username
	sudo chage -d 0 $username
else
	echo "the user -$username exist, will skip this step"
fi
echo " "


#add user in group
if [[ ${arrgone[$i]} != "empty" &&  ${arrgtwo[$i]} != "empty" ]];
then
	echo "will add $username in to group - ${arrgone[$i]}"
	sudo usermod -a -G ${arrgone[$i]} $username
	if [ $? -eq 0 ];
	then
		echo "==== add user in ${arrgone[$i]} group successfully ===="	
	else
		error_exit "==== add user in ${arrgone[$i]} unsuccessfully ===="
	fi	
	echo " "
	if [ ${arrgone[$i]} != ${arrgtwo[$i]} ];
	then
		echo "will add $username in to group - ${arrgtwo[$i]}"
		sudo usermod -a -G ${arrgtwo[$i]} $username
		if [ $? -eq 0 ];
			then	
			echo "==== add user in ${arrgtwo[$i]} group successfully ===="	
		else
			error_exit "==== add user in ${arrgtwo[$i]} unsuccessfully ===="
		fi
		echo " "
	fi
fi


#create sharefolder
#if directory not exist, create directory
if [ ${arrs[$i]} != "empty" ];
then
	echo "will create sharefolder /home/$username${arrs[$i]}"
	if [ -d "/home/$username${arrs[$i]}" ];
	then
		echo "folder exist, will skip this step"
	else
#create folder
		sudo mkdir "/home/$username${arrs[$i]}"
	fi
#change owner and group	
	if [ ${arrgone[$i]} != "empty" ];
	then
	sudo chown root:${arrgone[$i]} /home/$username${arrs[$i]}
	fi

	if [ ${arrgtwo[$i]} != "empty" ];
	then
	sudo chown root:${arrgone[$i]} /home/$username${arrs[$i]}
	fi
#change mode
	sudo chmod g+rwx /home/$username${arrs[$i]}
	sudo chmod o-rwx /home/$username${arrs[$i]}
	if [ $? -eq 0 ];
	then
		echo "==== sharefolder create successfully ===="	
	else		
		error_exit "==== sharefolder create unsuccessfully ===="
	fi
	echo " "

#create softlink for sharefolder
	echo "will create softlink for sharefolder"
	if [ -d "/home/$username/shared" ];
	then
		echo "link exist, will skip this step"
	else	
		sudo ln -s /home/$username${arrs[$i]} /home/$username/shared
		if [ $? -eq 0 ];
		then
			echo "==== sharefolder create successfully ===="	
		else	
			error_exit "==== sharefolder create unsuccessfully ===="
		fi
	
	fi	
	echo " "
fi


#alias
#if the user in sudo group
#create an alias off for systemctl poweroff
if [[ ${arrgone[$i]} == "sudo" || ${arrgtwo[$i]} == "sudo" ]];
then
	echo "this user in the sudo group, will set alias --"
	echo "alias off="'"systemctl poweroff"'"" | sudo tee /home/$username/.bash_aliases
	source /home/$username/.bashrc
	if [ $? -eq 0 ];
	then
		echo "==== alias create successfully ===="	
	else
		error_exit "==== alias create unsuccessfully ===="
	fi
	echo " "
fi

read -s -n1 -p "user $num finished, press any key to continue..."
echo " "
echo " "
echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::"
done

echo "finished..........."
echo ""

elif [[ $continue = "no" ]];
then
echo "will exit..."
else
echo "Please input [yes] or [no], exiting..."

fi

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


echo "##########################################"


