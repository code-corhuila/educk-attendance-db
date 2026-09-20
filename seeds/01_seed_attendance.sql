-- Seeds de prueba para eventos de asistencia
INSERT INTO attendance_events (id, student_id, date, status, teacher_id, sequence_num, idempotency_key)
VALUES ('55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', CURRENT_DATE, 'PRESENT', '22222222-2222-2222-2222-222222222222', 1, 'idem-key-initial-demo-001')
ON CONFLICT (idempotency_key) DO NOTHING;
