package com.cybershield.dao;

import com.cybershield.model.User;
import com.cybershield.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserDao {

    private static final String COLUMNS =
            "id, full_name, email, username, password_hash, role, created_at";

    public User findByLogin(String identifier) throws SQLException {
        String sql = "SELECT " + COLUMNS + " FROM users "
                + "WHERE username = ? OR email = ? LIMIT 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, identifier);
            ps.setString(2, identifier);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public User findById(int id) throws SQLException {
        String sql = "SELECT " + COLUMNS + " FROM users WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public int create(String fullName, String email,
                      String username, String passwordHash)
            throws SQLException {

        String sql = "INSERT INTO users "
                + "(full_name, email, username, password_hash, role) "
                + "VALUES (?, ?, ?, ?, 'USER')";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, username);
            ps.setString(4, passwordHash);
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    public boolean emailBelongsToOther(String email, int userId)
            throws SQLException {

        String sql = "SELECT 1 FROM users WHERE email = ? AND id <> ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean updateProfile(int userId, String fullName, String email)
            throws SQLException {

        String sql = "UPDATE users SET full_name = ?, email = ? WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setInt(3, userId);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean updatePassword(int userId, String passwordHash)
            throws SQLException {

        String sql = "UPDATE users SET password_hash = ? WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, passwordHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateRole(int userId, String role) throws SQLException {
        String sql = "UPDATE users SET role = ? WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, role);
            ps.setInt(2, userId);
            return ps.executeUpdate() == 1;
        }
    }

    public int countAdmins() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'ADMIN'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public List<User> findAll() throws SQLException {
        String sql = "SELECT " + COLUMNS + " FROM users ORDER BY created_at DESC";

        List<User> users = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                users.add(map(rs));
            }
        }
        return users;
    }

    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private User map(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setUsername(rs.getString("username"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setRole(rs.getString("role"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }
}
