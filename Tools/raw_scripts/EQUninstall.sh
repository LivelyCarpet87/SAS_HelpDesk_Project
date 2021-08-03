#!/bin/bash
#
# Equitrac uninstall script
#
# requires root privileges to run successfully
#
# to run:
# 1. login with Admin account;
# 2. open Terminal application;
# 3. type sudo ;
# 4. drug and drop EQUninstall.sh from Finder into Terminal window;
# 5. press Enter;
# 6. type Admin account password.

declare -i iErr=0

########## stop EQLoginController #############

strLoginControllerPID=$(ps -awwxjc | grep -i [E]QLoginController | awk '{print $2}')

if [ "$strLoginControllerPID" != "" ] ; then

	echo "Stopping LoginController..."

	kill -TERM $strLoginControllerPID

	declare -i iWaitCount=0 

	while [ "$strLoginControllerPID" != "" -a $iWaitCount -lt 5 ] ; do
		echo "Waiting 1 sec for LoginController to stop..."
		sleep 1
		iWaitCount=$iWaitCount+1
		strLoginControllerPID=$(ps -awwxjc | grep -i [E]QLoginController | awk '{print $2}')
	done

	if [ "$strLoginControllerPID" == "" ] ; then
		echo "LoginController stopped."
	else
		echo "LoginController did not stop - wait time expired."
	fi

else
	echo "LoginController is not running."
fi


########### LoginController launchd job ###########

# unload logincontroller.plist
for user in `/usr/bin/users` 
do 
    echo "Unloading com.equitrac.logincontroller.plist agent for user $user..." 
    su -l $user -c "launchctl unload -SAqua /Library/LaunchAgents/com.equitrac.logincontroller.plist" 
    iErr=$? 
    if [ $iErr != 0 ] ; then 
        echo "failed (non-fatal, status $iErr)." 
    else 
        echo "Unloaded com.equitrac.logincontroller.plist agent for $user" 
    fi 
done 

rm -f /Library/LaunchAgents/com.equitrac.logincontroller.plist
iErr=$?

if [ $iErr = 0 ] ; then
	echo "com.equitrac.logincontroller.plist deleted."
else
	echo "Can't delete com.equitrac.logincontroller.plist. err = $iErr"
fi


########### backends ###########
declare -i iRestartCUPSD=0

########### eqtrans ###########

strEQTransPath="/usr/libexec/cups/backend/eqtrans"

if [ -e "$strEQTransPath" ] ; then
	
	iRestartCUPSD=1
	
	echo "Deleting eqtrans..."

	rm -f "$strEQTransPath"
	iErr=$?

	if [ $iErr = 0 ] ; then
		echo "eqtrans deleted."
	else
		echo "Can't delete eqtrans. err = $iErr"
	fi

else
	echo "eqtrans does not exist."
fi

########### eqpmon ###########

strEQPMonPath="/usr/libexec/cups/backend/eqpmon"

if [ -e "$strEQPMonPath" ] ; then
	
	iRestartCUPSD=1
	
	echo "Deleting eqpmon..."

	rm -f "$strEQPMonPath"
	iErr=$?

	if [ $iErr = 0 ] ; then
		echo "eqpmon deleted."
	else
		echo "Can't delete eqpmon. err = $iErr"
	fi

else
	echo "eqpmon does not exist."
fi

########### cupsd ###########

if [ $iRestartCUPSD != 0 ] ; then

	# need to restart cupsd to unregister eqtrans and eqpmon

	strCupsdPID=$(ps -awwxjc | grep cupsd | awk '{print $2}')

	if [ "$strCupsdPID" != "" ] ; then
	
		echo "Restarting CUPS daemon..."
		
		kill -HUP $strCupsdPID
		iErr=$?

		if [ $iErr = 0 ] ; then
			echo "CUPS daemon restarted."
		else
			echo "Can't restart CUPS daemon. err = $iErr"
		fi
	
	else
		echo "CUPS daemon is not running."
	fi

else
	echo "Don't need to restart CUPS daemon."
fi


########### MachO LoginController ###########

strMachOLoginCtrlPath="/Library/Application Support/Equitrac/EQLoginController.app"

if [ -d "$strMachOLoginCtrlPath" ] ; then

	echo "Deleting MachO LoginController..."

	rm -fdr "$strMachOLoginCtrlPath"
	iErr=$?

	if [ $iErr = 0 ] ; then
		echo "MachO LoginController deleted."
	else
		echo "Can't delete MachO LoginController. err = $iErr"
	fi

else
	echo "MachO LoginController does not exist."
fi

########### CFM LoginController ###########

strCFMLoginCtrlPath="/Library/Application Support/Equitrac/EQLoginController"

if [ -e "$strCFMLoginCtrlPath" ] ; then

	echo "Deleting CFM LoginController..."

	rm -f "$strCFMLoginCtrlPath"
	iErr=$?

	if [ $iErr = 0 ] ; then
		echo "CFM LoginController deleted."
	else
		echo "Can't delete CFM LoginController. err = $iErr"
	fi

else
	echo "CFM LoginController does not exist."
fi

########### SharedEngine ###########

### unload SharedEngine plist

echo "Unloading EQSharedEngine plist..."

launchctl unload /Library/LaunchDaemons/com.equitrac.sharedengine.plist
iErr=$?
if [ $iErr = 0 ] ; then
    echo "EQSharedEngine plist unloaded."
else
    echo "Can't unload EQSharedEngine plist. err = $iErr"
fi


rm -f /Library/LaunchDaemons/com.equitrac.sharedengine.plist
iErr=$?
if [ $iErr = 0 ] ; then
	echo "com.equitrac.sharedengine.plist deleted."
else
	echo "Can't delete com.equitrac.sharedengine.plist. err = $iErr"
fi


### stop SharedEngine process

strSharedEnginePID=$(ps -awwxjc | grep eqshengd | awk '{print $2}')

if [ "$strSharedEnginePID" != "" ] ; then

	echo "Stopping SharedEngine..."

	kill -TERM $strSharedEnginePID

	declare -i iWaitCount=0 

	while [ "$strSharedEnginePID" != "" -a $iWaitCount -lt 5 ] ; do
		echo "Waiting 1 sec for SharedEngine to stop..."
		sleep 1
		iWaitCount=$iWaitCount+1
		strSharedEnginePID=$(ps -awwxjc | grep eqshengd | awk '{print $2}')
	done

	if [ "$strSharedEnginePID" == "" ] ; then
		echo "SharedEngine stopped."
	else
		echo "SharedEngine did not stop - wait time expired."
	fi

else
	echo "SharedEngine is not running."
fi


### delete SharedEngine module
# del from old location just in case
strSharedEnginePath_StartupItems="/Library/StartupItems/EQSharedEngine"

if [ -d "$strSharedEnginePath_StartupItems" ] ; then

	echo "Deleting SharedEngine from StartupItems..."

	rm -fdr "$strSharedEnginePath_StartupItems"
	iErr=$?

	if [ $iErr = 0 ] ; then
		echo "SharedEngine deleted from StartupItems."
	else
		echo "Can't delete SharedEngine from StartupItems. err = $iErr"
	fi

fi

# del from Equitrac folder
strSharedEnginePath="/Library/Application Support/Equitrac/SharedEngine"

if [ -d "$strSharedEnginePath" ] ; then

	echo "Deleting SharedEngine..."

	rm -fdr "$strSharedEnginePath"
	iErr=$?

	if [ $iErr = 0 ] ; then
		echo "SharedEngine deleted."
	else
		echo "Can't delete SharedEngine. err = $iErr"
	fi

else
	echo "SharedEngine does not exist."
fi

########### DRC ###########

### unload DRC plist

echo "Unloading DRC plist..."

launchctl unload /Library/LaunchDaemons/com.equitrac.drc.plist
iErr=$?
if [ $iErr = 0 ] ; then
    echo "DRC plist unloaded."
else
    echo "Can't unload DRC plist. err = $iErr"
fi


rm -f /Library/LaunchDaemons/com.equitrac.drc.plist
iErr=$?
if [ $iErr = 0 ] ; then
	echo "com.equitrac.drc.plist deleted."
else
	echo "Can't delete com.equitrac.drc.plist. err = $iErr"
fi

### stop DRC process

strDRCPID=$(ps -awwxjc | grep eqdrcd | awk '{print $2}')

if [ "$strDRCPID" != "" ] ; then

	echo "Stopping DRC..."

	kill -TERM $strDRCPID

	declare -i iWaitCount=0 

	while [ "$strDRCPID" != "" -a $iWaitCount -lt 20 ] ; do
		echo "Waiting 1 sec for DRC to stop..."
		sleep 1
		iWaitCount=$iWaitCount+1
		strDRCPID=$(ps -awwxjc | grep eqdrcd | awk '{print $2}')
	done

	if [ "$strDRCPID" == "" ] ; then
		echo "DRC stopped."
	else
		echo "DRC did not stop - wait time expired."
	fi

else
	echo "DRC is not running."
fi


### delete DRC module

# del from old location just in case
strDRCPath_StartupItems="/Library/StartupItems/EQDRC"

if [ -d "$strDRCPath_StartupItems" ] ; then

	echo "Deleting DRC from StartupItems..."

	rm -fdr "$strDRCPath_StartupItems"
	iErr=$?

	if [ $iErr = 0 ] ; then
		echo "DRC deleted from StartupItems."
	else
		echo "Can't delete DRC from StartupItems. err = $iErr"
	fi

fi

# del from Equitrac folder
strDRCPath="/Library/Application Support/Equitrac/DRE/eqdrcd"

if [ -e "$strDRCPath" ] ; then

	echo "Deleting DRC..."

	rm -f "$strDRCPath"
	iErr=$?

	if [ $iErr = 0 ] ; then
		echo "DRC deleted."
	else
		echo "Can't delete DRC. err = $iErr"
	fi

else
	echo "DRC does not exist."
fi

# del keychain files
# keychain
strKeyChainPath="/Library/Application Support/Equitrac/eqauto.keychain"

if [ -e "$strKeyChainPath" ] ; then
    rm -f "$strKeyChainPath"
    iErr=$?

    if [ $iErr != 0 ] ; then
        echo "Can't delete keychain file. err = $iErr"
    fi
fi

# pwd
strKeyChainPwdPath="/Library/Application Support/Equitrac/eqauto.keychain.password"

if [ -e "$strKeyChainPwdPath" ] ; then
    rm -f "$strKeyChainPwdPath"
    iErr=$?

    if [ $iErr != 0 ] ; then
        echo "Can't delete keychain pwd file. err = $iErr"
    fi
fi

exit 0
