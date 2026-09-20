-- =============================================================================
-- V1 & V2: Esquema y Datos Semilla - Asistencia Escolar & Orden Causal (educk-attendance-db :5433)
-- =============================================================================

CREATE TABLE IF NOT EXISTS class_sessions (
    id VARCHAR(36) PRIMARY KEY,
    course_id VARCHAR(36) NOT NULL,
    session_date DATE NOT NULL,
    title VARCHAR(120),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS attendance_records (
    id VARCHAR(36) PRIMARY KEY,
    session_id VARCHAR(36) REFERENCES class_sessions(id) ON DELETE CASCADE,
    student_id VARCHAR(36) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED')),
    lamport_timestamp BIGINT NOT NULL DEFAULT 1,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS absence_justifications (
    id VARCHAR(36) PRIMARY KEY,
    attendance_id VARCHAR(36) REFERENCES attendance_records(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    parent_id VARCHAR(36),
    approved_by VARCHAR(36),
    lamport_timestamp BIGINT NOT NULL DEFAULT 2,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Sesiones de Clase en Septiembre 2026
INSERT INTO class_sessions (id, course_id, session_date, title) VALUES
('ses-001', 'crs-dist-001', '2026-09-05', 'Sesión 1: Arquitectura de Microservicios y ADRs'),
('ses-002', 'crs-dist-001', '2026-09-12', 'Sesión 2: Gobernanza Git y Calidad de Código'),
('ses-003', 'crs-dist-001', '2026-09-19', 'Sesión 3: Pase de Lista y Orden Causal en Eventos')
ON CONFLICT DO NOTHING;

-- Registro de Asistencias (Todos Presentes con Lamport Clocks sincronizados)
INSERT INTO attendance_records (id, session_id, student_id, status, lamport_timestamp) VALUES
('att-001', 'ses-003', 'usr-estud-001', 'PRESENT', 101),
('att-002', 'ses-003', 'usr-estud-002', 'PRESENT', 102),
('att-003', 'ses-003', 'usr-estud-003', 'PRESENT', 103),
('att-004', 'ses-003', 'usr-estud-004', 'PRESENT', 104)
ON CONFLICT DO NOTHING;
