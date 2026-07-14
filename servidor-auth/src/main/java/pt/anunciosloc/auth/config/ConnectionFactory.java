package pt.anunciosloc.auth.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConnectionFactory {
    
    private static final String URL = "jdbc:mysql://localhost:3306/anunciosloc?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    
    // Lista de senhas possíveis
    private static final String[] SENHAS_POSSIVEIS = {
        "",           // XAMPP padrão
        "root123",    // Comum em instalações
        "123456",     // Comum
        "password",   // Comum
        "admin",      // Comum
        "root"        // Comum
    };
    
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("Driver MySQL carregado com sucesso");
        } catch (ClassNotFoundException e) {
            System.err.println("Erro ao carregar driver MySQL: " + e.getMessage());
            throw new RuntimeException("Driver MySQL nao encontrado", e);
        }
    }
    
    public static Connection getConnection() throws SQLException {
        SQLException ultimoErro = null;
        
        for (String senha : SENHAS_POSSIVEIS) {
            try {
                System.out.println("🔑 Tentando senha: '" + senha + "'");
                Connection conn = DriverManager.getConnection(URL, USER, senha);
                System.out.println("✅ CONECTADO! Senha correta: '" + senha + "'");
                return conn;
            } catch (SQLException e) {
                ultimoErro = e;
                System.out.println("❌ Falha com senha: '" + senha + "'");
            }
        }
        
        System.err.println("❌ TODAS AS SENHAS FALHARAM!");
        System.err.println("Por favor, verifique a senha do MySQL no XAMPP");
        throw new SQLException("Nao foi possivel conectar ao MySQL. Verifique as credenciais.", ultimoErro);
    }
    
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.err.println("Erro ao fechar conexao: " + e.getMessage());
            }
        }
    }
}