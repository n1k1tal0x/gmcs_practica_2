#!/usr/bin/env bash
set -euo pipefail

dump_file="/docker-entrypoint-initdb.d/test_marathon_db_2026_06_09.dump"

if [[ ! -f "$dump_file" ]]; then
  echo "Dump file not found: $dump_file" >&2
  exit 1
fi

echo "Restoring database from $dump_file"
pg_restore \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" \
  --clean \
  --if-exists \
  --no-owner \
  --no-privileges \
  --exit-on-error \
  "$dump_file"
