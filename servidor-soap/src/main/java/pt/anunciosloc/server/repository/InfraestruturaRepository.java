package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import pt.anunciosloc.server.model.Infraestrutura;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InfraestruturaRepository {

    // ==================== SALVAR ====================

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

    // ==================== BUSCAR ====================

    public Infraestrutura buscarPorNome(String nome) throws SQLException {
        // 1. Tentar buscar na tabela locais primeiro (mais comum)
        String sqlLocais = "SELECT l.*, i.id as infra_id, i.nome as infra_nome, " +
                "i.capacidade, i.conexoes_actuais, i.anuncios_entregues, i.anuncios_publicados " +
                "FROM locais l " +
                "LEFT JOIN infraestruturas i ON l.infraestrutura_id = i.id " +
                "WHERE LOWER(TRIM(l.nome)) = LOWER(TRIM(?))";

        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sqlLocais)) {

            stmt.setString(1, nome);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Infraestrutura infra = new Infraestrutura();
                infra.setNome(rs.getString("nome"));
                infra.setLocalizacao(rs.getString("nome"));
                infra.setLatitude(rs.getDouble("latitude"));
                infra.setLongitude(rs.getDouble("longitude"));
                // infra.setRaio(rs.getDouble("raio")); ← REMOVER ESTA LINHA

                // Dados da infraestrutura (se existir)
                try {
                    infra.setId(rs.getLong("infra_id"));
                    infra.setCapacidade(rs.getInt("capacidade"));
                    infra.setUtilizadoresConectados(rs.getInt("conexoes_actuais"));
                    infra.setTotalEntregas(rs.getInt("anuncios_entregues"));
                    infra.setTotalAnuncios(rs.getInt("anuncios_publicados"));
                } catch (SQLException e) {
                    infra.setCapacidade(100);
                    infra.setUtilizadoresConectados(0);
                    infra.setTotalEntregas(0);
                    infra.setTotalAnuncios(0);
                }

                infra.setAtivo(true);
                return infra;
            }
        }

        // 2. Se não encontrou, tentar buscar na tabela infraestruturas
        String sqlInfra = "SELECT i.*, l.latitude, l.longitude FROM infraestruturas i " +
                "LEFT JOIN locais l ON i.id = l.infraestrutura_id " +
                "WHERE LOWER(TRIM(i.nome)) = LOWER(TRIM(?))";

        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sqlInfra)) {

            stmt.setString(1, nome);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Infraestrutura infra = new Infraestrutura();
                infra.setNome(rs.getString("nome"));
                infra.setCapacidade(rs.getInt("capacidade"));
                infra.setUtilizadoresConectados(rs.getInt("conexoes_actuais"));
                infra.setTotalEntregas(rs.getInt("anuncios_entregues"));
                infra.setTotalAnuncios(rs.getInt("anuncios_publicados"));

                try {
                    infra.setLatitude(rs.getDouble("latitude"));
                    infra.setLongitude(rs.getDouble("longitude"));
                } catch (SQLException e) {
                    infra.setLatitude(0.0);
                    infra.setLongitude(0.0);
                }

                infra.setAtivo(true);
                System.out.println("Local encontrado na tabela infraestruturas: " + nome);
                return infra;
            }
        }

        System.out.println("Local nao encontrado: " + nome);
        return null;
    }

    public List<Infraestrutura> listarTodas() throws SQLException {
        String sql = "SELECT i.*, l.latitude, l.longitude FROM infraestruturas i " +
                "JOIN locais l ON i.id = l.infraestrutura_id";

        List<Infraestrutura> lista = new ArrayList<>();

        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearInfraestrutura(rs));
            }
        }
        return lista;
    }

    public Infraestrutura buscarPorId(Long id) throws SQLException {
        String sql = "SELECT i.*, l.latitude, l.longitude FROM infraestruturas i " +
                "JOIN locais l ON i.id = l.infraestrutura_id " +
                "WHERE i.id = ?";

        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapearInfraestrutura(rs);
            }
            return null;
        }
    }

    // ==================== ATUALIZAR ====================

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

    // ==================== ATIVAR / DESATIVAR ====================

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

    // ==================== ELIMINAR ====================

    public void eliminar(String nome) throws SQLException {
        // Primeiro eliminar os locais associados
        String sqlLocal = "DELETE FROM locais WHERE infraestrutura_id = (SELECT id FROM infraestruturas WHERE nome = ?)";
        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sqlLocal)) {
            stmt.setString(1, nome);
            stmt.executeUpdate();
        }

        // Depois eliminar a infraestrutura
        String sql = "DELETE FROM infraestruturas WHERE nome = ?";
        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, nome);
            stmt.executeUpdate();
        }
    }

    // ==================== VERIFICAR ====================

    public boolean existe(String nome) throws SQLException {
        String sql = "SELECT 1 FROM infraestruturas WHERE nome = ?";

        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, nome);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }

    // ==================== METODO AUXILIAR ====================

    private Infraestrutura mapearInfraestrutura(ResultSet rs) throws SQLException {
        Infraestrutura infra = new Infraestrutura();

        // Dados da infraestrutura
        try {
            infra.setId(rs.getLong("id"));
        } catch (SQLException e) {
            // coluna id pode não existir
        }

        infra.setNome(rs.getString("nome"));
        infra.setCapacidade(rs.getInt("capacidade"));
        infra.setUtilizadoresConectados(rs.getInt("conexoes_actuais"));
        infra.setTotalEntregas(rs.getInt("anuncios_entregues"));
        infra.setTotalAnuncios(rs.getInt("anuncios_publicados"));

        // Dados do local (JOIN)
        try {
            infra.setLatitude(rs.getDouble("latitude"));
            infra.setLongitude(rs.getDouble("longitude"));
        } catch (SQLException e) {
            infra.setLatitude(0.0);
            infra.setLongitude(0.0);
        }

        // Ativo
        try {
            infra.setAtivo(rs.getBoolean("ativo"));
        } catch (SQLException e) {
            infra.setAtivo(true);
        }

        return infra;
    }
}