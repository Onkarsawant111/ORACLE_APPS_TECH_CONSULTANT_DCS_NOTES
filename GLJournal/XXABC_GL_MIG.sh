#!/bin/bash
# ___________________________________________________________________________________ 
# |                                                                                  |
# | File Name    : XXABC_GL_MIG.sh                                     |
# |                                                                                  |
# |  Author           Date          Version  Remarks                                 |
# | -----------      ---------     -------  --------------------------               |
# | user   DD-MON-YYYY      1.0     Created                 			     |
# |_________________________________________________________________________________ |
#  Following RICE objects are considered for UAT Migration (Total 67)                |     
#------------------------------------------------------------------------------------|
#	SNO	RICEW ID           RICEW Name                                                |
#------------------------------------------------------------------------------------|


# ###########################################################
#  Local Varaiables
# ###########################################################
mig_log="XXABC_GL_MIG.sh_`date "+%d_%h_%Y_%H_%M_%S"`.log"

echo "*******************************" >> $mig_log
echo "Begin of Migration Script" >> $mig_log
echo "*******************************" >> $mig_log

# ###########################################################
#  Function to validate DB login credentials.
# ###########################################################

CHKLOGIN(){
if sqlplus -s /nolog <<!>>/dev/null 2>&1
WHENEVER SQLERROR EXIT 1;
CONNECT $1 ;

EXIT
!
then
 echo OK  
else
 echo NOK 
fi
} 

# ###########################################################
#  Get DB login credentials and validate
# ###########################################################

echo "===============================" >> $mig_log
echo "Getting and validating DB login credentials" >> $mig_log
echo "===============================" >> $mig_log
APPSPWD=""
TNS_STRING=`cat $CONTEXT_FILE|grep s_apps_jdbc_connect_descriptor|cut -d"@" -f2 | sed 's/<\/jdbc_url>//'` 

while [ "$APPSPWD" = "" -o `CHKLOGIN "apps/$APPSPWD" "DUAL"` = "NOK" ]
do
    if [ "$APPSPWD" = "" ];then
            echo "Enter Password : "
            read APPSPWD
    else
        echo "Entered password is not correct. "
        APPSPWD=""
    fi
done

echo "DB login credentials validated." >> $mig_log

#Control File
echo "Copying XXABCLoadGLData.ctl to $FND_TOP/bin">> $mig_log
cp XXABCLoadGLData.ctl $FND_TOP/bin >> $mig_log

#Table and Package Script
echo "Invoking XXABC_GL_INTF_STG_DDL.sql ">> $mig_log
sqlplus apps/$APPSPWD @XXABC_GL_INTF_STG_DDL.sql >> $mig_log
echo "Invoking XXABC_GL_INTERFACE_UTLS.pks ">> $mig_log
sqlplus apps/$APPSPWD @XXABC_GL_INTERFACE_UTLS.pks >> $mig_log
echo "Invoking XXABC_GL_INTERFACE_UTLS.pkb ">> $mig_log
sqlplus apps/$APPSPWD @XXABC_GL_INTERFACE_UTLS.pkb >> $mig_log

#Concurrent Program
echo "Loading LDT XXABC_GL_INTERFACE_IMPORT." >> $mig_log
FNDLOAD apps/$APPSPWD 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct XXABC_GL_INTERFACE_IMPORT.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE  >> $mig_log
echo "Loading XXABCLOADGLDATA.ldt" >> $mig_log
FNDLOAD apps/$APPSPWD 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct XXABCLOADGLDATA.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE  >> $mig_log
