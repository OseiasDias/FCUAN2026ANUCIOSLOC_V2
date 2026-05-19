package pt.anunciosloc.infra.repository;

import pt.anunciosloc.infra.config.ConnectionFactory;
import java.sql.*;

public class SaldoRepository {
    
    public double obterSaldo(String email) throws SQLException {
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
    
    public void atualizarSaldo(String email, double saldo) throws SQLException {
        String sql = "UPDATE utilizadores SET saldo = ? WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setDouble(1, saldo);
            stmt.setString(2, email);
            stmt.executeUpdate();
        }
    }
    
    public void atualizarReplicaSaldo(String email, String infraNome, double saldo, int versao) throws SQLException {
        String sql = "INSERT INTO replica_saldo (utilizador_id, infraestrutura_id, saldo, versao) " +
                     "VALUES ((SELECT id FROM utilizadores WHERE email = ?), " +
                     "(SELECT id FROM infraestruturas WHERE nome = ?), ?, ?) " +
                     "ON DUPLICATE KEY UPDATE saldo = ?, versao = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            stmt.setString(2, infraNome);
            stmt.setDouble(3, saldo);
            stmt.setInt(4, versao);
            stmt.setDouble(5, saldo);
            stmt.setInt(6, versao);
            stmt.executeUpdate();
        }
    }
    
    public double obterReplicaSaldo(String email, String infraNome) throws SQLException {
        String sql = "SELECT r.saldo FROM replica_saldo r " +
                     "JOIN utilizadores u ON r.utilizador_id = u.id " +
                     "JOIN infraestruturas i ON r.infraestrutura_id = i.id " +
                     "WHERE u.email = ? AND i.nome = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            stmt.setString(2, infraNome);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("saldo");
            }
            return -1;
        }
    }
}