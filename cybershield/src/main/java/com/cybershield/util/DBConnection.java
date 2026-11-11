
package com.cybershield.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/cybershield";

    private static final String USERNAME = "cybershield_app";

    public static Connection getConnection() throws SQLException {

        // Read database password from Windows environment variable
        String password = System.getenv("CYBERSHIELD_DB_PASSWORD");
        if (password == null || password.trim().isEmpty()) {
            throw new SQLException(
                "CYBERSHIELD_DB_PASSWORD environment variable is not configured."
            );
        }

        // Load MySQL JDBC Driver
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                "MySQL JDBC Driver not found. Check WEB-INF/lib.",
                e
            );
        }

        // Establish database connection
        return DriverManager.getConnection(URL, USERNAME, password);
    }

    // Test database connection
    public static boolean testConnection() {

        try (Connection connection = getConnection()) {

            if (connection != null && connection.isValid(2)) {
                System.out.println("CyberShield Database Connected Successfully!");
                return true;
            }

        } catch (SQLException e) {
            System.err.println("CyberShield Database Connection Failed!");
            e.printStackTrace();
        }

        return false;
    }
}
