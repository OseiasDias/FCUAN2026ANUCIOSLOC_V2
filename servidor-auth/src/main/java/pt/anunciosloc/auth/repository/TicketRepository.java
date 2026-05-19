package pt.anunciosloc.auth.repository;

import pt.anunciosloc.auth.config.ConnectionFactory;
import pt.anunciosloc.shared.Ticket;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.UUID;

public class TicketRepository {
    
    public String criarTicket(String email, String chaveSessao, int duracaoSegundos) throws SQLException {
        String ticketId = UUID.randomUUID().toString();
        LocalDateTime expiracao = LocalDateTime.now().plusSeconds(duracaoSegundos);
        
        String sql = "INSERT INTO sessoes (utilizador_id, token, data_inicio, expiracao) " +
                     "VALUES ((SELECT id FROM utilizadores WHERE email = ?), ?, NOW(), ?)";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            stmt.setString(2, ticketId);
            stmt.setTimestamp(3, Timestamp.valueOf(expiracao));
            stmt.executeUpdate();
            
            return ticketId;
        }
    }
    
    public boolean validarTicket(String ticketId, String email) throws SQLException {
        String sql = "SELECT 1 FROM sessoes s " +
                     "JOIN utilizadores u ON s.utilizador_id = u.id " +
                     "WHERE s.token = ? AND u.email = ? AND s.expiracao > NOW()";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, ticketId);
            stmt.setString(2, email);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }
    
    public boolean invalidarTicket(String ticketId) throws SQLException {
        String sql = "DELETE FROM sessoes WHERE token = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, ticketId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        }
    }
    
    public void limparTicketsExpirados() throws SQLException {
        String sql = "DELETE FROM sessoes WHERE expiracao < NOW()";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.executeUpdate();
        }
    }
}