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

export TS=$(date "+%s")
export WORKING_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LOGS=$WORKING_DIR/logs
export currentDate=$(date '+%Y-%m-%d-%H-%M-%S')
export UTILS=$WORKING_DIR/utils
mkdir -p $LOGS

function exportAllSnapshotsFromAnotherCluster() {
    snapshotList=$1
    source=$2
    destination=$3
    bandwidth=$4

    echo "$currentDate Start exporting all snapshots from $source to $destination" >>$LOGS/exportSnapshot.log
    while IFS= read -r line; do
        echo "Exporting snapshot $line"
        exportSnapshotCommand $line $source $destination $bandwidth
    done <$snapshotList
    echo "$currentDate Finished  exporting all snapshots from  $source to $destination" >>$LOGS/exportSnapshot.log
    exit 0
}

function exportSingleSnapshot() {
    snapshotName=$1
    source=$2
    destination=$3
    bandwidth=$4

    echo "$currentDate Start exporting snapshot $snapshotName from $source to $destination" >>$LOGS/exportSnapshot.log

    exportSnapshotCommand $snapshotName $source $destination $bandwidth

    echo "$currentDate Finished  exporting snapshot $snapshotName from  $source to $destination" >>$LOGS/exportSnapshot.log

}

function exportSnapshotCommand() {
    snapshotName=$1
    source=$2
    destination=$3
    bandwidth=$4

echo "$currentDate Start exporting snapshot $snapshotName from $source to $destination" >>$LOGS/exportSnapshot.log
    #check if bandwidth is Null
    if [ -z "$bandwidth" ]; then
        if [ -z "$source" ]; then
            hbase org.apache.hadoop.hbase.snapshot.ExportSnapshot -snapshot $snapshotName -copy-to $destination -mappers 16 -overwrite>>$LOGS/exportSnapshot.log
        else
            hbase org.apache.hadoop.hbase.snapshot.ExportSnapshot -snapshot $snapshotName -copy-from $source -copy-to $destination -mappers 16 -overwrite>>$LOGS/exportSnapshot.log
        fi
    else
        if [ -z "$source" ]; then
            hbase org.apache.hadoop.hbase.snapshot.ExportSnapshot -snapshot $snapshotName -copy-to $destination -mappers 16 -bandwidth $bandwidth -overwrite>>$LOGS/exportSnapshot.log
        else
            hbase org.apache.hadoop.hbase.snapshot.ExportSnapshot -snapshot $snapshotName -copy-from $source -copy-to $destination -mappers 16 -bandwidth $bandwidth -overwrite>>$LOGS/exportSnapshot.log
        fi
    fi
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error during export $snapshotName"
        exit $status
    fi
    echo "$currentDate Finished  exporting snapshot $snapshotName from  $source to $destination" >>$LOGS/exportSnapshot.log

}

restoreAllSnapshot() {
    hbase shell -n $1 >>>$LOGS/restore_commands.log
}

restoreSnapshot() {
    snapshotName=$1
    tableName=$2
    "disable '$tableName'" | hbase shell -n 2>>$LOGS/restore_commands.log
    "restore '$snapshotName'" | hbase shell -n 2>>$LOGS/restore_commands.log
    "enable '$tableName'" | hbase shell -n 2>>$LOGS/restore_commands.log
}

function generate_all_tablerestore_command() {
    mkdir -p $UTILS

    if [ -f $UTILS/restore_commands.txt ]; then
        echo "$currentDate  $UTILS/restore_commands.txt already exist, remove it"
        rm -f $UTILS/restore_commands.txt
        echo "$currentDate  $UTILS/restore_commands.txt is removed"
    fi

    while IFS= read -r snapshotName; do
        tableNameFromSnapshotName $snapshotName
        echo "disable '$tableName'" >>$UTILS/restore_commands.txt
        echo "restore_snapshot '$snapshotName'" >>$UTILS/restore_commands.txt
        echo "enable '$tableName'" >>$UTILS/restore_commands.txt
    done <$1

    echo "exit" >>$UTILS/restore_commands.txt
    restoreCommands=$UTILS/restore_commands.txt
}

tableNameFromSnapshotName() {
    IFS='-'
    name=$1
    read -a strarr <<<"$name"
    tableName="${strarr[0]}"
}

case $1 in
'restoreAll')
    #generate restore command for all table
    generate_all_tablerestore_command $2
    restoreAllSnapshot $restoreCommands
    ;;
'restore')
    restoreSnapshot $2 $3
    ;;
'export')
    exportAllSnapshotsFromAnotherCluster $2 $3 $4 $5
    ;;
*)
    exit 0
    ;;
esac
