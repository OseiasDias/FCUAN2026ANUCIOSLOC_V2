package pt.anunciosloc.server.repository;

import pt.anunciosloc.shared.Administrador;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

public class AdminRepository {
    
    private Connection connection;
    
    public AdminRepository(Connection connection) {
        this.connection = connection;
    }
    
    public void criarTabela() throws SQLException {
        String sql = """
            CREATE TABLE IF NOT EXISTS administradores (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                email VARCHAR(100) UNIQUE NOT NULL,
                nome VARCHAR(100) NOT NULL,
                password_hash VARCHAR(255) NOT NULL,
                role VARCHAR(20) DEFAULT 'ADMIN',
                ativo BOOLEAN DEFAULT TRUE,
                data_registo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                ultimo_acesso TIMESTAMP
            )
        """;
        try (Statement stmt = connection.createStatement()) {
            stmt.execute(sql);
        }
    }
    
    public void inserirAdminPadrao() throws SQLException {
        String sql = """
            INSERT IGNORE INTO administradores (email, nome, password_hash, role)
            VALUES (?, ?, ?, ?)
        """;
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, "admin@anunciosloc.com");
            stmt.setString(2, "Administrador");
            stmt.setString(3, hashPassword("admin123"));
            stmt.setString(4, "SUPER_ADMIN");
            stmt.executeUpdate();
        }
    }
    
    public Administrador findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM administradores WHERE email = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapToAdmin(rs);
            }
            return null;
        }
    }
    
    public boolean existeAdmin(String email) throws SQLException {
        String sql = "SELECT 1 FROM administradores WHERE email = ? AND ativo = 1";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }
    
    public void atualizarUltimoAcesso(String email) throws SQLException {
        String sql = "UPDATE administradores SET ultimo_acesso = ? WHERE email = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            stmt.setString(2, email);
            stmt.executeUpdate();
        }
    }
    
    private Administrador mapToAdmin(ResultSet rs) throws SQLException {
        Administrador admin = new Administrador();
        admin.setId(rs.getLong("id"));
        admin.setEmail(rs.getString("email"));
        admin.setNome(rs.getString("nome"));
        admin.setPasswordHash(rs.getString("password_hash"));
        admin.setRole(rs.getString("role"));
        admin.setAtivo(rs.getBoolean("ativo"));
        
        Timestamp dataRegisto = rs.getTimestamp("data_registo");
        if (dataRegisto != null) {
            admin.setDataRegisto(dataRegisto.toLocalDateTime());
        }
        
        Timestamp ultimoAcesso = rs.getTimestamp("ultimo_acesso");
        if (ultimoAcesso != null) {
            admin.setUltimoAcesso(ultimoAcesso.toLocalDateTime());
        }
        return admin;
    }
    
    private String hashPassword(String password) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            return password;
        }
    }
}