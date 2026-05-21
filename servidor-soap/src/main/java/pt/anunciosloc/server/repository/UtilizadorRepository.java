package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import pt.anunciosloc.server.model.Utilizador;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.security.MessageDigest;

public class UtilizadorRepository {
    
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            return password;
        }
    }
    
    public void salvar(Utilizador utilizador) throws SQLException {
        String sql = "INSERT INTO utilizadores (nome, email, senha, saldo, data_criacao, ultimo_anuncio, sessao_activa) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, utilizador.getNome());
            stmt.setString(2, utilizador.getEmail());
            // Aplicar hash na senha antes de salvar
            stmt.setString(3, hashPassword(utilizador.getPassword()));
            stmt.setDouble(4, utilizador.getSaldo());
            stmt.setTimestamp(5, Timestamp.valueOf(utilizador.getDataRegisto()));
            stmt.setTimestamp(6, utilizador.getUltimoAnuncio() != null ? 
                Timestamp.valueOf(utilizador.getUltimoAnuncio()) : null);
            stmt.setBoolean(7, utilizador.isSessaoActiva());
            
            stmt.executeUpdate();
            
            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                utilizador.setId(rs.getLong(1));
            }
        }
    }
    
    public Utilizador buscarPorEmail(String email) throws SQLException {
        String sql = "SELECT * FROM utilizadores WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Utilizador u = new Utilizador();
                u.setId(rs.getLong("id"));
                u.setEmail(rs.getString("email"));
                u.setNome(rs.getString("nome"));
                u.setPassword(rs.getString("senha"));
                u.setSaldo(rs.getDouble("saldo"));
                u.setSessaoActiva(rs.getBoolean("sessao_activa"));
                
                Timestamp ts = rs.getTimestamp("data_criacao");
                if (ts != null) u.setDataRegisto(ts.toLocalDateTime());
                
                ts = rs.getTimestamp("ultimo_anuncio");
                if (ts != null) u.setUltimoAnuncio(ts.toLocalDateTime());
                
                return u;
            }
            return null;
        }
    }
    
    public List<Utilizador> listarTodos() throws SQLException {
        String sql = "SELECT * FROM utilizadores ORDER BY data_criacao DESC";
        List<Utilizador> lista = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Utilizador u = new Utilizador();
                u.setId(rs.getLong("id"));
                u.setEmail(rs.getString("email"));
                u.setNome(rs.getString("nome"));
                u.setPassword(rs.getString("senha"));
                u.setSaldo(rs.getDouble("saldo"));
                u.setSessaoActiva(rs.getBoolean("sessao_activa"));
                
                Timestamp ts = rs.getTimestamp("data_criacao");
                if (ts != null) u.setDataRegisto(ts.toLocalDateTime());
                
                ts = rs.getTimestamp("ultimo_anuncio");
                if (ts != null) u.setUltimoAnuncio(ts.toLocalDateTime());
                
                lista.add(u);
            }
        }
        return lista;
    }
    
    public boolean debitarSaldo(String email, double valor) throws SQLException {
        String sql = "UPDATE utilizadores SET saldo = saldo - ? WHERE email = ? AND saldo >= ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setDouble(1, valor);
            stmt.setString(2, email);
            stmt.setDouble(3, valor);
            
            int atualizados = stmt.executeUpdate();
            return atualizados > 0;
        }
    }
    
    public void creditarSaldo(String email, double valor) throws SQLException {
        String sql = "UPDATE utilizadores SET saldo = saldo + ? WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setDouble(1, valor);
            stmt.setString(2, email);
            stmt.executeUpdate();
        }
    }
    
    public void atualizarSaldo(String email, double novoSaldo) throws SQLException {
        String sql = "UPDATE utilizadores SET saldo = ? WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setDouble(1, novoSaldo);
            stmt.setString(2, email);
            stmt.executeUpdate();
        }
    }
    
    public void atualizarUltimoAnuncio(String email, LocalDateTime data) throws SQLException {
        String sql = "UPDATE utilizadores SET ultimo_anuncio = ? WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setTimestamp(1, Timestamp.valueOf(data));
            stmt.setString(2, email);
            stmt.executeUpdate();
        }
    }
    
    public void desativar(String email) throws SQLException {
        String sql = "UPDATE utilizadores SET sessao_activa = false WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            stmt.executeUpdate();
        }
    }
    
    public void reativar(String email) throws SQLException {
        String sql = "UPDATE utilizadores SET sessao_activa = true WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            stmt.executeUpdate();
        }
    }
    
    public void eliminar(String email) throws SQLException {
        String sql = "DELETE FROM utilizadores WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            stmt.executeUpdate();
        }
    }
    
    public boolean existe(String email) throws SQLException {
        String sql = "SELECT 1 FROM utilizadores WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }
    
    public boolean verificarCredenciais(String email, String password) throws SQLException {
        String sql = "SELECT 1 FROM utilizadores WHERE email = ? AND senha = ? AND sessao_activa = true";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            // Aplicar hash na senha informada para comparar
            stmt.setString(2, hashPassword(password));
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }
    
    public void atualizarEstatisticas(String email, int anuncios, int visualizacoes) throws SQLException {
        String sql = "UPDATE utilizadores SET total_anuncios_publicados = ?, total_visualizacoes_recebidas = ? WHERE email = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, anuncios);
            stmt.setInt(2, visualizacoes);
            stmt.setString(3, email);
            stmt.executeUpdate();
        }
    }
}