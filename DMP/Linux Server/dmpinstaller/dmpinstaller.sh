#!/bin/bash

# LICENSE: SEE http://forum.kerbalspaceprogram.com/threads/92665-DMP-Linux-Server-Tools


# ---------------------------------------------------------------------------------------------------------
# PACKAGE
# ---------------------------------------------------------------------------------------------------------


# Common Variables
INSTALLDIR="/usr/share/dmpserver"
CONFIGDIR="/etc/dmpserver"
DATADIR="/srv/dmpserver"
LIBDIR="/var/lib/dmpserver"

# System Users
SysUser[0]="dmpserver"

# Dirs
NewDir[0]="$CONFIGDIR;774"
NewDir[1]="$INSTALLDIR;774"
NewDir[2]="$CONFIGDIR/config;774"
NewDir[3]="$DATADIR;774"
NewDir[8]="$LIBDIR;774"

# Pastebin Targets
#         Target;Key;Directory;chmodkey(Must Exist)
Target[0]="dmpbashup;Gx5wFtbx;/usr/bin;774"
Target[1]="dmpserver;X4E46Af5;/usr/bin;774"
Target[2]="dmpserver.cfg;UHaknDCZ;$CONFIGDIR;774"
Target[3]="dmpcmd;ZTTUF4dH;/usr/bin;774"
Target[4]="dmpbashlib;UQnVBYx5;$LIBDIR;774"
Target[5]="dmpenv;FkWEUsfX;/usr/bin;774"

# Dependencies
Depends[0]="mono"
Depends[1]="screen"
Depends[2]="curl"


# Disclaimer
Disclaimer="
This program will download and install DarkMultiplayer, an internet game server for Kerbal Space Program.
The computer or server from which you are running this script will allow other computers to connect to it
from across the internet, and send data to client programs. The client programs will interact with the
data, manipulate it, and send the data back to the server. The server will then receive, manipulate, and
broadcast the data to other clients connected to the server. If you do not understand or agree to the
function described by this message, you should answer no to the next question and refrain from running
this program again.


Additionally, this program will download and install management and update tools from www.pastebin.com .
These tools are listed in the 'pbpkg' file next to pbinstall. These tools will install and
periodically update DMPServer, allow for easy starting, stopping, and restarting of the DMPServer service,
and allow for the deletion of the DMPServer 'Universe'. DMPServer will be downloaded and installed from
www.godarklight.com , the official repository of DarkMultiplayer. If you do not understand or agree to the
function described by this message, you should answer no to the next question and refrain from running
this program again."

# Post-Installation Script
function postInstall(){
    dmpbashup
    dmpenv install default
    dmpserver

    echo "DarkMultiPlayer server has been installed. Make sure the correct ports are open"
    echo "and restart the server. Make sure you run as root when using the tools,"
    echo "i.e. 'sudo dmpserver status'."
    echo "To add another server, use dmpenv, i.e. 'sudo dmpenv install server2', and"
    echo "control it with dmpserver [server name], i.e. 'sudo dmpserver server2 start'."
}




# ---------------------------------------------------------------------------------------------------------
# INSTALLER
# ---------------------------------------------------------------------------------------------------------


# Variables
PASTEBIN_API="http://pastebin.com/raw.php?i="
ifsNewline=$'\n'
ifsReset=$IFS


# Functions
function linDistCheck(){
    if hash rpm 2> /dev/null ; then
        D_CHECK="rhel"
    elif hash dpkg 2> /dev/null ; then
        D_CHECK="debian"
    else
        echo "You are (probably) not running a Debian or RHEL based system!"
        echo "Your linux version is (probably) not supported."
        exit 1
    fi
        
}
function printDisclaimer(){
    IFS=$ifsNewline
    for line in $Disclaimer ; do
        echo $line
    done
    IFS=$ifsReset
}

function dependencyCheck(){
    for dependency in ${Depends[@]} ; do
        if hash $dependency 2> /dev/null ; then
            :
        else
            echo "This program requires '$dependency' to be available."
            echo "Please install it (try 'apt-get install $dependency' on Debian, or 'yum install $dependency' on RHEL) before continuing."
            exit 1
        fi
    done
}

function addSysUserList(){
    for user in ${SysUser[@]} ; do
        echo "Adding system user '$user'..."
        if id -u $user >/dev/null 2> /dev/null;
        then
            echo "User '$user' already exists! Skipping creation."
        else
            case "$D_CHECK" in
                "rhel")
                    useradd -r $user
                    usermod -s /bin/false $user
                    ;;

                "debian")
                    adduser -system $user
                    ;;

               *) echo "Distro Not Supported."  ;;
            esac
			echo "Added system user '$user'."
		fi
	done
}

function installDirList(){
    for src in ${NewDir[@]} ; do
        tdir=$(echo -n "$src" | awk -F ";" '{print $1}')
        tcode=$(echo -n "$src" | awk -F ";" '{print $2}')
        echo "Adding directory '$tdir'..."
        if [ ! -d $tdir ];
        then
            mkdir $tdir
            chmod $tcode $tdir
            echo "Added directory '$tdir' with chmod code '$tcode'."
        else
            echo -e "Directory '$tdir' already exists! Skipping creation."
        fi
    done
}

# AmselMax
# 'curl' changed to 'curl -L' or 'wget -q -O-' 
function getPBinScript(){
    echo "Installing '$2'. File will be downloaded from ${PASTEBIN_API}$1"
     wget -q -O- ${PASTEBIN_API}$1 | tr -d '\r' > $2
    echo "Installed '$2'."
    echo
}

function installPBinList(){
    t=0
    for src in ${Target[@]} ; do
        tname=$(echo -n "$src" | awk -F ";" '{print $1}')
        tkey=$(echo -n "$src" | awk -F ";" '{print $2}')
        tdir=$(echo -n "$src" | awk -F ";" '{print $3}')
        tcode=$(echo -n "$src" | awk -F ";" '{print $4}')

        if [ ! -d $tdir ];
        then
            echo -e "FATAL: Directory '$tdir' does not exist! Skipping file '$tdir'."
        else
            getPBinScript $tkey $tdir/$tname
            chmod $tcode $tdir/$tname
        fi
        ((t++))
    done
}




# ---------------------------------------------------------------------------------------------------------
# EXECUTION
# ---------------------------------------------------------------------------------------------------------


if [ $(whoami) != 'root' ]; then
        echo "This program must be run with root permissions."
        exit 1
fi

case "$1" in
    update)
        installPBinList
        exit
        ;;

    no-disclaim)
        linDistCheck
        dependencyCheck
        addSysUserList
        installDirList
        installPBinList
        postInstall
        exit
        ;;

    *)
        printDisclaimer    
        echo -n "Do you understand and agree to the terms above? [y/n]: "
        read answer
        case $answer in
            [Yy]*)
                linDistCheck
                dependencyCheck
                addSysUserList
                installDirList
                installPBinList
                postInstall
                exit
                ;;

            [Nn]*) exit;;

            *) echo "Answer must be y or n.";;
        esac
        ;;
esac
