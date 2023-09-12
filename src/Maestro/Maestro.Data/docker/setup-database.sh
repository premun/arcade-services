#!/bin/bash
echo 'starting database setup'
/opt/mssql/bin/sqlservr &

sleep 10s

echo 'Initializing database after 10 seconds of wait'
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ProdCon123 -i BuildAssetRegistry.sql

echo 'Finished initializing the database'
