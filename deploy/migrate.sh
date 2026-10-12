#!/bin/sh
set -eu
mkdir -p /tmp/domain-migrations
cp /domain/01_ddl/V1__init_attendance.sql /tmp/domain-migrations/
cp /domain/01_ddl/V3__outbox_events_schema.sql /tmp/domain-migrations/
cp /domain/04_alter/V4__align_attendance_runtime.sql /tmp/domain-migrations/
cp /domain/04_alter/V5__annex_j_permissions.sql /tmp/domain-migrations/
exec flyway -locations=filesystem:/tmp/domain-migrations -schemas=attendance -defaultSchema=attendance -cleanDisabled=true migrate
