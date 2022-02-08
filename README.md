# hbasesnapshot-script

# Take single table snapshot
Usage: bash take_snapshot.sh <hbase_table_name>

# Table all table snapshot
There are two ways to snapshot all tables.

1. fast mode
    With the fast mode, a file with the command list is generated.
    The file is then passed to hbase shell.
    In this case, error handling is not possible in the event of a snapshot failure.

    Usage: bash take_snapshot.sh all fast

2. slow mode    
    In slow mode, the command is launched for each table with a separate shell.
    If a command fails, the script ends.
    This is a very slow process, as hbase shell has to be re-launched for each table.

    Usage: bash take_snapshot.sh all slow

# Take multi table snapshot
For snapshot of multiple tables. Simply prepare a file (for example table.txt) containing the table list you want to take the snapshot and pass the complete path of file to the script.

Usage: bash take_snapshot.sh multi  slow /file/tables/list/tables.txt
Usage: bash take_snapshot.sh multi  fast /file/tables/list/tables.txt