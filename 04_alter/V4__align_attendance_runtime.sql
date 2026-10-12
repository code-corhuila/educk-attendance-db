-- Forward-only compatibility with the HU-005 persistence adapter.
-- Existing event IDs and records are preserved; school IDs are logical references.
ALTER TABLE attendance_events ADD COLUMN school_id UUID;
ALTER TABLE attendance_events DROP CONSTRAINT attendance_events_status_check;
ALTER TABLE attendance_events ADD CONSTRAINT attendance_events_status_check
    CHECK (status IN ('PRESENT', 'ABSENT', 'LATE', 'JUSTIFIED'));

ALTER TABLE outbox_events ADD COLUMN lamport_timestamp BIGINT NOT NULL DEFAULT 0;
COMMENT ON COLUMN outbox_events.lamport_timestamp IS
    'Lamport clock persisted with the attendance transaction; legacy rows start at zero.';
