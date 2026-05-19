package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import pt.anunciosloc.server.model.Anuncio;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AnuncioRepository {
    
    public void salvar(Anuncio anuncio) throws SQLException {
        String sql = "INSERT INTO anuncios (id, titulo, descricao, utilizador_id, local_id, data_criacao, data_expiracao, total_visualizacoes, activo) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, anuncio.getId());
            stmt.setString(2, anuncio.getTitulo());
            stmt.setString(3, anuncio.getDescricao());
            stmt.setLong(4, obterUtilizadorId(anuncio.getAutorEmail(), conn));
            stmt.setLong(5, obterLocalId(anuncio.getLocal(), conn));
            stmt.setTimestamp(6, Timestamp.valueOf(anuncio.getDataCriacao()));
            stmt.setTimestamp(7, Timestamp.valueOf(anuncio.getDataExpiracao()));
            stmt.setInt(8, anuncio.getTotalVisualizacoes());
            stmt.setBoolean(9, anuncio.isActivo());
            
            stmt.executeUpdate();
            
            atualizarEstatisticasUtilizador(anuncio.getAutorEmail(), conn);
            atualizarEstatisticasInfraestrutura(anuncio.getLocal(), conn);
        }
    }
    
    public Anuncio buscarPorId(String id) throws SQLException {
        String sql = "SELECT a.*, u.email as autor_email, l.nome as local_nome FROM anuncios a " +
                     "JOIN utilizadores u ON a.utilizador_id = u.id " +
                     "JOIN locais l ON a.local_id = l.id " +
                     "WHERE a.id = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Anuncio a = new Anuncio();
                a.setId(rs.getString("id"));
                a.setTitulo(rs.getString("titulo"));
                a.setDescricao(rs.getString("descricao"));
                a.setAutorEmail(rs.getString("autor_email"));
                a.setLocal(rs.getString("local_nome"));
                a.setTotalVisualizacoes(rs.getInt("total_visualizacoes"));
                a.setActivo(rs.getBoolean("activo"));
                
                Timestamp ts = rs.getTimestamp("data_criacao");
                if (ts != null) a.setDataCriacao(ts.toLocalDateTime());
                
                ts = rs.getTimestamp("data_expiracao");
                if (ts != null) a.setDataExpiracao(ts.toLocalDateTime());
                
                return a;
            }
            return null;
        }
    }
    
    public List<Anuncio> buscarPorLocal(String localNome) throws SQLException {
        String sql = "SELECT a.*, u.email as autor_email FROM anuncios a " +
                     "JOIN utilizadores u ON a.utilizador_id = u.id " +
                     "JOIN locais l ON a.local_id = l.id " +
                     "WHERE l.nome = ? AND a.activo = true AND a.data_expiracao > NOW() " +
                     "ORDER BY a.data_criacao DESC";
        
        List<Anuncio> lista = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, localNome);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Anuncio a = new Anuncio();
                a.setId(rs.getString("id"));
                a.setTitulo(rs.getString("titulo"));
                a.setDescricao(rs.getString("descricao"));
                a.setAutorEmail(rs.getString("autor_email"));
                a.setLocal(localNome);
                a.setTotalVisualizacoes(rs.getInt("total_visualizacoes"));
                a.setActivo(rs.getBoolean("activo"));
                
                Timestamp ts = rs.getTimestamp("data_criacao");
                if (ts != null) a.setDataCriacao(ts.toLocalDateTime());
                
                ts = rs.getTimestamp("data_expiracao");
                if (ts != null) a.setDataExpiracao(ts.toLocalDateTime());
                
                lista.add(a);
            }
        }
        return lista;
    }
    
    public List<Anuncio> buscarPorAutor(String email) throws SQLException {
        String sql = "SELECT a.*, l.nome as local_nome FROM anuncios a " +
                     "JOIN utilizadores u ON a.utilizador_id = u.id " +
                     "JOIN locais l ON a.local_id = l.id " +
                     "WHERE u.email = ? ORDER BY a.data_criacao DESC";
        
        List<Anuncio> lista = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Anuncio a = new Anuncio();
                a.setId(rs.getString("id"));
                a.setTitulo(rs.getString("titulo"));
                a.setDescricao(rs.getString("descricao"));
                a.setAutorEmail(email);
                a.setLocal(rs.getString("local_nome"));
                a.setTotalVisualizacoes(rs.getInt("total_visualizacoes"));
                a.setActivo(rs.getBoolean("activo"));
                
                Timestamp ts = rs.getTimestamp("data_criacao");
                if (ts != null) a.setDataCriacao(ts.toLocalDateTime());
                
                ts = rs.getTimestamp("data_expiracao");
                if (ts != null) a.setDataExpiracao(ts.toLocalDateTime());
                
                lista.add(a);
            }
        }
        return lista;
    }
    
    public List<Anuncio> listarTodos() throws SQLException {
        String sql = "SELECT a.*, u.email as autor_email, l.nome as local_nome FROM anuncios a " +
                     "JOIN utilizadores u ON a.utilizador_id = u.id " +
                     "JOIN locais l ON a.local_id = l.id " +
                     "ORDER BY a.data_criacao DESC";
        
        List<Anuncio> lista = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Anuncio a = new Anuncio();
                a.setId(rs.getString("id"));
                a.setTitulo(rs.getString("titulo"));
                a.setDescricao(rs.getString("descricao"));
                a.setAutorEmail(rs.getString("autor_email"));
                a.setLocal(rs.getString("local_nome"));
                a.setTotalVisualizacoes(rs.getInt("total_visualizacoes"));
                a.setActivo(rs.getBoolean("activo"));
                
                Timestamp ts = rs.getTimestamp("data_criacao");
                if (ts != null) a.setDataCriacao(ts.toLocalDateTime());
                
                ts = rs.getTimestamp("data_expiracao");
                if (ts != null) a.setDataExpiracao(ts.toLocalDateTime());
                
                lista.add(a);
            }
        }
        return lista;
    }
    
    public List<Anuncio> buscarAtivosPorLocal(String localNome) throws SQLException {
        String sql = "SELECT a.*, u.email as autor_email FROM anuncios a " +
                     "JOIN utilizadores u ON a.utilizador_id = u.id " +
                     "JOIN locais l ON a.local_id = l.id " +
                     "WHERE l.nome = ? AND a.activo = true AND a.data_expiracao > NOW()";
        
        List<Anuncio> lista = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, localNome);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Anuncio a = new Anuncio();
                a.setId(rs.getString("id"));
                a.setTitulo(rs.getString("titulo"));
                a.setDescricao(rs.getString("descricao"));
                a.setAutorEmail(rs.getString("autor_email"));
                a.setLocal(localNome);
                a.setTotalVisualizacoes(rs.getInt("total_visualizacoes"));
                
                Timestamp ts = rs.getTimestamp("data_criacao");
                if (ts != null) a.setDataCriacao(ts.toLocalDateTime());
                
                lista.add(a);
            }
        }
        return lista;
    }
    
    public void registrarVisualizacao(String anuncioId, String emailVisualizador) throws SQLException {
        Connection conn = null;
        try {
            conn = ConnectionFactory.getConnection();
            conn.setAutoCommit(false);
            
            String sql = "INSERT INTO visualizacoes_anuncio (anuncio_id, utilizador_id) " +
                         "VALUES ((SELECT id FROM anuncios WHERE id = ?), " +
                         "(SELECT id FROM utilizadores WHERE email = ?))";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, anuncioId);
                stmt.setString(2, emailVisualizador);
                stmt.executeUpdate();
            }
            
            String updateSql = "UPDATE anuncios SET total_visualizacoes = total_visualizacoes + 1 WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                stmt.setString(1, anuncioId);
                stmt.executeUpdate();
            }
            
            String autorSql = "SELECT u.email FROM anuncios a JOIN utilizadores u ON a.utilizador_id = u.id WHERE a.id = ?";
            String autorEmail = null;
            try (PreparedStatement stmt = conn.prepareStatement(autorSql)) {
                stmt.setString(1, anuncioId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    autorEmail = rs.getString("email");
                }
            }
            
            if (autorEmail != null) {
                String statsSql = "UPDATE utilizadores SET total_visualizacoes_recebidas = total_visualizacoes_recebidas + 1 WHERE email = ?";
                try (PreparedStatement stmt = conn.prepareStatement(statsSql)) {
                    stmt.setString(1, autorEmail);
                    stmt.executeUpdate();
                }
            }
            
            conn.commit();
        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (conn != null) conn.setAutoCommit(true);
            ConnectionFactory.closeConnection(conn);
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
    
    public void desativarAnunciosExpirados() throws SQLException {
        String sql = "UPDATE anuncios SET activo = false WHERE data_expiracao < NOW() AND activo = true";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.executeUpdate();
        }
    }
    
    public void desativar(String id) throws SQLException {
        String sql = "UPDATE anuncios SET activo = false WHERE id = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, id);
            stmt.executeUpdate();
        }
    }
    
    public void ativar(String id) throws SQLException {
        String sql = "UPDATE anuncios SET activo = true WHERE id = ? AND data_expiracao > NOW()";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, id);
            stmt.executeUpdate();
        }
    }
    
    public void eliminar(String id) throws SQLException {
        String sql = "DELETE FROM anuncios WHERE id = ?";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, id);
            stmt.executeUpdate();
        }
    }
    
    public int contarAnunciosAtivosPorUtilizador(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM anuncios a " +
                     "JOIN utilizadores u ON a.utilizador_id = u.id " +
                     "WHERE u.email = ? AND a.activo = true AND a.data_expiracao > NOW()";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }
    
    private long obterUtilizadorId(String email, Connection conn) throws SQLException {
        String sql = "SELECT id FROM utilizadores WHERE email = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getLong("id");
            }
            throw new SQLException("Utilizador nao encontrado: " + email);
        }
    }
    
    private long obterLocalId(String localNome, Connection conn) throws SQLException {
        String sql = "SELECT id FROM locais WHERE nome = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, localNome);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getLong("id");
            }
            return 1;
        }
    }
    
    private void atualizarEstatisticasUtilizador(String email, Connection conn) throws SQLException {
        String sql = "UPDATE utilizadores SET total_anuncios_publicados = total_anuncios_publicados + 1 WHERE email = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.executeUpdate();
        }
    }
    
    private void atualizarEstatisticasInfraestrutura(String localNome, Connection conn) throws SQLException {
        String sql = "UPDATE infraestruturas i " +
                     "JOIN locais l ON i.id = l.infraestrutura_id " +
                     "SET i.anuncios_publicados = i.anuncios_publicados + 1 " +
                     "WHERE l.nome = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, localNome);
            stmt.executeUpdate();
        }
    }
}