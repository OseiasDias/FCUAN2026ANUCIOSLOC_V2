package pt.anunciosloc.server.repository;

import pt.anunciosloc.server.config.ConnectionFactory;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ComentarioRepository {
    
    public void salvarComentario(String anuncioId, String email, String texto) throws SQLException {
        String sql = "INSERT INTO comentarios (anuncio_id, utilizador_id, texto, data_comentario) " +
                     "VALUES ((SELECT id FROM anuncios WHERE id = ?), " +
                     "(SELECT id FROM utilizadores WHERE email = ?), ?, NOW())";
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, anuncioId);
            stmt.setString(2, email);
            stmt.setString(3, texto);
            stmt.executeUpdate();
        }
    }
    
    public List<String> listarComentarios(String anuncioId) throws SQLException {
        String sql = "SELECT c.texto, c.data_comentario, u.nome, u.email " +
                     "FROM comentarios c " +
                     "JOIN utilizadores u ON c.utilizador_id = u.id " +
                     "WHERE c.anuncio_id = (SELECT id FROM anuncios WHERE id = ?) " +
                     "ORDER BY c.data_comentario DESC";
        
        List<String> comentarios = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, anuncioId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                String comentario = rs.getString("u.nome") + " (" + rs.getTimestamp("data_comentario") + "): " + rs.getString("texto");
                comentarios.add(comentario);
            }
        }
        return comentarios;
    }
}