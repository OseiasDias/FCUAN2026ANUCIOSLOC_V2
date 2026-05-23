package pt.anunciosloc.auth.repository;

import pt.anunciosloc.auth.config.ConnectionFactory;
import java.sql.*;
import java.util.UUID;

public class TicketRepository {
    
    public String criarRefreshToken(int userId) throws SQLException {
        String token = UUID.randomUUID().toString();
        
        String sql = "INSERT INTO refresh_tokens (user_id, token, expiracao) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 7 DAY))";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setString(2, token);
            stmt.executeUpdate();
            
            return token;
        }
    }
    
    public boolean validarRefreshToken(String token) throws SQLException {
        String sql = "SELECT 1 FROM refresh_tokens WHERE token = ? AND expiracao > NOW() AND usado = false";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, token);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }
    
    public void marcarRefreshTokenUsado(String token) throws SQLException {
        String sql = "UPDATE refresh_tokens SET usado = true WHERE token = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, token);
            stmt.executeUpdate();
        }
    }
    
    public void limparTokensExpirados() throws SQLException {
        String sql = "DELETE FROM refresh_tokens WHERE expiracao < NOW()";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.executeUpdate();
        }
    }
}