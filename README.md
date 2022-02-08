# hbasesnapshot-script

# Take single table snapshot
Usage: bash take_snapshot.sh <hbase_table_name>

# Table all table snapshot
There are two ways to snapshot all tables.

1. fast mode
    With the fast mode, a file with the command list is generated.
    The file is then passed to hbase shell.
    In this case, error handling is not possible in the event of a snapshot failure.

    Usage: bash take_snapshot.sh allfast

2. slow mode    
    In slow mode, the command is launched for each table with a separate shell.
    If a command fails, the script ends.
    This is a very slow process, as hbase shell has to be re-launched for each table.

    Usage: bash take_snapshot.sh allslow

# Take multi table snapshot
For snapshot of multiple tables. Simply prepare a file (for example table.txt) containing the table list you want to take the snapshot and pass the complete path of file to the script.

Usage: bash take_snapshot.sh multislow /file/tables/list/tables.txt
Usage: bash take_snapshot.sh multifast /file/tables/list/tables.txt

# Generate file with snapshots list
Usage: bash take_snapshot.sh generatesnapshotlist

# Generate file with tables list
Usage: bash take_snapshot.sh generatetablelist

# Restore all snapshots
Usage: bash restore_snapshot.sh restoreAll tableSnapshotsList.txt

# Export all snapshots from another cluste
Usage: bash restore_snapshot.sh export tableSnapshotsList $source $destination $bandwidth