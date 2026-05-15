package pt.anunciosloc.auth.service;

import jakarta.jws.WebService;
import pt.anunciosloc.shared.Ticket;
import java.util.*;
import java.security.MessageDigest;
import java.util.concurrent.ConcurrentHashMap;

@WebService(endpointInterface = "pt.anunciosloc.auth.service.AuthService")
public class AuthServiceImpl implements AuthService {
    
    private Map<String, String> utilizadores;
    private Map<String, Ticket> tickets;
    
    public AuthServiceImpl() {
        this.utilizadores = new HashMap<>();
        this.tickets = new ConcurrentHashMap<>();
        
        System.out.println("=== KERBEROS AUTHENTICATION SERVICE ===");
        System.out.println("Base de dados vazia. Registar utilizadores primeiro!");
        System.out.println("========================================");
    }
    
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            return password;
        }
    }
    
    private String gerarChaveSessao() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 32);
    }
    
    @Override
    public String ping() {
        return "Kerberos AS ativo! Utilizadores: " + utilizadores.size();
    }
    
    @Override
    public Ticket solicitarTicket(String email, String password) {
        System.out.println("📝 Login solicitado para: " + email);
        
        String hashSenha = hashPassword(password);
        
        if (!utilizadores.containsKey(email)) {
            System.err.println("❌ Utilizador não encontrado: " + email);
            throw new RuntimeException("Utilizador não registado: " + email);
        }
        
        if (!utilizadores.get(email).equals(hashSenha)) {
            System.err.println("❌ Password incorreta para: " + email);
            throw new RuntimeException("Password incorreta");
        }
        
        String chaveSessao = gerarChaveSessao();
        Ticket ticket = new Ticket(email, chaveSessao, 3600);
        tickets.put(ticket.getTicketId(), ticket);
        
        System.out.println("✅ Login bem-sucedido: " + email);
        return ticket;
    }
    
    @Override
    public boolean validarTicket(String ticketId, String email) {
        Ticket ticket = tickets.get(ticketId);
        if (ticket == null) return false;
        if (!ticket.isValid()) {
            tickets.remove(ticketId);
            return false;
        }
        return ticket.getClienteEmail().equals(email);
    }
    
    @Override
    public boolean invalidarTicket(String ticketId) {
        Ticket removed = tickets.remove(ticketId);
        return removed != null;
    }
    
    // Método para registar utilizador (chamado pelo servidor principal)
  
    @Override
public String registarUtilizador(String email, String password) {
    if (!utilizadores.containsKey(email)) {
        utilizadores.put(email, hashPassword(password));
        System.out.println("✅ Utilizador registado manualmente no Kerberos: " + email);
        return "Utilizador registado com sucesso!";
    }
    return "Utilizador já existe!";
}
}