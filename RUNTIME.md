# HU-005 runtime schema correction

V1 and V3 retain their original contents/checksums and move to the Flyway locations
already declared in flyway.toml. V4 only adds school_id and lamport_timestamp and
extends the attendance status check to the domain's JUSTIFIED value. Legacy outbox
rows start with Lamport zero; this does not reconstruct historical causal order.

Fresh local databases: set DB_USER and DB_PASSWORD, then docker compose -p educk-attendance-local up -d --wait.
Existing databases: apply V4 using Flyway against the owning database; init scripts
do not run again on existing volumes. No reset, deletion or cross-database FK is required.
Use a distinct Compose project and volume for each environment. No DB port is exposed.
The paired API PR proves PostgreSQL startup, pending outbox persistence and rollback.
Do not promote either correction until both PRs have passed review.
