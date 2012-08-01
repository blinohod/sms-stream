#!/bin/bash

echo "Cleanup start"

DBNAME=zuka
DBUSER=zuka

dropdb -U postgres $DBNAME
dropuser -U postgres $DBUSER

echo "Cleanup stop"
