#!/bin/bash
set -e  # Exit if any command fails
source ../../.env  # Load environment variables

echo "----- Loading CSVs into PostgreSQL Database: $PGDATABASE -----"

# Ensure database exists
psql -U $PGUSER -tc "SELECT 1 FROM pg_database WHERE datname='$PGDATABASE'" | grep -q 1 || psql -U $PGUSER -c "CREATE DATABASE $PGDATABASE"
echo "Database '$PGDATABASE' ready."

# Loop through all CSV files
for file in $DEC_CSV_DIR/*.csv; do
  [ -e "$file" ] || { echo "No CSV files found in $DEC_CSV_DIR"; exit 0; }

  filename=$(basename -- "$file")
  table="${filename%.csv}"

  echo "Processing file: $filename (Table: $table)"

  # Drop table if exists (optional)
  psql -U $PGUSER -d $PGDATABASE -c "DROP TABLE IF EXISTS $table CASCADE;"

  # Create table automatically (all columns as text)
  header=$(head -1 "$file" | tr -d '\r')
  IFS=',' read -ra cols <<< "$header"
  schema=$(printf "%s text," "${cols[@]}")
  schema=${schema%,}

  psql -U $PGUSER -d $PGDATABASE -c "CREATE TABLE $table ($schema);"

  # Copy data into PostgreSQL
  psql -U $PGUSER -d $PGDATABASE -c "\COPY $table FROM '$file' CSV HEADER;"

  echo "Loaded $filename into $table"
done

echo "All CSV files successfully loaded into '$PGDATABASE'"
