#/bin/bash

export ORACLE_HOME=/oracle/product/11g
export ORACLE_SID=ALLOYDT1
export PATH=$ORACLE_HOME/bin:$PATH
logfile=/home/oracle/dba/scripts/log/asm_dg.log
sqlplus -s "/as sysdba" > /dev/null << EOF spool $logfile
SET LINESIZE 150
SET PAGESIZE 9999
SET VERIFY off
COLUMN group_name FORMAT a10 HEAD 'DISKGROUP_NAME'
COLUMN state FORMAT a11 HEAD 'STATE'
COLUMN type FORMAT a6 HEAD 'TYPE'
COLUMN total_mb FORMAT 999,999,999 HEAD 'TOTAL SIZE(GB)'
COLUMN free_mb FORMAT 999,999,999 HEAD 'FREE SIZE (GB)'
COLUMN used_mb FORMAT 999,999,999 HEAD 'USED SIZE (GB)'
COLUMN pct_used FORMAT 999.99 HEAD 'PERCENTAGE USED'

SELECT distinct name group_name , state state , type type ,
round(total_mb/1024) TOTAL_GB , round(free_mb/1024) free_gb ,
round((total_mb - free_mb) / 1024) used_gb ,
round((1- (free_mb / total_mb))*100, 2) pct_used from
v$asm_diskgroup where round((1- (free_mb / total_mb))*100, 2) > 70 ORDER BY name;

spool off
exit
EOF
count=`cat $logfile|wc -l`
#echo $count
if [ $count  -ge 4 ];
 then
  mailx -s "ASM DISKGROUP REACHED 90% UTILIZATION" echinherende@liaison.com < $logfile
fi

> /home/oracle/dba/scripts/log/asm_dg.log