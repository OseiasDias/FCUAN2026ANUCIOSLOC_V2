package pt.anunciosloc.shared;

import java.sql.*;
import java.util.Properties;

public class MySQLConnection {
    
    private static final String URL = "jdbc:mysql://localhost:3306/anunciosloc";
    private static final String USER = "root";
    private static final String PASSWORD = "";  // ← SENHA VAZIA!
    
    private static Connection connection = null;
    
    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            Properties props = new Properties();
            props.setProperty("user", USER);
            props.setProperty("password", PASSWORD);
            props.setProperty("useSSL", "false");
            props.setProperty("serverTimezone", "UTC");
            connection = DriverManager.getConnection(URL, props);
        }
        return connection;
    }
    
    public static void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            System.out.println("✅ Conectado ao MySQL!");
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("❌ Erro ao conectar ao MySQL: " + e.getMessage());
            return false;
        }
    }
}