package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;

public class PerfilUtilizadorRepository {
    
    public void salvarPerfil(Long utilizadorId, String chave, String valor) throws SQLException {
        String sql = "INSERT INTO perfil_utilizador (utilizador_id, chave_perfil, valor_perfil) VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE valor_perfil = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, utilizadorId);
            stmt.setString(2, chave);
            stmt.setString(3, valor);
            stmt.setString(4, valor);
            stmt.executeUpdate();
        }
    }
    
    public Map<String, String> obterPerfil(Long utilizadorId) throws SQLException {
        String sql = "SELECT chave_perfil, valor_perfil FROM perfil_utilizador WHERE utilizador_id = ?";
        Map<String, String> perfil = new HashMap<>();
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, utilizadorId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                perfil.put(rs.getString("chave_perfil"), rs.getString("valor_perfil"));
            }
        }
        return perfil;
    }
    
    public String obterPreferencia(Long utilizadorId, String chave) throws SQLException {
        String sql = "SELECT valor_perfil FROM perfil_utilizador WHERE utilizador_id = ? AND chave_perfil = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, utilizadorId);
            stmt.setString(2, chave);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getString("valor_perfil");
            }
            return null;
        }
    }
    
    public void removerPreferencia(Long utilizadorId, String chave) throws SQLException {
        String sql = "DELETE FROM perfil_utilizador WHERE utilizador_id = ? AND chave_perfil = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, utilizadorId);
            stmt.setString(2, chave);
            stmt.executeUpdate();
        }
    }
}