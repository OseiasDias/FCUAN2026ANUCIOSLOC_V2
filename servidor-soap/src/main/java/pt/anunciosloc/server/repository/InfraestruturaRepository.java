package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import pt.anunciosloc.server.model.Infraestrutura;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InfraestruturaRepository {
    
    public void salvar(Infraestrutura infra) throws SQLException {
        String sql = "INSERT INTO infraestruturas (nome, capacidade, premio_entrega, conexoes_actuais, anuncios_entregues, anuncios_publicados) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, infra.getNome());
            stmt.setInt(2, infra.getCapacidade());
            stmt.setDouble(3, 2.00);
            stmt.setInt(4, infra.getUtilizadoresConectados());
            stmt.setInt(5, infra.getTotalEntregas());
            stmt.setInt(6, infra.getTotalAnuncios());
            
            stmt.executeUpdate();
            
            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                long infraId = rs.getLong(1);
                salvarLocal(infra, infraId, conn);
            }
        }
    }
    
    private void salvarLocal(Infraestrutura infra, long infraId, Connection conn) throws SQLException {
        String sql = "INSERT INTO locais (nome, tipo, latitude, longitude, raio, infraestrutura_id) VALUES (?, 'GPS', ?, ?, ?, ?)";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, infra.getNome());
            stmt.setDouble(2, infra.getLatitude());
            stmt.setDouble(3, infra.getLongitude());
            stmt.setDouble(4, 50.0);
            stmt.setLong(5, infraId);
            stmt.executeUpdate();
        }
    }
    
    public Infraestrutura buscarPorNome(String nome) throws SQLException {
        String sql = "SELECT i.*, l.latitude, l.longitude FROM infraestruturas i " +
                     "JOIN locais l ON i.id = l.infraestrutura_id " +
                     "WHERE i.nome = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, nome);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Infraestrutura infra = new Infraestrutura();
                infra.setNome(rs.getString("nome"));
                infra.setCapacidade(rs.getInt("capacidade"));
                infra.setUtilizadoresConectados(rs.getInt("conexoes_actuais"));
                infra.setTotalEntregas(rs.getInt("anuncios_entregues"));
                infra.setTotalAnuncios(rs.getInt("anuncios_publicados"));
                infra.setLatitude(rs.getDouble("latitude"));
                infra.setLongitude(rs.getDouble("longitude"));
                infra.setAtivo(true);
                return infra;
            }
            return null;
        }
    }
    
    public List<Infraestrutura> listarTodas() throws SQLException {
        String sql = "SELECT i.*, l.latitude, l.longitude FROM infraestruturas i " +
                     "JOIN locais l ON i.id = l.infraestrutura_id";
        
        List<Infraestrutura> lista = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Infraestrutura infra = new Infraestrutura();
                infra.setNome(rs.getString("nome"));
                infra.setCapacidade(rs.getInt("capacidade"));
                infra.setUtilizadoresConectados(rs.getInt("conexoes_actuais"));
                infra.setTotalEntregas(rs.getInt("anuncios_entregues"));
                infra.setTotalAnuncios(rs.getInt("anuncios_publicados"));
                infra.setLatitude(rs.getDouble("latitude"));
                infra.setLongitude(rs.getDouble("longitude"));
                infra.setAtivo(true);
                lista.add(infra);
            }
        }
        return lista;
    }
    
    public void atualizarEstatisticas(String nome, int entregas, int anuncios) throws SQLException {
        String sql = "UPDATE infraestruturas SET anuncios_entregues = ?, anuncios_publicados = ? WHERE nome = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, entregas);
            stmt.setInt(2, anuncios);
            stmt.setString(3, nome);
            stmt.executeUpdate();
        }
    }
    
    public void incrementarConexoes(String nome) throws SQLException {
        String sql = "UPDATE infraestruturas SET conexoes_actuais = conexoes_actuais + 1 WHERE nome = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, nome);
            stmt.executeUpdate();
        }
    }
    
    public void decrementarConexoes(String nome) throws SQLException {
        String sql = "UPDATE infraestruturas SET conexoes_actuais = GREATEST(conexoes_actuais - 1, 0) WHERE nome = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, nome);
            stmt.executeUpdate();
        }
    }
    
    public void ativar(String nome) throws SQLException {
        String sql = "UPDATE infraestruturas SET ativo = true WHERE nome = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, nome);
            stmt.executeUpdate();
        }
    }
    
    public void desativar(String nome) throws SQLException {
        String sql = "UPDATE infraestruturas SET ativo = false WHERE nome = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, nome);
            stmt.executeUpdate();
        }
    }
    
    public void eliminar(String nome) throws SQLException {
        String sql = "DELETE FROM infraestruturas WHERE nome = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, nome);
            stmt.executeUpdate();
        }
    }
    
    public boolean existe(String nome) throws SQLException {
        String sql = "SELECT 1 FROM infraestruturas WHERE nome = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, nome);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }
}