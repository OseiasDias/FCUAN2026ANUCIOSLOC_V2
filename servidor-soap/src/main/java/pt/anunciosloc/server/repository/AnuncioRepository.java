package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import pt.anunciosloc.server.model.Anuncio;
import pt.anunciosloc.shared.Restricao;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class AnuncioRepository {

    // ==================== SALVAR ====================

    public void salvar(Anuncio anuncio) throws SQLException {
        Long utilizadorId = obterUtilizadorId(anuncio.getAutorEmail());
        Long localId = obterLocalId(anuncio.getLocal());

        String sql = "INSERT INTO anuncios (id, titulo, descricao, utilizador_id, local_id, data_criacao, data_expiracao, total_visualizacoes, activo) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, anuncio.getId());
            stmt.setString(2, anuncio.getTitulo());
            stmt.setString(3, anuncio.getDescricao());
            stmt.setLong(4, utilizadorId);
            stmt.setLong(5, localId);
            stmt.setTimestamp(6, Timestamp.valueOf(anuncio.getDataCriacao()));
            stmt.setTimestamp(7, Timestamp.valueOf(anuncio.getDataExpiracao()));
            stmt.setInt(8, anuncio.getTotalVisualizacoes());
            stmt.setBoolean(9, anuncio.isActivo());

            stmt.executeUpdate();
        }
    }

    // ==================== BUSCAR ====================

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
                return mapearAnuncio(rs);
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
                if (ts != null)
                    a.setDataCriacao(ts.toLocalDateTime());

                ts = rs.getTimestamp("data_expiracao");
                if (ts != null)
                    a.setDataExpiracao(ts.toLocalDateTime());

                lista.add(a);
            }
        }
        return lista;
    }

   public List<Anuncio> buscarPorAutor(String email) throws SQLException {
    String sql = "SELECT a.id, a.titulo, a.descricao, a.data_criacao, a.data_expiracao, " +
                 "a.total_visualizacoes, a.activo, " +
                 "u.email as autor_email, " +
                 "l.nome as local_nome " +
                 "FROM anuncios a " +
                 "JOIN utilizadores u ON a.utilizador_id = u.id " +
                 "JOIN locais l ON a.local_id = l.id " +
                 "WHERE u.email = ? " +
                 "ORDER BY a.data_criacao DESC";

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
                lista.add(mapearAnuncio(rs));
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
                if (ts != null)
                    a.setDataCriacao(ts.toLocalDateTime());

                lista.add(a);
            }
        }
        return lista;
    }

    public List<Anuncio> buscarPorLocalAtivo(String local) throws SQLException {
        return buscarAtivosPorLocal(local);
    }

    // ==================== ATUALIZAR ====================

    public void registrarVisualizacao(String anuncioId, String emailVisualizador) throws SQLException {
        Connection conn = null;
        try {
            conn = ConnectionFactory.getConnection();
            conn.setAutoCommit(false);

            String sqlInsert = "INSERT INTO visualizacoes_anuncio (anuncio_id, utilizador_id) " +
                    "VALUES ((SELECT id FROM anuncios WHERE id = ?), " +
                    "(SELECT id FROM utilizadores WHERE email = ?))";

            try (PreparedStatement stmt = conn.prepareStatement(sqlInsert)) {
                stmt.setString(1, anuncioId);
                stmt.setString(2, emailVisualizador);
                stmt.executeUpdate();
            }

            String sqlUpdate = "UPDATE anuncios SET total_visualizacoes = total_visualizacoes + 1 WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlUpdate)) {
                stmt.setString(1, anuncioId);
                stmt.executeUpdate();
            }

            conn.commit();

        } catch (SQLException e) {
            if (conn != null)
                conn.rollback();
            throw e;
        } finally {
            if (conn != null)
                conn.setAutoCommit(true);
            ConnectionFactory.closeConnection(conn);
        }
    }

    public void incrementarVisualizacao(String anuncioId) throws SQLException {
        String sql = "UPDATE anuncios SET total_visualizacoes = total_visualizacoes + 1 WHERE id = ?";

        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, anuncioId);
            stmt.executeUpdate();
        }
    }

    // ==================== ATIVAR / DESATIVAR ====================

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

    public void desativarAnunciosExpirados() throws SQLException {
        String sql = "UPDATE anuncios SET activo = false WHERE data_expiracao < NOW() AND activo = true";

        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.executeUpdate();
        }
    }

    // ==================== ELIMINAR ====================

    public void eliminar(String id) throws SQLException {
        String sql = "DELETE FROM anuncios WHERE id = ?";

        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, id);
            stmt.executeUpdate();
        }
    }

    // ==================== CONTAGEM ====================

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

    // ==================== VERIFICACOES ====================

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

    // ==================== FILTRAGEM POR PERFIL ====================

    public List<Anuncio> buscarAnunciosVisiveisPorLocal(String localNome, Map<String, String> perfilUtilizador)
            throws SQLException {
        String sql = "SELECT a.*, u.email as autor_email FROM anuncios a " +
                "JOIN utilizadores u ON a.utilizador_id = u.id " +
                "JOIN locais l ON a.local_id = l.id " +
                "WHERE l.nome = ? AND a.activo = true AND a.data_expiracao > NOW() " +
                "ORDER BY a.data_criacao DESC";

        List<Anuncio> todosAnuncios = new ArrayList<>();

        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, localNome);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                todosAnuncios.add(mapearAnuncio(rs));
            }
        }

        // Filtrar por restricoes
        RestricaoRepository restricaoRepo = new RestricaoRepository();
        List<Anuncio> visiveis = new ArrayList<>();

        for (Anuncio anuncio : todosAnuncios) {
            if (isAnuncioVisivel(anuncio, perfilUtilizador, restricaoRepo)) {
                visiveis.add(anuncio);
            }
        }

        return visiveis;
    }

    private boolean isAnuncioVisivel(Anuncio anuncio, Map<String, String> perfil, RestricaoRepository restricaoRepo)
            throws SQLException {
        Long anuncioId = obterIdAnuncio(anuncio.getId());
        if (anuncioId == null)
            return true;

        List<Restricao> restricoes = restricaoRepo.listarPorAnuncio(anuncioId);

        for (Restricao r : restricoes) {
            String valorPerfil = perfil.getOrDefault(r.getChave(), "");

            if (r.getTipo().equals("WHITELIST")) {
                if (!valorPerfil.equals(r.getValor())) {
                    return false;
                }
            } else if (r.getTipo().equals("BLACKLIST")) {
                if (valorPerfil.equals(r.getValor())) {
                    return false;
                }
            }
        }
        return true;
    }

    // ==================== METODOS AUXILIARES ====================

    private Long obterUtilizadorId(String email) throws SQLException {
        String sql = "SELECT id FROM utilizadores WHERE email = ?";
        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getLong("id");
            }
            throw new SQLException("Utilizador nao encontrado: " + email);
        }
    }

   private Long obterLocalId(String localNome) throws SQLException {
    // Primeiro tentar com comparação exata (case-sensitive)
    String sql = "SELECT id FROM locais WHERE nome = ?";
    try (Connection conn = ConnectionFactory.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, localNome);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            return rs.getLong("id");
        }
    }
    
    // Se não encontrou, tentar com LOWER e TRIM (case-insensitive)
    String sqlLike = "SELECT id FROM locais WHERE LOWER(TRIM(nome)) = LOWER(TRIM(?))";
    try (Connection conn = ConnectionFactory.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sqlLike)) {
        stmt.setString(1, localNome);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            System.out.println("Local encontrado com case-insensitive: " + localNome);
            return rs.getLong("id");
        }
    }
    
    // Se ainda não encontrou, tentar com LIKE (ignorando espaços)
    String sqlLike2 = "SELECT id FROM locais WHERE REPLACE(LOWER(nome), ' ', '') = REPLACE(LOWER(?), ' ', '')";
    try (Connection conn = ConnectionFactory.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sqlLike2)) {
        stmt.setString(1, localNome);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            System.out.println("Local encontrado com REPLACE: " + localNome);
            return rs.getLong("id");
        }
    }
    
    // Local padrão (1) se não encontrar
    System.out.println("Local nao encontrado, usando ID 1: " + localNome);
    return 1L;
}
    private Long obterIdAnuncio(String id) throws SQLException {
        String sql = "SELECT id FROM anuncios WHERE id = ?";
        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getLong(1);
            }
            return null;
        }
    }

    private Anuncio mapearAnuncio(ResultSet rs) throws SQLException {
        Anuncio a = new Anuncio();
        a.setId(rs.getString("id"));
        a.setTitulo(rs.getString("titulo"));
        a.setDescricao(rs.getString("descricao"));
        a.setAutorEmail(rs.getString("autor_email"));
        a.setLocal(rs.getString("local_nome"));
        a.setTotalVisualizacoes(rs.getInt("total_visualizacoes"));
        a.setActivo(rs.getBoolean("activo"));

        Timestamp ts = rs.getTimestamp("data_criacao");
        if (ts != null)
            a.setDataCriacao(ts.toLocalDateTime());

        ts = rs.getTimestamp("data_expiracao");
        if (ts != null)
            a.setDataExpiracao(ts.toLocalDateTime());

        return a;
    }
}