-- Domain-owned grants; migration history is deliberately excluded.
GRANT USAGE ON SCHEMA attendance TO attendance_reader, attendance_writer;
GRANT SELECT ON attendance.attendance_events, attendance.attendance_processed, attendance.outbox_events TO attendance_reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON attendance.attendance_events, attendance.attendance_processed, attendance.outbox_events TO attendance_writer;
