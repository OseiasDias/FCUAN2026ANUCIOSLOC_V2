package pt.anunciosloc.auth.repository;

import pt.anunciosloc.auth.config.ConnectionFactory;
import pt.anunciosloc.auth.security.PasswordUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UtilizadorAuthRepository {
    
    public boolean registarUtilizador(String email, String password) throws SQLException {
        String sql = "INSERT INTO utilizadores (nome, email, senha, saldo, data_criacao, sessao_activa) VALUES (?, ?, ?, 10.00, NOW(), true)";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String nome = email.substring(0, email.indexOf('@'));
            stmt.setString(1, nome);
            stmt.setString(2, email);
            stmt.setString(3, PasswordUtil.hash(password));
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean verificarCredenciais(String email, String password) throws SQLException {
        String sql = "SELECT senha FROM utilizadores WHERE email = ? AND sessao_activa = true";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                String hash = rs.getString("senha");
                return PasswordUtil.verify(password, hash);
            }
            return false;
        }
    }
    
    public int getUserIdByEmail(String email) throws SQLException {
        String sql = "SELECT id FROM utilizadores WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("id");
            }
            return -1;
        }
    }
    
    public double getSaldoByEmail(String email) throws SQLException {
        String sql = "SELECT saldo FROM utilizadores WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("saldo");
            }
            return 0;
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