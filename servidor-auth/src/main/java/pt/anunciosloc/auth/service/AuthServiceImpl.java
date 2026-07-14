package pt.anunciosloc.auth.service;

import jakarta.jws.WebService;
import pt.anunciosloc.auth.config.ConnectionFactory;
import pt.anunciosloc.auth.model.LoginResponse;
import pt.anunciosloc.auth.repository.UtilizadorAuthRepository;
import pt.anunciosloc.auth.repository.TicketRepository;
import pt.anunciosloc.auth.security.JwtUtil;
import pt.anunciosloc.shared.Ticket;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;

@WebService(endpointInterface = "pt.anunciosloc.auth.service.AuthService")
public class AuthServiceImpl implements AuthService {
    
    private UtilizadorAuthRepository utilizadorRepo;
    private TicketRepository ticketRepo;
    private Map<String, Ticket> adminTickets = new ConcurrentHashMap<>();
    
    public AuthServiceImpl() {
        this.utilizadorRepo = new UtilizadorAuthRepository();
        this.ticketRepo = new TicketRepository();
        
        // Testar conexão ao iniciar
        try {
            Connection conn = ConnectionFactory.getConnection();
            System.out.println("✅ Conexão MySQL estabelecida com sucesso!");
            ConnectionFactory.closeConnection(conn);
        } catch (SQLException e) {
            System.err.println("❌ ERRO CRÍTICO: Não foi possível conectar ao MySQL");
            System.err.println("   Mensagem: " + e.getMessage());
            System.err.println("   Verifique se o MySQL está rodando no XAMPP");
        }
        
        System.out.println("=== AUTH SERVICE COM JWT + BD ===");
        System.out.println("Base de dados: anunciosloc");
        System.out.println("=============================");
    }
    
    @Override
    public String ping() {
        return "Auth Service ativo com JWT + BD";
    }
    
    @Override
    public LoginResponse login(String email, String password) {
        System.out.println("Login JWT solicitado para: " + email);
        
        try {
            if (!utilizadorRepo.verificarCredenciais(email, password)) {
                System.err.println("Credenciais invalidas para: " + email);
                return null;
            }
            
            int userId = utilizadorRepo.getUserIdByEmail(email);
            double saldo = utilizadorRepo.getSaldoByEmail(email);
            
            String accessToken = JwtUtil.generateToken(email, userId);
            String refreshToken = ticketRepo.criarRefreshToken(userId);
            
            utilizadorRepo.atualizarUltimoLogin(email);
            
            System.out.println("Login JWT bem-sucedido: " + email);
            return new LoginResponse(accessToken, refreshToken, email, saldo);
            
        } catch (SQLException e) {
            System.err.println("Erro ao fazer login: " + e.getMessage());
            return null;
        }
    }
    
    @Override
    public LoginResponse refreshToken(String refreshToken) {
        System.out.println("Refresh token solicitado");
        
        try {
            if (!ticketRepo.validarRefreshToken(refreshToken)) {
                System.err.println("Refresh token invalido");
                return null;
            }
            
            ticketRepo.marcarRefreshTokenUsado(refreshToken);
            
            System.out.println("Refresh token valido");
            return null;
            
        } catch (SQLException e) {
            System.err.println("Erro no refresh: " + e.getMessage());
            return null;
        }
    }
    
    @Override
    public boolean validarToken(String token) {
        return JwtUtil.validateToken(token);
    }
    
    @Override
    public String registarUtilizador(String email, String password) {
        try {
            if (utilizadorRepo.utilizadorExiste(email)) {
                return "Utilizador ja existe";
            }
            
            boolean registado = utilizadorRepo.registarUtilizador(email, password);
            
            if (registado) {
                System.out.println("Utilizador registado: " + email);
                return "Utilizador registado com sucesso";
            }
            return "Erro ao registar";
            
        } catch (SQLException e) {
            System.err.println("Erro ao registar: " + e.getMessage());
            return "Erro: " + e.getMessage();
        }
    }

    // ==================== ADMIN (SOAP) ====================
    
    @Override
    public Ticket solicitarTicketAdmin(String email, String password) {
        System.out.println("Login admin solicitado para: " + email);
        
        try (Connection conn = ConnectionFactory.getConnection()) {
            String sql = "SELECT id, email, password_hash, role FROM administradores WHERE email = ? AND ativo = 1";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    String hash = rs.getString("password_hash");
                    String role = rs.getString("role");
                    
                    System.out.println("Admin encontrado: " + email + " (Role: " + role + ")");
                    
                    // Verificar password (usando SHA-256)
                    String passwordHash = hashPassword(password);
                    if (hash.equals(passwordHash)) {
                        System.out.println("Password correta para: " + email);
                        
                        Ticket ticket = new Ticket();
                        ticket.setTicketId("admin-" + UUID.randomUUID().toString());
                        ticket.setClienteEmail(email);
                        ticket.setValidade(new Date(System.currentTimeMillis() + 7200000));
                        adminTickets.put(ticket.getTicketId(), ticket);
                        
                        System.out.println("Ticket admin gerado para: " + email);
                        return ticket;
                    } else {
                        System.out.println("Password incorreta para: " + email);
                    }
                } else {
                    System.out.println("Admin nao encontrado: " + email);
                }
            }
            
            throw new RuntimeException("Credenciais de administrador invalidas");
            
        } catch (SQLException e) {
            System.err.println("Erro ao verificar admin no banco: " + e.getMessage());
            throw new RuntimeException("Erro ao autenticar administrador: " + e.getMessage());
        }
    }
    
    @Override
    public boolean validarTicketAdmin(String ticketId, String email) {
        Ticket ticket = adminTickets.get(ticketId);
        if (ticket == null) {
            System.err.println("Ticket admin nao encontrado: " + ticketId);
            return false;
        }
        if (ticket.getValidade().before(new Date())) {
            System.err.println("Ticket admin expirado: " + ticketId);
            return false;
        }
        if (!ticket.getClienteEmail().equals(email)) {
            System.err.println("Email nao coincide com o ticket admin");
            return false;
        }
        return true;
    }
    
    // ==================== METODO AUXILIAR ====================
    
    private String hashPassword(String password) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            return java.util.Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            return password;
        }
    }
}