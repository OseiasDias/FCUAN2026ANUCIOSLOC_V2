package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.UUID;

public class SessaoRepository {
    
    public String criarSessao(String email) throws SQLException {
        String token = UUID.randomUUID().toString();
        String sql = "INSERT INTO sessoes (utilizador_id, token, data_inicio, expiracao) " +
                     "VALUES ((SELECT id FROM utilizadores WHERE email = ?), ?, NOW(), DATE_ADD(NOW(), INTERVAL 24 HOUR))";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            stmt.setString(2, token);
            stmt.executeUpdate();
            
            return token;
        }
    }
    
    public boolean validarSessao(String token) throws SQLException {
        String sql = "SELECT 1 FROM sessoes WHERE token = ? AND expiracao > NOW()";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, token);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }
    
    public String obterEmailPorToken(String token) throws SQLException {
        String sql = "SELECT u.email FROM sessoes s " +
                     "JOIN utilizadores u ON s.utilizador_id = u.id " +
                     "WHERE s.token = ? AND s.expiracao > NOW()";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, token);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getString("email");
            }
            return null;
        }
    }
    
    public void invalidarSessao(String token) throws SQLException {
        String sql = "DELETE FROM sessoes WHERE token = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, token);
            stmt.executeUpdate();
        }
    }
    
    public void limparSessoesExpiradas() throws SQLException {
        String sql = "DELETE FROM sessoes WHERE expiracao < NOW()";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.executeUpdate();
        }
    }
}