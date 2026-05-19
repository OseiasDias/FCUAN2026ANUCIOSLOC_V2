package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import java.sql.*;

public class ReplicaSaldoRepository {
    
    public void atualizarReplica(String email, String infraNome, int saldo) throws SQLException {
        String sql = "INSERT INTO replica_saldo (utilizador_id, infraestrutura_id, saldo, versao) " +
                     "VALUES ((SELECT id FROM utilizadores WHERE email = ?), " +
                     "(SELECT id FROM infraestruturas WHERE nome = ?), ?, 1) " +
                     "ON DUPLICATE KEY UPDATE saldo = ?, versao = versao + 1";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            stmt.setString(2, infraNome);
            stmt.setInt(3, saldo);
            stmt.setInt(4, saldo);
            stmt.executeUpdate();
        }
    }
    
    public int consultarReplica(String email, String infraNome) throws SQLException {
        String sql = "SELECT saldo FROM replica_saldo r " +
                     "JOIN utilizadores u ON r.utilizador_id = u.id " +
                     "JOIN infraestruturas i ON r.infraestrutura_id = i.id " +
                     "WHERE u.email = ? AND i.nome = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            stmt.setString(2, infraNome);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("saldo");
            }
            return -1;
        }
    }
}