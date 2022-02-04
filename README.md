# hbasesnapshot-script

# Take single table snapshot
Usage: bash take_snapshot.sh <hbase_table_name>

# Table all table snapshot

Usage: bash take_snapshot.sh *

# Take multi table snapshot
For snapshot of multiple tables. Simply prepare a file (for example table.txt) containing the table list you want to take the snapshot and pass the complete path of file to the script.

Usage: bash take_snapshot.sh multi /file/tables/list/tables.txt