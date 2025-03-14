#!/bin/bash

#Script to Domain join a linux client/server to an active directory (AD) on a windows server.

#Sets variables for the script to use.
ADDC_IP=""
Test_Connection=""
New_Hostname=""
Linux_Server=""
NTP_IP=""
AD_USER=""
DOMAIN=""
Kinit_Error=""
Admin_Username=""

echo "Domain Join script for Linux have been booted."
echo "Press Enter to continue, or CTRL+C to stop the script."
read

IP_Address=$(hostname -I | awk '{print $1}')
Old_Hostname=$(hostname)

#Asks user to specify their domain to be used in the script.
echo "For Active Directory purposes what is the Domain used on the ADDC?"
echo "Example domain 'grp1.local'"
read DOMAIN
echo "$DOMAIN is the domain specified, using it in the script, press Enter to continue"
read

#Used to specify the Domain in uppercase letters
DOMAIN_UPPER="${DOMAIN^^}"

#To begin with we want to specify the host name for the machine to make sure you have the one you wishes to have in AD.
clear
echo "Current hostname is: $Old_Hostname"
echo "Do you wish to change this to a new name?"
echo "1 - YES"
echo "2 - NO"
read New_Hostname
case "$New_Hostname" in
    1)
        Old_Hostname=""
        echo "You have chosen: YES."
        echo "What do you wish your new hostname to be?"
        read new_hostname
        hostnamectl set-hostname $new_hostname
        echo "$IP_Address $new_hostname" | sudo tee -a /etc/hosts
        echo "$new_hostname have now been set as the new hostname."
        echo "Press enter to continue"
        read
    ;;

    2)
        echo "You have chosen: NO."
        echo "This means you wish to keep $Old_Hostname"
        echo "Press Enter to continue"
        read
    ;;
esac

if [[ -n "$Old_Hostname" ]]; then
  Hostname="$Old_Hostname"
elif [[ -n "$new_hostname" ]]; then
  Hostname="$new_hostname"
else
  Hostname="123"
fi

#Specify the IP for the AD domain controller and test connection.
clear
echo "Time to specify the domain controller."
echo "IPv4 format goes like 192.168.xxx.xxx."
echo "What is the IPv4 address for the Active Directory Domain Controller:"
read ADDC_IP
sudo bash -c echo $ADDC_IP $Hostname.grp1.local sbad >> /etc/hosts
echo "Domain Controller IP have been recorded, wish to test connection to it?"
echo "1 - YES"
echo "2 - NO"
read Test_Connection
case "$Test_Connection" in
    1)
        echo "You have chosen: YES"
        echo "Testing connection to the domain controller"
        ping -c 5 $Hostname.grp1.local
        echo "If connection did not work, press CTRL+C to end script and manually configuer ping issues"
        echo "Press Enter to continue"
        read
    ;;

    2)
        echo "You have chosen: NO"
        echo "Press Enter to continue"
        read
    ;;
esac

#Checks if you are running the script on a server or client then asks you to specify the NTP servers IP if on a static IP server.
clear
echo "Is this script ran on a Linux server/client with static IP? (NTP Server)"
echo "1 - YES"
echo "2 - NO"
read Linux_Server
case "$Linux_Server" in
    1)
        echo "You have chosen this script is being ran on a Linux server/client with static IP,"
        echo "this means you have to specify your NTP server (time server),"
        echo "echo what is the IPv4 on your NTP server? (format 192.168.xxx.xxx)."
        read NTP_IP
        sudo sed -i 's/sourcedir /run/chrony-dhcp/$NTP_IP/' /etc/chrony.conf
        echo "NTP server have been specified, enabling and resetting crony service to update it with the new IP."
        sudo systemctl enable chronyd
        sudo systemctl restart chronyd
        sudo systemctl enable chronyd
        echo "Chrony have been enabled and restartet and is ready to go."
        echo "Press Enter to continue"
        read
    ;;

    2)
        echo "You are not running on static IP, you can skip the NTP step since that will be propegated by DHCP."
        echo "Press Enter to continue"
        read
    ;;
esac

#Installing Samba suite and Winbind.
#Samba Share = SMB share protocol.
#Winbind = Allows Linux to interact with AD as a windows machine.
echo "Installing Samba suite (SMB share protocoll) and Winbind"
sudo dnf install samba samba-client samba-winbind samba-winbind-clients oddjob-mkhomedir -y

#Configuring Samba Realm and Workgroup
echo "Configuring Samba Real and Workgroup to match Domain and workgroup for AD."
sudo tee -a /etc/samba/smb.conf > /dev/null <<EOT
[global]
   security = ADS
   realm = $DOMAIN_UPPER
   workgroup = ${DOMAIN%%.*}
   encrypt passwords = yes
   winbind use default domain = yes
   winbind offline logon = yes
   idmap config * : backend = tdb
   idmap config * : range = 10000-99999
   template shell = /bin/bash
EOT
sudo systemctl restart smb winbind
echo "Realm and Workgroup have now been updated."
echo "Press enter to continue."
read
clear
echo "Lets make sure it is correctlly configured before we continue."
sudo cat /etc/samba/smb.conf | grep realm
sudo cat /etc/samba/smb.conf | grep workgroup
sudo cat /etc/samba/smb.conf | grep security
sudo cat /etc/samba/smb.conf | grep winbind seperator
echo "Does the settings look correct? windbind seperator needs to be '+' and security needs to be 'ADS'."
echo "Press Enter to contine if it looks fine or else use CTRL+C to stop script and manually configure"
read

#Enable winbind daemon
clear
echo "Time to enable the winbind daemon."
sudo systemctl enable winbind
echo "winbind daemon is now online."
echo "Press Enter to continue."
read

#Install Kerboros realms packege.
clear
echo "Now installing Kerboros realms package."
sudo sudo dnf install -y krb5-workstation
echo "Kerboros realms package have been installed."

#Adds Linux client/server to Active Directory hosted on Windows server.
clear
echo "What is the Active Directory Administator username? (windows server admin accunt)."
read Admin_Username
echo "Adding Linux client/server to Active Directory."
sudo net ads join -U $Admin_Username $DOMAIN_UPPER
echo "Linux client/server have been added to Active Directory."
echo "Check the Active Directory Domain Controller to validate this, if it is not added continue the script by pressing Enter"
echo "to figure out where the issue might be."
read

#Starts checks of services to make sure they are running correctlly.
clear
echo "Now we start the check of the services to make sure they are running correctlly if anything is not,"
echo "then the script can be stopped with CTRL+C."
echo "Is the winbind service running correctlly?"
echo "To run the check press Enter."
read
sudo systemctl status winbind
echo "If yes press Enter to continue."
read
echo ""
echo "Does the RPC calls succeed or fail?"
echo "To run the check press Enter."
read
sudo wbinfo -t
echo "If successful then press Enter to continue."
read
echo ""
echo "Can you see the users of the Active Directory?"
echo "To run the check press Enter."
read
sudo wbinfo -u
echo "If you are able to see the users press Enter to continue."
read
echo "Can you see the groups of the Active Directory?"
echo "To run the check press Enter."
read
sudo wbinfo -g
echo "If you are able to see the groups the winbind service is working correctlly."
echo "Press Enter to continue."
read

#Ensure winbind is selected as the authorization provider.
echo "Now we ensures winbind is selected as the authorization provider."
sudo authselect select winbind --force
echo "Now we have ensured winbind is selected as the authorization provider."

#Ensures passwd and groups are using winbind.
clear
echo "Now we need to ensure passwd and groups in the nsswitch.conf file is using winbind to pull login informations from the AD."
sudo sed -i 's/^passwd:.*$/passwd: files winbind/' /etc/nsswitch.conf
sudo sed -i 's/^group:.*$/group: files winbind/' /etc/nsswitch.conf
sudo sed -i 's/^shadow:.*$/shadow: files/' /etc/nsswitch.conf
sudo systemctl restart winbind
echo "Entries relyent on winbind have now been updated in nsswitch.conf."
echo "Press Enter to continue, otherwise CTRL+C to end the script."
read

#Use kinit to get a Kerberos TGT and to see if any errors.
clear
echo "Now on to test the Kerberos TGT system, for this you will need to know the 'Account Name' of a user in your AD."
echo "What user do you wish to use? and make sure it is the full Account Name as listed in the Active Directory"
read AD_USER
sudo kinit $AD_USER@$DOMAIN
sudo klist
echo "Do you recive any kinit errors?"
echo "1 - YES"
echo "2 - NO"
read Kinit_Error
case "$Kinit_Error" in
    1)
        echo "You have chosen YES to reciving kinit errors, lets try and fix this."
        echo "Lets fix the krb5.conf to see if that might fix the error you are getting."
        echo "Press Enter to run the configuration of /etc/krb5.conf."
        read
        sudo tee /etc/krb5.conf > /dev/null <<EOT
        [libdefaults]
            default_realm = $DOMAIN_UPPER
            dns_lookup_realm = false
            dns_lookup_kdc = true

        [realms]
            $DOMAIN_UPPER = {
                kdc = $ADDC_IP
                admin_server = $ADDC_IP
            }

        [domain_realm]
            .$DOMAIN = $DOMAIN_UPPER
            $DOMAIN = $DOMAIN_UPPER
EOT
        echo "krb5.conf file have now been configured."
        echo "Lets run the test again to see if it worked."
        echo "Press Enter to run the test."
        read
        kinit $AD_ADMIN@$DOMAIN
        klist
        echo "If it looks right now press Enter to continue, otherwise CRTL+C to stop the script and manually configure"
        read
    ;;

    2)
        echo "You have chosen No to reciving any kinit errors, this is grate!"
        echo "Press Enter to contiue the script"
        read
    ;;
esac

#You are now done getting your linux machine in to the AD.
echo "Congratulations on making it to here..."
echo "You have done it, well done soldier."
echo "Your Linux client/server should now be part of your AD."
echo "Give your self a pat on the back."
echo "Press Enter to end the script."
read