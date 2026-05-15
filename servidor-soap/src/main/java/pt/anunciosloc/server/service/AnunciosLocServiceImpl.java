package pt.anunciosloc.server.service;

import jakarta.jws.WebService;
import pt.anunciosloc.server.model.*;
import pt.anunciosloc.server.quorum.QuorumManager;
import java.util.*;
import java.util.stream.Collectors;

@WebService(endpointInterface = "pt.anunciosloc.server.service.AnunciosLocService")
public class AnunciosLocServiceImpl implements AnunciosLocService {
    
    private Map<String, Utilizador> utilizadores = new HashMap<>();
    private List<Anuncio> anuncios = new ArrayList<>();
    private List<Infraestrutura> infraestruturas = new ArrayList<>();
    private QuorumManager quorumManager;
    
    public AnunciosLocServiceImpl() {
        List<String> urls = Arrays.asList("http://localhost:8081/infra");
        this.quorumManager = new QuorumManager(urls);
        
        infraestruturas.add(new Infraestrutura("Belas Shopping", -8.98, 13.18, 100, "http://localhost:8081/infra"));
        
        Utilizador admin = new Utilizador("admin@anunciosloc.com", "admin123", "Administrador");
        admin.setSaldo(1000);
        utilizadores.put("admin@anunciosloc.com", admin);
        
        System.out.println("=== SERVIDOR INICIADO ===");
        System.out.println("Admin: admin@anunciosloc.com / admin123");
        System.out.println("========================");
    }
    
    private void registarNoKerberos(String email, String password) {
        try {
            java.net.http.HttpClient client = java.net.http.HttpClient.newHttpClient();
            String soapRequest = "<?xml version='1.0' encoding='utf-8'?>" +
                "<soap:Envelope xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/' " +
                "xmlns:ns='http://service.auth.anunciosloc.pt/'>" +
                "<soap:Body><ns:registarUtilizador>" +
                "<email>" + email + "</email>" +
                "<password>" + password + "</password>" +
                "</ns:registarUtilizador></soap:Body></soap:Envelope>";
            
            java.net.http.HttpRequest request = java.net.http.HttpRequest.newBuilder()
                .uri(java.net.URI.create("http://localhost:8085/auth"))
                .header("Content-Type", "text/xml")
                .POST(java.net.http.HttpRequest.BodyPublishers.ofString(soapRequest))
                .build();
            
            client.send(request, java.net.http.HttpResponse.BodyHandlers.ofString());
            System.out.println("✅ Utilizador registado no Kerberos: " + email);
        } catch (Exception e) {
            System.err.println("⚠️ Erro ao registar no Kerberos: " + e.getMessage());
        }
    }
    
    @Override
    public String ping() {
        return "Servidor AnunciosLoc ativo!";
    }
    
    @Override
    public String ativarUtilizador(String email, String password, String nome) {
        if (utilizadores.containsKey(email)) {
            return "Erro: Utilizador já existe: " + email;
        }
        
        if (email == null || email.isEmpty()) return "Erro: Email é obrigatório!";
        if (password == null || password.length() < 4) return "Erro: Password deve ter pelo menos 4 caracteres!";
        if (nome == null || nome.isEmpty()) return "Erro: Nome é obrigatório!";
        
        Utilizador novo = new Utilizador(email, password, nome);
        novo.setSaldo(10);
        utilizadores.put(email, novo);
        quorumManager.escreverSaldo(email, 10);
        
        registarNoKerberos(email, password);
        
        return "✅ Utilizador registado com sucesso!\nEmail: " + email + "\nNome: " + nome + "\nSaldo: 10 pontos";
    }
    
    @Override
    public int consultarSaldo(String email) {
        Utilizador u = utilizadores.get(email);
        if (u == null || !u.isAtivo()) throw new RuntimeException("Utilizador não encontrado: " + email);
        return u.getSaldo();
    }
    
    @Override
    public String atualizarSaldo(String email, int novoSaldo) {
        Utilizador u = utilizadores.get(email);
        if (u == null || !u.isAtivo()) throw new RuntimeException("Utilizador não encontrado: " + email);
        u.setSaldo(novoSaldo);
        quorumManager.escreverSaldo(email, novoSaldo);
        return "Saldo atualizado para " + novoSaldo;
    }
    
    @Override
    public String eliminarUtilizador(String email) {
        Utilizador removido = utilizadores.remove(email);
        if (removido != null) {
            anuncios.removeIf(a -> a.getAutorEmail().equals(email));
            return "Utilizador " + email + " eliminado!";
        }
        return "Utilizador não encontrado: " + email;
    }
    
    @Override
    public String editarUtilizador(String email, String novoEmail, String novoNome) {
        Utilizador u = utilizadores.get(email);
        if (u == null || !u.isAtivo()) return "Utilizador não encontrado: " + email;
        
        if (novoEmail != null && !novoEmail.isEmpty() && !novoEmail.equals(email)) {
            if (utilizadores.containsKey(novoEmail)) return "Erro: Email " + novoEmail + " já em uso!";
            utilizadores.remove(email);
            u.setEmail(novoEmail);
            utilizadores.put(novoEmail, u);
            for (Anuncio a : anuncios) if (a.getAutorEmail().equals(email)) a.setAutorEmail(novoEmail);
        }
        if (novoNome != null && !novoNome.isEmpty()) u.setNome(novoNome);
        
        return "Utilizador atualizado!\nEmail: " + u.getEmail() + "\nNome: " + u.getNome();
    }
    
    @Override
    public String[] listarUtilizadores() {
        return utilizadores.values().stream()
                .filter(Utilizador::isAtivo)
                .map(u -> u.getEmail() + " | " + u.getNome() + " | Saldo: " + u.getSaldo())
                .toArray(String[]::new);
    }
    
    @Override
    public String alterarPassword(String email, String passwordAntiga, String passwordNova) {
        Utilizador u = utilizadores.get(email);
        if (u == null || !u.isAtivo()) return "Utilizador não encontrado: " + email;
        if (u.getPassword() != null && !u.getPassword().equals(passwordAntiga)) return "Password antiga incorreta!";
        if (passwordNova == null || passwordNova.length() < 4) return "Nova password deve ter pelo menos 4 caracteres!";
        u.setPassword(passwordNova);
        return "Password alterada com sucesso!";
    }
    
    @Override
    public String desativarConta(String email) {
        Utilizador u = utilizadores.get(email);
        if (u == null) return "Utilizador não encontrado: " + email;
        if (!u.isAtivo()) return "Conta já está desativada!";
        u.setAtivo(false);
        return "Conta de " + email + " foi desativada.";
    }
    
    @Override
    public String reativarConta(String email) {
        Utilizador u = utilizadores.get(email);
        if (u == null) return "Utilizador não encontrado: " + email;
        if (u.isAtivo()) return "Conta já está ativa!";
        u.setAtivo(true);
        return "Conta de " + email + " foi reativada!";
    }
    
    @Override
    public Utilizador obterUtilizador(String email) {
        Utilizador u = utilizadores.get(email);
        if (u == null || !u.isAtivo()) throw new RuntimeException("Utilizador não encontrado: " + email);
        Utilizador copia = new Utilizador(u.getEmail());
        copia.setNome(u.getNome());
        copia.setSaldo(u.getSaldo());
        copia.setDataRegisto(u.getDataRegisto());
        copia.setUltimoAnuncio(u.getUltimoAnuncio());
        return copia;
    }
    
    @Override
    public String postarMensagem(String email, String conteudo, String local) {
        Utilizador u = utilizadores.get(email);
        if (u == null || !u.isAtivo()) throw new RuntimeException("Utilizador não encontrado: " + email);
        Anuncio anuncio = new Anuncio(conteudo, email, local);
        anuncios.add(anuncio);
        u.setUltimoAnuncio(java.time.LocalDateTime.now());
        return "Anúncio publicado! ID: " + anuncio.getId();
    }
    
    @Override
    public String[] receberMensagens(String email, String local) {
        Utilizador u = utilizadores.get(email);
        if (u == null || !u.isAtivo()) throw new RuntimeException("Utilizador não encontrado: " + email);
        return anuncios.stream()
                .filter(a -> a.getLocal().equalsIgnoreCase(local))
                .map(a -> "[" + a.getDataCriacao() + "] " + a.getConteudo())
                .toArray(String[]::new);
    }
    
    @Override
    public Infraestrutura[] listarInfraestruturas() {
        return infraestruturas.toArray(new Infraestrutura[0]);
    }
    
    @Override
    public Infraestrutura obterInfoInfraestrutura(String nome) {
        return infraestruturas.stream()
                .filter(i -> i.getNome().equalsIgnoreCase(nome))
                .findFirst()
                .orElse(null);
    }
    
    @Override
    public String getQuorumStatus() {
        return quorumManager.getStatus();
    }
}