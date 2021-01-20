#!/bin/bash

 user="$(whoami)"
 setup_path=/setup
 conf_save=$setup_path/conf_backup
 conf_test=$setup_path/tester
 


if [  $user != root ]
 then

	echo "Für dieses Script musst du root sein. Ich mach das schon :D 
Allerdings musst du jetzt das Script neu starten. Lege vorher ein
neues Passwort für den Nutzer $user fest.

	"
	passwd
	sudo su
fi
 

if [ ! -d "$setup_path" ];then
	echo "Das Setup-Verzeichnis existiert nicht. Wird erstellt."
	sudo mkdir $setup_path/
fi

if [ ! -d "$conf_save" ];then
	sudo mkdir $conf_save
fi

if [ ! -d "$conf_test" ];then
	sudo mkdir $conf_test
fi
 
 
clear

 echo "
 Raspberry-Pi Configurator für die erstinstallation und config des Pi's.
 -------------------------------------------------------------------------
 "
 echo " Die Programme / Konfigurationspunkte :
 ----------------------------------------------
  
*Hostname 
(ändert den Standart-Hostnamen der Standart ist raspberrypi)
 -----------------------------------------------------------
*Remote-Desktop 
(Bietet die möglichkeit virtuellem Desktop zuzugreifen.)
 -------------------------------------------------------
 Rootlogin 
(Bietet die möglichkeit als root via SSH zuzugreifen.)
 ----------------------------------------------------------
 fstab 
(fügt zu mountende Adressen zur fstab hinzu)
 --------------------------------------------
 Java (installiert Java)
 -------------------------
 Screen (installiert Screen)
 ------------------------------
 ZIP 
(installiert ZIP um zip Archive erstellen und entpacken zu können.)
 -------------------------------------------------------------------
 SAMBA 
(installiert und Konfiguriert SAMBA um auf den PI als Netzlaufwerk zugreifen zu können.)
 ----------------------------------------------------------------------------------------
 *Raspi-config 
(öffnet Abschließend die Raspi-config um Sprache, Uhrzeit etc. einstellen zu können
 -----------------------------------------------------------------------------------
 
 
 Du kannst jetzt entscheiden was du installieren möchtest. 
 Mit * markierte werden immer Ausgeführt
 ----------------------------------------------------------
 "
 
 echo "Alles installieren | Individuell A/I
 "
 
 read gesamt
 
 if [ $gesamt == "A" ] || [ $gesamt == "a" ];then
	
		wahl_root=y
	
		wahl_fstab=y
		echo "Lokalen Mount-Pfad angeben: (beispiel : /mnt/Filme/"
		read fstab_mnt
		echo "Mount IP-Adresse: (zb : 192.168.1.2)"
		read mnt_ip
		echo "Mount Freigabe: (zb : /export/beispiel)"
		read mnt_share
		echo "Mehrere Mount-eingaben? Y/N?"
		read repeat
	
		wahl_java=y
	
		wahl_screen=y

		wahl_zip=y

		wahl_samba=y
		echo "SAMBA-Gruppen-Name:"
		read name
		
 else
 
	if [ ! -e "$conf_test/rootlogin.txt" ];then 
		
		echo "Rootlogin via SSH erlauben?"
		read wahl_root
	fi
	
	if [ ! -e "$conf_test/fstab.txt" ];then
		 
		echo "Möchtest du die fstab anpassen ? Y/N"
		read wahl_fstab
		if [ $wahl_fstab == "Y" ] || [ $wahl_fstab == "y" ]
		then
			echo "" >> $conf_test/fstab.txt
			echo "Lokalen Mount-Pfad angeben: (beispiel : /mnt/Filme/"
			read fstab_mnt
			echo "Mount IP-Adresse: (zb : 192.168.1.2)"
			read mnt_ip
			echo "Mount Freigabe: (zb : /export/beispiel)"
			read mnt_share
			echo "Mehrere Mount-eingaben? Y/N?"
			read repeat
		fi
	fi
	
	if [ ! -e "$conf_test/java.txt" ];then 
		echo "Möchtest du Java installieren ? Y/N"
		echo "" >> $conf_test/java.txt
		read wahl_java
	fi
	
	if [ ! -e "$conf_test/screen.txt" ];then 
		echo "Möchtest du Screen installieren ? Y/N"
		echo "" >> $conf_test/screen.txt
		read wahl_screen
	fi
	
	if [ ! -e "$conf_test/zip.txt" ];then  
		echo "Möchtest du zip installieren ? Y/N"
		echo "" >> $conf_test/zip.txt
		read wahl_zip
	fi
	
	if [ ! -e "$conf_test/samba.txt" ];then 
		echo "" >> $conf_test/samba.txt 
		echo "Möchtest du SAMBA installieren ? Y/N"
		read wahl_samba
		if [ $wahl_samba == "Y" ] || [ $wahl_samba == "y" ]
		then
			echo "SAMBA-Gruppen-Name:"
			read name
		fi
	fi
 fi
	
 
###############----Hostname----####################

 if [ ! -e "$conf_test/hostname.txt" ];then 
 echo "" >> $conf_test/hostname.txt
 echo "Hostname ändern in : (standart raspberrypi)"
 read hostname
 sudo cp /etc/hostname $conf_save/hostname
 echo $hostname > /etc/hostname
 fi
 
 sudo apt-get update
 
 
################----Static-IP----###################
 
 if [ ! -e "$conf_test/static-ip.txt" ];then 
 echo "" >> $conf_test/static-ip.txt
 echo "Statische IP-Adresse zuweisen"
 echo ""
 echo "IP-Adresse :	(beispel: 192.168.2.234)"
 read static_ip
 echo "Gateway :	(beispel: 192.168.0.1)"
 read gateway
 sudo service dhcpcd start
 sudo systemctl enable dhcpcd
 sudo cp /etc/dhcpcd.conf $conf_save/dhcpcd.conf
 echo "
interface eth0
static ip_address=$static_ip/24
static routers=$gateway
static domain_name_servers=$gateway
" >> /etc/dhcpcd.conf
 fi
 

##############----Remote-Desktop----################

 if [ ! -e "$conf_test/remote.txt" ];then 
 echo "" >> $conf_test/remote.txt
 sudo apt-get install xrdp -y
 sudo apt full-upgrade -y
 fi
 

##############----Rootlogin----##############

 if [ $wahl_root == "Y" ] || [ $wahl_root == "y" ] 
 then
   	if [ ! -e "$conf_test/rootlogin.txt" ];then 
		echo "" >> $conf_test/rootlogin.txt 
		echo rootlogin.txt
		
		echo "" >> $conf_test/rootlogin.txt
		sudo cp /etc/ssh/sshd_config $conf_save/sshd_config
		sudo sed -i -e 32c"PermitRootLogin yes" /etc/ssh/sshd_config
		echo "Neues Root-Passwort:"
		passwd
	fi
 fi


###############----fstab----################

 if [ $wahl_fstab == "Y" ] || [ $wahl_fstab == "y" ] 
 then
 	if [ ! -e "$conf_test/fstab.txt" ];then
		echo "" >> $conf_test/fstab.txt 

		cp /etc/fstab $conf_save/fstab
		if [ ! -d "$fstab_mnt" ];then
			echo "Das Verzeichnis existiert nicht. Wird erstellt."
			mkdir $fstab_mnt
		fi
		echo "$mnt_ip:$mnt_share $fstab_mnt nfs rw 0 0" >> /etc/fstab
		while  [ $repeat == "Y" ] || [ $repeat == "y" ] 
			do
				echo "Lokalen Mount-Pfad angeben: (beispiel : /mnt/Filme/"
				read fstab_mnt
				echo "Mount IP-Adresse: (zb : 192.168.1.2)"
				read mnt_ip
				echo "Mount Freigabe: (zb : /export/beispiel)"
				read mnt_share
			
			if [ ! -d "$fstab_mnt" ];then
				echo "Das Verzeichnis existiert nicht. Wird erstellt."
				mkdir $fstab_mnt
			fi
			
			echo "$mnt_ip:$mnt_share $fstab_mnt nfs rw 0 0" >> /etc/fstab
			echo "Weiteren Pfad eingeben? Y/N"
			read repeat
		done
		mount -a
	fi
 fi



###############----Java----################

 if [ $wahl_java == "Y" ] || [ $wahl_java == "y" ] 
 then
 	if [ ! -e "$conf_test/java.txt" ];then 
		echo "" >> $conf_test/java.txt
		
		sudo apt-get install openjdk-11-jre-headless -y
	fi
 fi
 

###############----Screen----################

 if [ $wahl_screen == "Y" ] || [ $wahl_screen == "y" ] 
 then
 	if [ ! -e "$conf_test/screen.txt" ];then 
		echo "" >> $conf_test/screen.txt 
	fi
	 sudo apt-get install screen -y
 fi

 
 ###############----ZIP----################
 
 if [ $wahl_zip == "Y" ] || [ $wahl_zip == "y" ] 
 then
 	if [ ! -e "$conf_test/zip.txt" ];then 
		echo "" >> $conf_test/zip.txt 
	fi
	sudo apt-get install zip -y
 fi
 
 
##############----SAMBA----################

 if [ $wahl_samba == "Y" ] || [ $wahl_samba == "y" ]
 then
 	if [ ! -e "$conf_test/samba.txt" ];then 
		echo "" >> $conf_test/samba.txt
	fi
 echo Samba install-Script
 pfad=/
 sudo apt-get update
 sudo apt-get install samba samba-common smbclient -y
 sudo cp /etc/samba/smb.conf $conf_save/smb.conf
 sudo sed -i -e 175c"   read only = no" /etc/samba/smb.conf
 echo "
[$name]
comment=Raspberry Pi
path=/
browseable = yes
guest ok = no
public = yes
writeable = yes
create mask = 0777
directory mask = 0777
" >> /etc/samba/smb.conf
 
 sudo chown root:root $pfad
 sudo chown pi:pi $pfad
 echo "Vergebe ein Passwort für deine Dateien: (muss bei Windows eingegeben werden)"
 smbpasswd -a root
 sudo service nmbd restart && sudo service smbd restart
 fi
 
  #############----Autostart----#########
  
 if [ ! -e "$conf_test/autostart.txt" ];then 
 echo "" >> $conf_test/autostart.txt 
 
 autostart_script=/autostart/autostart.sh
 
 if [ ! -d /autostart ];then
	sudo mkdir /autostart
 fi
 if [ ! -e $autostart_script ];then
	sudo sed -i 's/^exit/\/autostart\/autostart.sh \n\n&/' /etc/rc.local
 fi
echo "#!/bin/bash
 ### Autostart-Script ###
 sleep 15s
 sudo mount -a
 sudo ping -i 300 google.de
 exit 0
  
 " > $autostart_script
 
 chmod +x $autostart_script
 fi
 
 #############----Raspi-config----#########

 if [ ! -e "$conf_test/raspi_config.txt" ];then 
 echo "" >> $conf_test/raspi_config.txt 
 sudo raspi-config
 fi


 COUNTER=5
 while [  $COUNTER -gt 0 ]; do
 echo Neustart in $COUNTER Sekunden.
 sleep 1s
 let COUNTER=COUNTER-1 
 done

 sudo reboot
