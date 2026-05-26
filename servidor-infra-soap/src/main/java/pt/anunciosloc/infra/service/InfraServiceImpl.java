package pt.anunciosloc.infra.service;

import jakarta.jws.WebService;
import pt.anunciosloc.infra.config.ConnectionFactory;
import pt.anunciosloc.infra.model.Local;
import pt.anunciosloc.infra.repository.InfraRepository;
import pt.anunciosloc.infra.repository.SaldoRepository;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

// CORRIGIR: apontar para a interface correta
@WebService(
    endpointInterface = "pt.anunciosloc.infra.service.InfraService",
    targetNamespace = "http://service.infra.anunciosloc.pt/"
)
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
                             double raio, String wifiSsid, long infraestruturaId) {
        System.out.println("=== CRIAR LOCAL ===");
        System.out.println("Nome: " + nome);
        System.out.println("Tipo: " + tipo);
        System.out.println("Latitude: " + latitude);
        System.out.println("Longitude: " + longitude);
        System.out.println("Raio: " + raio);
        System.out.println("InfraestruturaId: " + infraestruturaId);
        
        try {
            String sql = "INSERT INTO locais (nome, tipo, latitude, longitude, raio, wifi_ssid, infraestrutura_id) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";
            
            try (Connection conn = ConnectionFactory.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                
                stmt.setString(1, nome);
                stmt.setString(2, tipo);
                stmt.setDouble(3, latitude);
                stmt.setDouble(4, longitude);
                stmt.setDouble(5, raio);
                stmt.setString(6, wifiSsid != null ? wifiSsid : "");
                stmt.setLong(7, infraestruturaId);
                
                int rows = stmt.executeUpdate();
                System.out.println("Linhas inseridas: " + rows);
            }
            
            System.out.println("Local criado com sucesso: " + nome);
            return "Local criado com sucesso: " + nome;
            
        } catch (SQLException e) {
            System.err.println("ERRO SQL: " + e.getMessage());
            e.printStackTrace();
            return "Erro ao criar local: " + e.getMessage();
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