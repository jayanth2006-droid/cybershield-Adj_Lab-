-- CyberShield migration v2
-- Safe, additive migration. It does NOT drop tables or delete records.
-- Run once against the existing `cybershield` database.

USE cybershield;

ALTER TABLE incidents
    ADD COLUMN investigation_notes TEXT NULL AFTER status,
    ADD COLUMN resolved_at TIMESTAMP NULL AFTER investigation_notes,
    ADD COLUMN resolved_by INT NULL AFTER resolved_at,
    ADD COLUMN updated_at TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

ALTER TABLE incidents
    ADD INDEX idx_incidents_status (status),
    ADD INDEX idx_incidents_severity (severity),
    ADD INDEX idx_incidents_type (incident_type),
    ADD INDEX idx_incidents_created_at (created_at);

ALTER TABLE incidents
    ADD CONSTRAINT fk_incidents_resolver
        FOREIGN KEY (resolved_by) REFERENCES users(id)
        ON DELETE SET NULL;
