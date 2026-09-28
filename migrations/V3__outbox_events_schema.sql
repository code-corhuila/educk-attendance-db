-- V3__outbox_events_schema.sql
-- Transactional Outbox table for educk-attendance-db (ADR-007: Resilient AMQP
-- Messaging, Transactional Outbox & DLQ Strategy). Decouples the RabbitMQ
-- broker from the domain transaction: business rows and their outbound
-- events are written atomically in the same DB transaction (ADR-003:
-- Database per Service), and a separate publisher process drains this table.

-- pgcrypto provides gen_random_uuid(), already enabled in V1 for this schema.
-- Kept here as well so this migration is self-contained and safely re-runnable
-- on a fresh database if migrations are ever replayed out of order.
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS outbox_events (
    -- Surrogate key; also doubles as the idempotency key (eventId) that
    -- downstream consumers use for de-duplication, per ADR-007 section 3.
    id              UUID NOT NULL DEFAULT gen_random_uuid(),

    -- Domain aggregate that produced the event, e.g. 'AttendanceRecord'.
    aggregate_type  VARCHAR(64) NOT NULL,

    -- Identifier of the specific aggregate instance, e.g. the attendance
    -- record UUID. Stored as text to stay agnostic of the source key type.
    aggregate_id    VARCHAR(64) NOT NULL,

    -- Event name used to build the AMQP routing key,
    -- e.g. 'attendance.student.absent'.
    event_type      VARCHAR(64) NOT NULL,

    -- Full event body as emitted to RabbitMQ. JSONB allows indexing/inspection
    -- without forcing a rigid column-per-field schema.
    payload         JSONB NOT NULL,

    -- Publication state of this outbox row. Kept as a bounded CHECK instead of
    -- a free-form VARCHAR to prevent invalid states from being inserted.
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                        CHECK (status IN ('PENDING', 'PUBLISHED', 'FAILED')),

    -- Row creation time; also the natural ordering key for the relay worker
    -- that polls PENDING rows in FIFO order (see idx_outbox_status_created).
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Set by the relay worker once the message is confirmed published to
    -- 'edutrack.events'. NULL while status = 'PENDING'.
    published_at    TIMESTAMPTZ,

    CONSTRAINT pk_outbox_events PRIMARY KEY (id)
);

-- Composite index supporting the relay worker's polling query:
--   SELECT ... FROM outbox_events WHERE status = 'PENDING' ORDER BY created_at ...
-- Column order (status, created_at) matches the equality-then-range access
-- pattern so Postgres can use the index for both the filter and the sort,
-- avoiding a full table scan and a separate sort step as the table grows.
CREATE INDEX IF NOT EXISTS idx_outbox_status_created
    ON outbox_events (status, created_at);

-- Documents intent directly in the catalog for future maintainers/DBAs.
COMMENT ON TABLE outbox_events IS
    'Transactional Outbox (ADR-007): rows written in the same DB transaction '
    'as the domain change they describe; a relay worker publishes PENDING '
    'rows to RabbitMQ exchange edutrack.events and marks them PUBLISHED.';

COMMENT ON COLUMN outbox_events.id IS
    'Also used as the AMQP message eventId for consumer-side idempotency (Redis SETNX).';
COMMENT ON COLUMN outbox_events.status IS
    'PENDING = not yet relayed, PUBLISHED = confirmed on edutrack.events, FAILED = relay giving up (routed to DLQ upstream).';