package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;

public class RestricaoRepository {
    
    public void adicionarRestricao(String anuncioId, String tipo, String chave, String valor) throws SQLException {
        String sql = "INSERT INTO restricoes (anuncio_id, tipo, chave_restricao, valor_restricao) " +
                     "VALUES ((SELECT id FROM anuncios WHERE id = ?), ?, ?, ?)";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, anuncioId);
            stmt.setString(2, tipo);
            stmt.setString(3, chave);
            stmt.setString(4, valor);
            stmt.executeUpdate();
        }
    }
    
    public Map<String, Map<String, String>> obterRestricoes(String anuncioId) throws SQLException {
        String sql = "SELECT tipo, chave_restricao, valor_restricao FROM restricoes " +
                     "WHERE anuncio_id = (SELECT id FROM anuncios WHERE id = ?)";
        
        Map<String, Map<String, String>> restricoes = new HashMap<>();
        restricoes.put("WHITELIST", new HashMap<>());
        restricoes.put("BLACKLIST", new HashMap<>());
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, anuncioId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                String tipo = rs.getString("tipo");
                String chave = rs.getString("chave_restricao");
                String valor = rs.getString("valor_restricao");
                restricoes.get(tipo).put(chave, valor);
            }
        }
        return restricoes;
    }
}