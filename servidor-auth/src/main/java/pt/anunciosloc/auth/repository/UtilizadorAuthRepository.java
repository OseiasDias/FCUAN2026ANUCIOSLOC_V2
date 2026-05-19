package pt.anunciosloc.auth.repository;

import pt.anunciosloc.auth.config.ConnectionFactory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.security.MessageDigest;
import java.util.Base64;

public class UtilizadorAuthRepository {
    
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            return password;
        }
    }
    
    public boolean registarUtilizador(String email, String password) throws SQLException {
        String sql = "INSERT INTO utilizadores (nome, email, senha, saldo, data_criacao, sessao_activa) VALUES (?, ?, ?, 10.00, NOW(), true)";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String nome = email.substring(0, email.indexOf('@'));
            stmt.setString(1, nome);
            stmt.setString(2, email);
            stmt.setString(3, hashPassword(password));
            
            int rows = stmt.executeUpdate();
            return rows > 0;
        }
    }
    
    public boolean verificarCredenciais(String email, String password) throws SQLException {
        String sql = "SELECT senha FROM utilizadores WHERE email = ? AND sessao_activa = true";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                String hashArmazenado = rs.getString("senha");
                String hashInformado = hashPassword(password);
                return hashArmazenado.equals(hashInformado);
            }
            return false;
        }
    }
    
    public boolean utilizadorExiste(String email) throws SQLException {
        String sql = "SELECT 1 FROM utilizadores WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }
    
    public void atualizarUltimoLogin(String email) throws SQLException {
        String sql = "UPDATE utilizadores SET ultimo_anuncio = NOW() WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            stmt.executeUpdate();
        }
    }
}