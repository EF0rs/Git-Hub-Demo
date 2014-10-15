#!/bin/bash
. $HOME/.bash_profile 
#====================================================================================================
#  Shippensburg University of PA
#  ScriptName:  MyScript
#  Description: 
#  Author:      AHR
#  TrackIt WO#  N/A
#  Date:        2011
#  I MADE SOME CHANGES
#----------------------------------------------------------------------------------------------------
#  Parameters
#  Name             		Description
#  ----             		---------------------------------------------------------------------------------
# 	1. term   					Term Code of Billing/Registration
#		2. script_mode			Mode of 'R'eport or 'U'pdate
#		3. connection_type	DB Connection (TEST, TRNG, PPRD, PROD)
#		4. dated_output			'Y'es or 'N'o for whether to add date to file name
#		5. email						Email Addresses that the locaiton will be emailed to
#
#----------------------------------------------------------------------------------------------------
#  Modifications
#  Date        Name             Description
#  ----------  ---------------- ---------------------------------------------------------------------
#   20130716
#		20130920
#		20140723	AHR	& WPR					Adding additional columns as requested by Dawn in WO 45173, issues with missing indexes
#   20140911 	EF								WO 46131 - Added Quotations around STREET1 in SQL file so CSV would keep addresses with Apt# in the same column
#		20140911	EF								WO 46131 - Fixed email link for Financial Aid
#

### UPDATE ME
script_name=clear_bill
script_path=/home/scriptadmin/AR
numargs=5

#----------------------------------------------------------------------------------------------------
# -- Checks the number of parameters
#----------------------------------------------------------------------------------------------------
if [ "$#" -ne $numargs ]; then
    echo
    echo
    echo $numargs" argument(s) required, $# provided" 
    ### UPDATE ME
    echo $script_name".sh term script_mode(U/R) connection_type dated_output(Y/N) email"    
    echo "ex. <scriptname>.sh 201460 R TEST Y ahrosenberry@ship.edu,dmcuts@ship.edu,mlharbaugh@ship.edu,SLTarbox@ship.edu,rcanne@ship.edu"
    echo
    exit 1
fi

#----------------------------------------------------------------------------------------------------
# -- Parameters passed in by user
#----------------------------------------------------------------------------------------------------
### UPDATE ME
v_term=$1
script_mode=$2
v_connection=$3
dated_output=$4
email=$5
title_text="Clear Bills "$v_term

#----------------------------------------------------------------------------------------------------
# -- BASH Script body
#----------------------------------------------------------------------------------------------------
if [ $dated_output = Y ]; then
### Updated dated format so that it is in date asc and desc order if you order the files by name
		date=`/bin/date +%Y%m%d%H%M%S`
    OutFileName=$script_name$date".csv"
else
    OutFileName=$script_name".csv"
fi

### UPDATE ME
command="$script_path/$script_name.sql $v_term $script_mode $OutFileName"
sudo /home/scriptadmin/"$IMBREAKINGTHECODE~!~!!#v_connection"_baninst1_connect.sh "$command" 


#########################################################
### Move file to the S drive
###########
if [ "$v_connection" == "PROD" ]; then 
	### Production
	###host=files.ship.edu	###username=infosvc 
	from_dir=$script_path/outfiles
	network_mapping="\\\\shipFSOFS\\Temp\\"
	to_dir=\\CIS\\Reports\\AR
	smbclient \\\\shipFSOFS\\TEMP -A /home/scriptadmin/AUTH_S_INFOSVC -c "put ${from_dir}/${OutFileName} ${to_dir}\\${OutFileName}"
	
##	to_dir2=\\CIS\\Reports\\Financial Aid
	to_dir2="\"\\CIS\\Reports\\Financial Aid\\\""
	email_link=CIS\\Reports\\"Financial Aid"
##	smbclient \\\\shipFSOFS\\TEMP -A /home/scriptadmin/AUTH_S_INFOSVC -c "put ${from_dir}/${OutFileName} ${to_dir2}\\${OutFileName}"
	smbclient \\\\shipFSOFS\\TEMP -A /home/scriptadmin/AUTH_S_INFOSVC -c "cd ${to_dir2};prompt;put ${from_dir}/${OutFileName} ${OutFileName}"
	
	echo "<"$network_mapping$to_dir\\$OutFileName">" > $from_dir/success.txt
	echo "<"$network_mapping$email_link\\$OutFileName">" >> $from_dir/success.txt
	
else
### Developement
##host=files.ship.edu	##username=infodevsvc
	from_dir=$script_path/outfiles
	network_mapping="\\\\shipFSOFS\\Temp\\"
	###from_dir=$script_path/outfiles
	to_dir=CC\\Dev_Test
	sudo -u scriptadmin smbclient \\\\files.ship.edu\\TEMP -A /home/scriptadmin/AUTH_TEST -c "put ${from_dir}/${OutFileName} ${to_dir}\\${OutFileName}"
	
	echo "<"$network_mapping$to_dir\\$OutFileName">" > $from_dir/success.txt
fi


mutt -s "$title_text" $email< $from_dir/success.txt
