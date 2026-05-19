package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import java.sql.*;

public class VisualizacaoRepository {
    
    public void registrarVisualizacao(String anuncioId, String email) throws SQLException {
        String sql = "INSERT INTO visualizacoes_anuncio (anuncio_id, utilizador_id, data_visualizacao) " +
                     "VALUES ((SELECT id FROM anuncios WHERE id = ?), " +
                     "(SELECT id FROM utilizadores WHERE email = ?), NOW())";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, anuncioId);
            stmt.setString(2, email);
            stmt.executeUpdate();
        }
    }
    
    public boolean jaVisualizou(String anuncioId, String email) throws SQLException {
        String sql = "SELECT 1 FROM visualizacoes_anuncio v " +
                     "JOIN anuncios a ON v.anuncio_id = a.id " +
                     "JOIN utilizadores u ON v.utilizador_id = u.id " +
                     "WHERE a.id = ? AND u.email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, anuncioId);
            stmt.setString(2, email);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }
    
    public int contarVisualizacoes(String anuncioId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM visualizacoes_anuncio WHERE anuncio_id = (SELECT id FROM anuncios WHERE id = ?)";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, anuncioId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }
}