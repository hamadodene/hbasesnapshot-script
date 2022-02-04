# DISCLAIMER
# Please note: This script is released for use "AS IS" without any warranties
# of any kind, including, but not limited to their installation, use, or
# performance. We disclaim any and all warranties, either express or implied,
# including but not limited to any warranty of noninfringement,
# merchantability, and/ or fitness for a particular purpose. We do not warrant
# that the technology will meet your requirements, that the operation thereof
# will be uninterrupted or error-free, or that any errors will be corrected.
#
# Any use of these scripts and tools is at your own risk. There is no guarantee
# that they have been through thorough testing in a comparable environment and
# we are not responsible for any damage or data loss incurred with their use.
#
# You are responsible for reviewing and testing any scripts you run thoroughly
# before use in any non-testing environment.

#Usage:
#For single table Snapshot
# bash take_snapshot.sh table
#For all tableSnapshot
#bash take_snapshot.sh *

#For multi table snapshot
#bash take_snapshot.sh multi /file/tables/list/tables.txt
#table.txt contain list of tables. One table name per row

export TS=`date "+%s"`
export WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export LOGS=$WORKING_DIR/logs
export currentDate=$(date '+%Y-%m-%d-%H-%M-%S')
export UTILS=$WORKING_DIR/utils

mkdir -p $LOGS

function  make_table_snapshot() {
	tableName=$1
	
	echo "$date Create snapshot for table $tableName: $tableName-$date" >> $LOGS/makesnapshot.log
	
	#make snapshot for table
	echo "snapshot '$tableName', '$tableName-$TS'" | hbase shell -n 2>> $LOGS/makesnapshot.log
	
	status=$?
	
	if [ $status -ne 0 ];
	then
		echo "$date Snapshot for table $tableName may have failed: $status" >> $LOGS/makesnapshot.log
		#if the snapshot of a table fails, quit the program
		exit $status
	fi
}

function  make_all_table_snapshot() {
	tables=$1
	echo "$date Start making snapshot for all tables" >> $LOGS/makesnapshot.log
	while IFS= read -r line
	do
		make_table_snapshot $line
	done < tables
	echo "$date Finished making snapshot for all tables" >> $LOGS/makesnapshot.log
}

function list_hbase_tables_in_file() {
	#create utils folder
	mkdir -p $UTILS
	
	#get hbase tables
	echo 'list' | hbase shell -n>>$UTILS/tables.txt
	status=$?
	if [$status -ne 0]; then
	  echo "$date ommand = list may have failed."
	fi
	
	#remove TABLE from the first line of file
	sed -i '1d' $UTILS/tables.txt
	
	tableList='$UTILS/tables.txt'
	echo "$date Stored table list on $tableList" >> $LOGS/makesnapshot.log
}
 
if [ -z $1 ] || [ $1 == '-h' ]
then
	echo "Usage: $WORKING_DIR/$0 <table>"
	echo "Usage: $WORKING_DIR/$0 <*>"
	exit 1;
fi


if [[ $1 == '*' ]]
then
	#get tables list
	list_hbase_tables_in_file
	
	#Start making snapshots process
	make_all_table_snapshot $tableList
elif [[ $1 == 'multi']]
then
	#Multi table snapshot
	#Expected file of table list
	tableListPath=$2
	make_all_table_snapshot $tableListPath
else 
	#Make a single table snapshot
	make_table_snapshot $1
fi


