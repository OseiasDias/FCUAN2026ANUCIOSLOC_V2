package pt.anunciosloc.infra.repository;

import pt.anunciosloc.infra.config.ConnectionFactory;
import pt.anunciosloc.infra.model.Local;
import java.sql.*;

public class InfraRepository {
    
    public String obterNomeInfraestrutura() throws SQLException {
        String sql = "SELECT nome FROM infraestruturas WHERE id = 1";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                return rs.getString("nome");
            }
            return "Infraestrutura Central";
        }
    }
    
    public int obterCapacidade() throws SQLException {
        String sql = "SELECT capacidade FROM infraestruturas WHERE id = 1";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("capacidade");
            }
            return 100;
        }
    }
    
    public int obterUtilizadoresConectados() throws SQLException {
        String sql = "SELECT conexoes_actuais FROM infraestruturas WHERE id = 1";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("conexoes_actuais");
            }
            return 0;
        }
    }
    
    public int obterTotalAnuncios() throws SQLException {
        String sql = "SELECT anuncios_publicados FROM infraestruturas WHERE id = 1";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("anuncios_publicados");
            }
            return 0;
        }
    }
    
    public int obterTotalEntregas() throws SQLException {
        String sql = "SELECT anuncios_entregues FROM infraestruturas WHERE id = 1";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("anuncios_entregues");
            }
            return 0;
        }
    }
    
    public void incrementarUtilizadoresConectados() throws SQLException {
        String sql = "UPDATE infraestruturas SET conexoes_actuais = conexoes_actuais + 1 WHERE id = 1";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.executeUpdate();
        }
    }
    
    public void decrementarUtilizadoresConectados() throws SQLException {
        String sql = "UPDATE infraestruturas SET conexoes_actuais = GREATEST(conexoes_actuais - 1, 0) WHERE id = 1";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.executeUpdate();
        }
    }
    
    public void incrementarAnunciosPublicados() throws SQLException {
        String sql = "UPDATE infraestruturas SET anuncios_publicados = anuncios_publicados + 1 WHERE id = 1";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.executeUpdate();
        }
    }
    
    public void incrementarAnunciosEntregues() throws SQLException {
        String sql = "UPDATE infraestruturas SET anuncios_entregues = anuncios_entregues + 1 WHERE id = 1";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.executeUpdate();
        }
    }
    
    public Local obterLocal() throws SQLException {
        String sql = "SELECT * FROM locais WHERE infraestrutura_id = 1 LIMIT 1";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                Local local = new Local();
                local.setId(rs.getLong("id"));
                local.setNome(rs.getString("nome"));
                local.setTipo(rs.getString("tipo"));
                local.setLatitude(rs.getDouble("latitude"));
                local.setLongitude(rs.getDouble("longitude"));
                local.setRaio(rs.getDouble("raio"));
                local.setWifiSsid(rs.getString("wifi_ssid"));
                local.setInfraestruturaId(rs.getLong("infraestrutura_id"));
                return local;
            }
            return null;
        }
    }
}