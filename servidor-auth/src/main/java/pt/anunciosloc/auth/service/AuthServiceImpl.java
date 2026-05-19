package pt.anunciosloc.auth.service;

import jakarta.jws.WebService;
import pt.anunciosloc.shared.Ticket;
import pt.anunciosloc.auth.repository.UtilizadorAuthRepository;
import pt.anunciosloc.auth.repository.TicketRepository;
import java.sql.SQLException;
import java.util.UUID;

@WebService(endpointInterface = "pt.anunciosloc.auth.service.AuthService")
public class AuthServiceImpl implements AuthService {
    
    private UtilizadorAuthRepository utilizadorRepo;
    private TicketRepository ticketRepo;
    
    public AuthServiceImpl() {
        this.utilizadorRepo = new UtilizadorAuthRepository();
        this.ticketRepo = new TicketRepository();
        
        System.out.println("=== KERBEROS AUTHENTICATION SERVICE COM MYSQL ===");
        System.out.println("Base de dados: anunciosloc");
        System.out.println("================================================");
    }
    
    private String gerarChaveSessao() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 32);
    }
    
    @Override
    public String ping() {
        return "Kerberos AS ativo com MySQL!";
    }
    
    @Override
    public Ticket solicitarTicket(String email, String password) {
        System.out.println("Login solicitado para: " + email);
        
        try {
            if (!utilizadorRepo.verificarCredenciais(email, password)) {
                System.err.println("Credenciais invalidas para: " + email);
                throw new RuntimeException("Email ou password incorretos");
            }
            
            String chaveSessao = gerarChaveSessao();
            String ticketId = ticketRepo.criarTicket(email, chaveSessao, 3600);
            
            utilizadorRepo.atualizarUltimoLogin(email);
            
            Ticket ticket = new Ticket(email, chaveSessao, 3600);
            ticket.setTicketId(ticketId);
            
            System.out.println("Login bem-sucedido: " + email);
            return ticket;
            
        } catch (SQLException e) {
            System.err.println("Erro ao solicitar ticket: " + e.getMessage());
            throw new RuntimeException("Erro na autenticacao: " + e.getMessage());
        }
    }
    
    @Override
    public boolean validarTicket(String ticketId, String email) {
        try {
            return ticketRepo.validarTicket(ticketId, email);
        } catch (SQLException e) {
            System.err.println("Erro ao validar ticket: " + e.getMessage());
            return false;
        }
    }
    
    @Override
    public boolean invalidarTicket(String ticketId) {
        try {
            return ticketRepo.invalidarTicket(ticketId);
        } catch (SQLException e) {
            System.err.println("Erro ao invalidar ticket: " + e.getMessage());
            return false;
        }
    }
    
    @Override
    public String registarUtilizador(String email, String password) {
        try {
            if (utilizadorRepo.utilizadorExiste(email)) {
                return "Utilizador ja existe!";
            }
            
            boolean registado = utilizadorRepo.registarUtilizador(email, password);
            
            if (registado) {
                System.out.println("Utilizador registado no Kerberos: " + email);
                return "Utilizador registado com sucesso!";
            } else {
                return "Erro ao registar utilizador!";
            }
            
        } catch (SQLException e) {
            System.err.println("Erro ao registar utilizador: " + e.getMessage());
            return "Erro: " + e.getMessage();
        }
    }
}