#!/bin/bash

echo "SMS Stream 2.0"

DBNAME=zuka
DBUSER=zuka

./clean.sh

createuser -e -U postgres -D -R -S $DBUSER
createdb -e -U postgres -O $DBUSER -E UTF8 $DBNAME
createlang -e -U postgres plpgsql $DBNAME

psql -U $DBUSER -f ./sms-stream.sql $DBNAME
