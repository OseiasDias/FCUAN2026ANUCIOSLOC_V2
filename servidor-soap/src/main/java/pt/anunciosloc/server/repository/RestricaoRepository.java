package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import pt.anunciosloc.shared.Restricao;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RestricaoRepository {
    
    public void salvarRestricao(Restricao restricao) throws SQLException {
        String sql = "INSERT INTO restricoes (anuncio_id, tipo, chave_restricao, valor_restricao) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setLong(1, restricao.getAnuncioId());
            stmt.setString(2, restricao.getTipo());
            stmt.setString(3, restricao.getChave());
            stmt.setString(4, restricao.getValor());
            stmt.executeUpdate();
            
            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                restricao.setId(rs.getLong(1));
            }
        }
    }
    
    public List<Restricao> listarPorAnuncio(Long anuncioId) throws SQLException {
        String sql = "SELECT * FROM restricoes WHERE anuncio_id = ?";
        List<Restricao> restricoes = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, anuncioId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Restricao r = new Restricao();
                r.setId(rs.getLong("id"));
                r.setAnuncioId(rs.getLong("anuncio_id"));
                r.setTipo(rs.getString("tipo"));
                r.setChave(rs.getString("chave_restricao"));
                r.setValor(rs.getString("valor_restricao"));
                restricoes.add(r);
            }
        }
        return restricoes;
    }
    
    public void removerRestricao(Long restricaoId) throws SQLException {
        String sql = "DELETE FROM restricoes WHERE id = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, restricaoId);
            stmt.executeUpdate();
        }
    }
    
    public void removerRestricoesPorAnuncio(Long anuncioId) throws SQLException {
        String sql = "DELETE FROM restricoes WHERE anuncio_id = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, anuncioId);
            stmt.executeUpdate();
        }
    }
}