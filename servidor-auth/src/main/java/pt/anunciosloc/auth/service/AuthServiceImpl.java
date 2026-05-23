package pt.anunciosloc.auth.service;

import jakarta.jws.WebService;
import pt.anunciosloc.auth.model.LoginResponse;
import pt.anunciosloc.auth.repository.UtilizadorAuthRepository;
import pt.anunciosloc.auth.repository.TicketRepository;
import pt.anunciosloc.auth.security.JwtUtil;
import java.sql.SQLException;

@WebService(endpointInterface = "pt.anunciosloc.auth.service.AuthService")
public class AuthServiceImpl implements AuthService {
    
    private UtilizadorAuthRepository utilizadorRepo;
    private TicketRepository ticketRepo;
    
    public AuthServiceImpl() {
        this.utilizadorRepo = new UtilizadorAuthRepository();
        this.ticketRepo = new TicketRepository();
        
        System.out.println("=== AUTH SERVICE COM JWT + BCrypt ===");
        System.out.println("Base de dados: anunciosloc");
        System.out.println("======================================");
    }
    
    @Override
    public String ping() {
        return "Auth Service ativo com JWT + BCrypt!";
    }
    
    @Override
    public LoginResponse login(String email, String password) {
        System.out.println("Login solicitado para: " + email);
        
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
            
            System.out.println("Login bem-sucedido: " + email);
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
                System.err.println("Refresh token invalido ou expirado");
                return null;
            }
            
            ticketRepo.marcarRefreshTokenUsado(refreshToken);
            
            System.out.println("Refresh token valido");
            return null;
            
        } catch (SQLException e) {
            System.err.println("Erro ao processar refresh: " + e.getMessage());
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
                return "Utilizador ja existe!";
            }
            
            boolean registado = utilizadorRepo.registarUtilizador(email, password);
            
            if (registado) {
                System.out.println("Utilizador registado: " + email);
                return "Utilizador registado com sucesso!";
            } else {
                return "Erro ao registar utilizador!";
            }
            
        } catch (SQLException e) {
            System.err.println("Erro ao registar: " + e.getMessage());
            return "Erro: " + e.getMessage();
        }
    }
}