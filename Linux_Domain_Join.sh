#!bin/bash

#Script to Domain join a linux client/server to an active directory (AD) on a windows server.

#Sets variables for the script to use.
ADDC_IP=""
Test_Connection=""
New_Hostname=""

echo "Domain Join script for Linux have been booted."
echo "Press Enter to continue, or CTRL+C to stop the script."
read

IP_Address=$(hostname -I | awk '{print $1}')
Old_Hostname=$(hostname)

#To begin with we want to specify the host name for the machine to make sure you have the one you wishes to have in AD.
clear
echo "Current hostname is: $Old_Hostname"
echo "Do you wish to change this to a new name?"
echo "1 - YES"
echo "2 - NO"
read New_Hostname
case "$New_Hostname" in
    1)
        echo "You have chosen: YES."
        echo "What do you wish your new hostname to be?"
        read new_hostname
        hostnamectl set-hostname $new_hostname
        echo $IP_Address $new_hostname >> /etc/hosts
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

#Specify the IP for the AD domain controller and test connection.
clear
echo "Time to specify the domain controller."
echo "IPv4 format goes like 192.168.xxx.xxx."
echo "What is the IPv4 address for the Active Directory Domain Controller:"
read ADDC_IP
echo $ADDC_IP sbad.sbits.net sbad >> /etc/hosts
echo "Domain Controller IP have been recorded, wish to test connection to it?"
echo "1 - YES"
echo "2 - NO"
read Test_Connection
case "$Test_Connection" in
    1)
        echo "You have chosen: YES"
        echo "Testing connection to the domain controller"
        ping -c 5 sbad.sbits.net
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

