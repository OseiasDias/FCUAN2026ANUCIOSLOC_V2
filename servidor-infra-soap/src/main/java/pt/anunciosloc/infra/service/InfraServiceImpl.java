package pt.anunciosloc.infra.service;

import jakarta.jws.WebService;
import pt.anunciosloc.infra.config.ConnectionFactory;
import pt.anunciosloc.infra.model.Local;
import pt.anunciosloc.infra.repository.InfraRepository;
import pt.anunciosloc.infra.repository.SaldoRepository;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebService(endpointInterface = "pt.anunciosloc.infra.service.InfraService", 
           targetNamespace = "http://service.infra.anunciosloc.pt/")
public class InfraServiceImpl implements InfraService {

    private String nome;
    private InfraRepository infraRepo;
    private SaldoRepository saldoRepo;

    public InfraServiceImpl() {
        this.infraRepo = new InfraRepository();
        this.saldoRepo = new SaldoRepository();

        try {
            this.nome = infraRepo.obterNomeInfraestrutura();
        } catch (SQLException e) {
            this.nome = "Infraestrutura Central";
            System.err.println("Erro ao obter nome: " + e.getMessage());
        }

        System.out.println("=== INFRAESTRUTURA INICIADA COM MYSQL ===");
        System.out.println("Nome: " + nome);
        System.out.println("Porta: 8081");
        System.out.println("=========================================");
    }

    @Override
    public String getNome() {
        return nome;
    }

    @Override
    public Local getLocal() {
        try {
            return infraRepo.obterLocal();
        } catch (SQLException e) {
            System.err.println("Erro ao obter local: " + e.getMessage());
            return new Local("Largo da Independencia", "GPS", -8.838333, 13.234444, 20);
        }
    }

    @Override
    public int getCapacidade() {
        try {
            return infraRepo.obterCapacidade();
        } catch (SQLException e) {
            System.err.println("Erro ao obter capacidade: " + e.getMessage());
            return 100;
        }
    }

    @Override
    public int getUtilizadoresConectados() {
        try {
            return infraRepo.obterUtilizadoresConectados();
        } catch (SQLException e) {
            System.err.println("Erro ao obter utilizadores conectados: " + e.getMessage());
            return 0;
        }
    }

    @Override
    public int getTotalAnuncios() {
        try {
            return infraRepo.obterTotalAnuncios();
        } catch (SQLException e) {
            System.err.println("Erro ao obter total anuncios: " + e.getMessage());
            return 0;
        }
    }

    @Override
    public int getTotalEntregas() {
        try {
            return infraRepo.obterTotalEntregas();
        } catch (SQLException e) {
            System.err.println("Erro ao obter total entregas: " + e.getMessage());
            return 0;
        }
    }

    @Override
    public String obterInfoInfraestrutura() {
        try {
            StringBuilder sb = new StringBuilder();
            sb.append("Infraestrutura: ").append(infraRepo.obterNomeInfraestrutura()).append("\n");
            sb.append("Capacidade: ").append(infraRepo.obterCapacidade()).append("\n");
            sb.append("Conectados: ").append(infraRepo.obterUtilizadoresConectados()).append("\n");
            sb.append("Anuncios: ").append(infraRepo.obterTotalAnuncios()).append("\n");
            sb.append("Entregas: ").append(infraRepo.obterTotalEntregas());
            return sb.toString();
        } catch (SQLException e) {
            System.err.println("Erro ao obter info infraestrutura: " + e.getMessage());
            return "Erro ao obter info: " + e.getMessage();
        }
    }

    @Override
    public String criarLocal(String nome, String tipo, double latitude, double longitude, 
                             double raio, String wifiSsid, long infraestruturaId, String email) {
        System.out.println("=== CRIAR LOCAL ===");
        System.out.println("Nome: " + nome);
        System.out.println("Email: " + email);
        
        try {
            // Buscar ID do utilizador pelo email
            String sqlUser = "SELECT id FROM utilizadores WHERE email = ?";
            Long userId = null;
            
            try (Connection conn = ConnectionFactory.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sqlUser)) {
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    userId = rs.getLong("id");
                }
            }
            
            if (userId == null) {
                return "Erro: Utilizador nao encontrado com email: " + email;
            }
            
            String sql = "INSERT INTO locais (nome, tipo, latitude, longitude, raio, wifi_ssid, infraestrutura_id, criado_por) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            
            try (Connection conn = ConnectionFactory.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                
                stmt.setString(1, nome);
                stmt.setString(2, tipo);
                stmt.setDouble(3, latitude);
                stmt.setDouble(4, longitude);
                stmt.setDouble(5, raio);
                stmt.setString(6, wifiSsid != null ? wifiSsid : "");
                stmt.setLong(7, infraestruturaId);
                stmt.setLong(8, userId);
                stmt.executeUpdate();
            }
            
            System.out.println("Local criado com sucesso: " + nome);
            return "Local criado com sucesso: " + nome;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return "Erro ao criar local: " + e.getMessage();
        }
    }

    
@Override
public String[] listarLocaisPorUtilizador(String email) {
    System.out.println("=== LISTAR LOCAIS POR UTILIZADOR ===");
    System.out.println("Email recebido: " + email);
    
    try {
        // Buscar ID do utilizador pelo email
        String sqlUser = "SELECT id FROM utilizadores WHERE email = ?";
        Long userId = null;
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sqlUser)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                userId = rs.getLong("id");
                System.out.println("User ID encontrado: " + userId);
            } else {
                System.out.println("Email nao encontrado: " + email);
            }
        }
        
        // Se nao encontrou o email, retorna vazio
        if (userId == null) {
            return new String[0];
        }
        
        // Buscar locais criados pelo utilizador
        String sql = "SELECT id, nome, tipo, latitude, longitude, raio, wifi_ssid FROM locais WHERE criado_por = ? ORDER BY id DESC";
        List<String> locais = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, userId);
            System.out.println("Executando query com userId: " + userId);
            ResultSet rs = stmt.executeQuery();
            
            int count = 0;
            while (rs.next()) {
                count++;
                System.out.println("Local #" + count + ": " + rs.getString("nome"));
                String data = rs.getInt("id") + "|" +
                              rs.getString("nome") + "|" +
                              rs.getString("tipo") + "|" +
                              rs.getDouble("latitude") + "|" +
                              rs.getDouble("longitude") + "|" +
                              rs.getDouble("raio") + "|" +
                              (rs.getString("wifi_ssid") != null ? rs.getString("wifi_ssid") : "");
                locais.add(data);
            }
            System.out.println("Total de locais encontrados: " + count);
        }
        
        return locais.toArray(new String[0]);
        
    } catch (SQLException e) {
        System.err.println("Erro ao listar locais: " + e.getMessage());
        e.printStackTrace();
        return new String[0];
    }
}

    @Override
    public String atualizarLocal(int id, String nome, String tipo, double latitude, 
                                 double longitude, double raio, String wifiSsid) {
        System.out.println("=== ATUALIZAR LOCAL ===");
        System.out.println("ID: " + id);
        System.out.println("Nome: " + nome);
        
        try {
            String sql = "UPDATE locais SET nome = ?, tipo = ?, latitude = ?, longitude = ?, " +
                         "raio = ?, wifi_ssid = ? WHERE id = ?";
            
            try (Connection conn = ConnectionFactory.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                
                stmt.setString(1, nome);
                stmt.setString(2, tipo);
                stmt.setDouble(3, latitude);
                stmt.setDouble(4, longitude);
                stmt.setDouble(5, raio);
                stmt.setString(6, wifiSsid != null ? wifiSsid : "");
                stmt.setInt(7, id);
                stmt.executeUpdate();
            }
            
            return "Local atualizado com sucesso: " + nome;
            
        } catch (SQLException e) {
            return "Erro ao atualizar local: " + e.getMessage();
        }
    }

    @Override
    public String eliminarLocal(int id) {
        System.out.println("=== ELIMINAR LOCAL ===");
        System.out.println("ID: " + id);
        
        try {
            String sql = "DELETE FROM locais WHERE id = ?";
            
            try (Connection conn = ConnectionFactory.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                
                stmt.setInt(1, id);
                int rows = stmt.executeUpdate();
                System.out.println("Linhas eliminadas: " + rows);
            }
            
            return "Local eliminado com sucesso!";
            
        } catch (SQLException e) {
            return "Erro ao eliminar local: " + e.getMessage();
        }
    }

    @Override
    public int obterSaldo(String email) {
        try {
            double saldo = saldoRepo.obterSaldo(email);
            System.out.println("Consultando saldo: " + email + " = " + (int) saldo);
            return (int) saldo;
        } catch (SQLException e) {
            System.err.println("Erro ao obter saldo: " + e.getMessage());
            return 0;
        }
    }

    @Override
    public String escreverSaldo(String email, int valor) {
        try {
            saldoRepo.atualizarSaldo(email, (double) valor);
            saldoRepo.atualizarReplicaSaldo(email, nome, (double) valor, 1);
            System.out.println("Saldo atualizado: " + email + " = " + valor);
            return "Saldo de " + email + " atualizado para " + valor;
        } catch (SQLException e) {
            System.err.println("Erro ao escrever saldo: " + e.getMessage());
            return "Erro: " + e.getMessage();
        }
    }

    @Override
    public String incrementarUtilizadoresConectados() {
        try {
            infraRepo.incrementarUtilizadoresConectados();
            return "OK";
        } catch (SQLException e) {
            System.err.println("Erro ao incrementar utilizadores: " + e.getMessage());
            return "Erro: " + e.getMessage();
        }
    }

    @Override
    public String decrementarUtilizadoresConectados() {
        try {
            infraRepo.decrementarUtilizadoresConectados();
            return "OK";
        } catch (SQLException e) {
            System.err.println("Erro ao decrementar utilizadores: " + e.getMessage());
            return "Erro: " + e.getMessage();
        }
    }

    @Override
    public String incrementarAnunciosPublicados() {
        try {
            infraRepo.incrementarAnunciosPublicados();
            return "OK";
        } catch (SQLException e) {
            System.err.println("Erro ao incrementar anuncios publicados: " + e.getMessage());
            return "Erro: " + e.getMessage();
        }
    }

    @Override
    public String incrementarAnunciosEntregues() {
        try {
            infraRepo.incrementarAnunciosEntregues();
            return "OK";
        } catch (SQLException e) {
            System.err.println("Erro ao incrementar anuncios entregues: " + e.getMessage());
            return "Erro: " + e.getMessage();
        }
    }

    @Override
    public String ping() {
        return "Infraestrutura '" + nome + "' ativa com MySQL!";
    }

    @Override
    public String registrarNoUDDI() {
        return "Registado no UDDI";
    }
}