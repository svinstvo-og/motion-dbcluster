#!/bin/bash
set -e

if [ -s "$PGDATA/PG_VERSION" ]; then
    echo "Data already exists, skipping base backup"
else
    echo "Starting base backup from leader..."
    until pg_basebackup -h db-leader -D "$PGDATA" -U replicator -vP --wal-method=stream; do
        echo "Waiting for db-leader to be ready..."
        sleep 2
    done

    echo "primary_conninfo = 'host=db-leader port=5432 user=replicator password=replicator'" >> "$PGDATA/postgresql.auto.conf"
    touch "$PGDATA/standby.signal"
    chown -R postgres:postgres "$PGDATA"
fi
