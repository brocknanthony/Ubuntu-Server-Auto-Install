#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This Script must be run as root"
	exit 1
fi

#Modes (Variables)
# b=backup i=install r=restore u=update U=Force Update 
mode="$1"

Programloc=/opt/CouchPotatoServer/
backupdir=/opt/backup/CouchPotatoServer
time=$(date +"%m_%d_%y-%H_%M")

case $mode in
	(-i|"")
	apt install git-core python python-cheetah python-pyasn1 python3-lxml -y
	adduser --disabled-password --system --home /opt/ProgramData/couchpotato --gecos "CouchPotato Service" --group couchpotato
	echo "<--- Downloading latest CouchPotato --->"
	cd /opt && sudo git clone https://github.com/CouchPotato/CouchPotatoServer.git
	chown -R couchpotato:couchpotato $Programloc
	chmod -R 0777 $Programloc
	echo "Creating Startup Script"
	cp /opt/install/CouchPotato/couchpotato.service /etc/systemd/system/
	chmod 644 /etc/systemd/system/couchpotato.service
	systemctl enable couchpotato.service
	systemctl restart couchpotato.service 
	;;
	(-r)
	echo "<--- Restoring CouchPotato Settings --->"
	echo "Stopping CouchPotato"
	systemctl stop couchpotato
	chmod -R 0777 /opt/ProgramData/couchpotato
	#NEEDS TO BE EDITED FOR UNZIP TAR FILE TO RESTORE SETTINGS VS SINGLE FILE RESTORE
	cp /opt/install/CouchPotato/CouchPotato.txt /opt/ProgramData/couchpotato/.couchpotato/settings.conf
	echo "Starting CouchPotato"
    	systemctl start couchpotato	
	;;
	(-b)
	echo "Stopping CouchPotato"
    	systemctl stop couchpotato
    	echo "Making sure Backup Dir exists"
    	mkdir -p $backupdir
    	echo "Backing up CouchPotato to /opt/backup"
	cp /opt/ProgramData/couchpotato/.couchpotato/settings.conf $backupdir
	echo "Data Folder might be located under /root/.couchpotato/ if theres a Data Folder created"
	echo "some install dont have it"
	cp /opt/CouchPotatoServer/Data $backupdir
    	tar -zcvf /opt/backup/CouchPotato_FullBackup-$time.tar.gz $backupdir
    	echo "Restarting up CouchPotato"
	systemctl start couchpotato
	;;
	(-u)
	echo "Stopping CouchPotato to Update"
	sudo systemctl stop couchpotato
	sleep 5
	cd $Programloc
	git pull
	echo "Starting CouchPotato"
	sudo systemctl start couchpotato
	;;
	(-U)
	echo "Stopping CouchPotato to Force Update"
	sudo systemctl stop couchpotato
	sleep 5
	cd $Programloc
	git fetch --all
	git reset --hard origin/master
	git pull
	echo "Starting CouchPotato"
	sudo systemctl start couchpotato
	;;
    	(-*) echo "Invalid Argument"; exit 0;;
esac
exit 0
