package com.cybershield.dao;

import com.cybershield.model.Incident;
import com.cybershield.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class IncidentDao {

    private static final String SELECT_BASE =
            "SELECT i.id, i.title, i.description, i.incident_type, i.severity, "
            + "i.status, i.investigation_notes, i.reported_by, i.resolved_by, "
            + "i.created_at, i.resolved_at, i.updated_at, "
            + "u.full_name AS reporter_name, u.username AS reporter_username, "
            + "u.email AS reporter_email, r.full_name AS resolver_name "
            + "FROM incidents i "
            + "LEFT JOIN users u ON u.id = i.reported_by "
            + "LEFT JOIN users r ON r.id = i.resolved_by ";

    public int create(String title, String description, String incidentType,
                      String severity, int reportedBy) throws SQLException {

        String sql = "INSERT INTO incidents "
                + "(title, description, incident_type, severity, status, reported_by) "
                + "VALUES (?, ?, ?, ?, 'OPEN', ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, title);
            ps.setString(2, description);
            ps.setString(3, incidentType);
            ps.setString(4, severity);
            ps.setInt(5, reportedBy);

            if (ps.executeUpdate() != 1) {
                return 0;
            }
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    public Incident findById(int id) throws SQLException {
        String sql = SELECT_BASE + "WHERE i.id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public List<Incident> findByUser(int userId, String search,
                                     String status, String severity)
            throws SQLException {

        return query(userId, search, status, severity, 0);
    }

    public List<Incident> findAll(String search, String status, String severity)
            throws SQLException {

        return query(null, search, status, severity, 0);
    }

    public List<Incident> findRecent(Integer userId, int limit)
            throws SQLException {

        return query(userId, null, null, null, limit);
    }

    private List<Incident> query(Integer userId, String search,
                                 String status, String severity, int limit)
            throws SQLException {

        StringBuilder sql = new StringBuilder(SELECT_BASE);
        List<Object> parameters = new ArrayList<>();

        List<String> conditions = new ArrayList<>();
        if (userId != null) {
            conditions.add("i.reported_by = ?");
            parameters.add(userId);
        }
        String term = search == null ? "" : search.trim();
        if (!term.isEmpty()) {
            conditions.add("(i.title LIKE ? OR i.description LIKE ? "
                    + "OR i.incident_type LIKE ?)");
            String like = "%" + term + "%";
            parameters.add(like);
            parameters.add(like);
            parameters.add(like);
        }
        if (isValidStatus(status)) {
            conditions.add("i.status = ?");
            parameters.add(status);
        }
        if (isValidSeverity(severity)) {
            conditions.add("i.severity = ?");
            parameters.add(severity);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions))
               .append(' ');
        }
        sql.append("ORDER BY i.created_at DESC, i.id DESC");
        if (limit > 0) {
            sql.append(" LIMIT ?");
            parameters.add(limit);
        }

        List<Incident> incidents = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < parameters.size(); i++) {
                Object value = parameters.get(i);
                if (value instanceof Integer) {
                    ps.setInt(i + 1, (Integer) value);
                } else {
                    ps.setString(i + 1, String.valueOf(value));
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    incidents.add(map(rs));
                }
            }
        }
        return incidents;
    }

    public int[] getStats(Integer userId) throws SQLException {
        String sql = "SELECT COUNT(*), "
                + "COALESCE(SUM(status = 'OPEN'), 0), "
                + "COALESCE(SUM(status = 'IN_PROGRESS'), 0), "
                + "COALESCE(SUM(status = 'RESOLVED'), 0) "
                + "FROM incidents";

        if (userId != null) {
            sql += " WHERE reported_by = ?";
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (userId != null) {
                ps.setInt(1, userId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{rs.getInt(1), rs.getInt(2),
                            rs.getInt(3), rs.getInt(4)};
                }
            }
        }
        return new int[]{0, 0, 0, 0};
    }

    public Map<String, Integer> distribution(String dimension, Integer userId)
            throws SQLException {

        String column;
        switch (dimension == null ? "" : dimension) {
            case "status":
                column = "status";
                break;
            case "incident_type":
                column = "incident_type";
                break;
            case "severity":
            default:
                column = "severity";
                break;
        }

        String sql = "SELECT " + column + " AS label, COUNT(*) AS total "
                + "FROM incidents";
        if (userId != null) {
            sql += " WHERE reported_by = ?";
        }
        sql += " GROUP BY " + column + " ORDER BY total DESC";

        Map<String, Integer> result = new LinkedHashMap<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (userId != null) {
                ps.setInt(1, userId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String label = rs.getString("label");
                    result.put(label == null ? "Unknown" : label, rs.getInt("total"));
                }
            }
        }
        return result;
    }

    public boolean updateStatus(int incidentId, String status, String notes,
                                Integer actorId, boolean admin, int userId)
            throws SQLException {

        if (!isValidStatus(status)) {
            return false;
        }

        boolean resolved = "RESOLVED".equals(status);
        Timestamp resolvedAt = resolved ? new Timestamp(System.currentTimeMillis()) : null;
        Integer resolvedBy = resolved ? actorId : null;

        String sql = "UPDATE incidents SET status = ?, "
                + "investigation_notes = COALESCE(?, investigation_notes), "
                + "resolved_at = ?, resolved_by = ? WHERE id = ?";

        if (!admin) {
            sql += " AND reported_by = ?";
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            int index = 1;
            ps.setString(index++, status);
            ps.setString(index++, normalizeNotes(notes));
            if (resolvedAt == null) {
                ps.setNull(index++, java.sql.Types.TIMESTAMP);
            } else {
                ps.setTimestamp(index++, resolvedAt);
            }
            if (resolvedBy == null) {
                ps.setNull(index++, java.sql.Types.INTEGER);
            } else {
                ps.setInt(index++, resolvedBy);
            }
            ps.setInt(index++, incidentId);
            if (!admin) {
                ps.setInt(index, userId);
            }
            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateNotes(int incidentId, String notes) throws SQLException {
        String sql = "UPDATE incidents SET investigation_notes = ? WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, normalizeNotes(notes));
            ps.setInt(2, incidentId);
            return ps.executeUpdate() == 1;
        }
    }

    private String normalizeNotes(String notes) {
        if (notes == null) {
            return null;
        }
        String trimmed = notes.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    public static boolean isValidStatus(String status) {
        return "OPEN".equals(status)
                || "IN_PROGRESS".equals(status)
                || "RESOLVED".equals(status);
    }

    public static boolean isValidSeverity(String severity) {
        return "LOW".equals(severity)
                || "MEDIUM".equals(severity)
                || "HIGH".equals(severity)
                || "CRITICAL".equals(severity);
    }

    private Incident map(ResultSet rs) throws SQLException {
        Incident incident = new Incident();
        incident.setId(rs.getInt("id"));
        incident.setTitle(rs.getString("title"));
        incident.setDescription(rs.getString("description"));
        incident.setIncidentType(rs.getString("incident_type"));
        incident.setSeverity(rs.getString("severity"));
        incident.setStatus(rs.getString("status"));
        incident.setInvestigationNotes(rs.getString("investigation_notes"));
        incident.setReportedBy(rs.getInt("reported_by"));

        int resolver = rs.getInt("resolved_by");
        incident.setResolvedBy(rs.wasNull() ? null : resolver);

        incident.setCreatedAt(rs.getTimestamp("created_at"));
        incident.setResolvedAt(rs.getTimestamp("resolved_at"));
        incident.setUpdatedAt(rs.getTimestamp("updated_at"));
        incident.setReporterName(rs.getString("reporter_name"));
        incident.setReporterUsername(rs.getString("reporter_username"));
        incident.setReporterEmail(rs.getString("reporter_email"));
        incident.setResolverName(rs.getString("resolver_name"));
        return incident;
    }
}
