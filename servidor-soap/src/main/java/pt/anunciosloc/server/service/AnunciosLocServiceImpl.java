package pt.anunciosloc.server.service;

import jakarta.jws.WebService;
import pt.anunciosloc.server.config.ConnectionFactory;
import pt.anunciosloc.server.model.*;
import pt.anunciosloc.server.quorum.QuorumManager;
import pt.anunciosloc.server.repository.UtilizadorRepository;
import pt.anunciosloc.shared.Restricao;
import pt.anunciosloc.server.repository.AnuncioRepository;
import pt.anunciosloc.server.repository.InfraestruturaRepository;
import pt.anunciosloc.server.repository.PerfilUtilizadorRepository;
import pt.anunciosloc.server.repository.RestricaoRepository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.*;

@WebService(endpointInterface = "pt.anunciosloc.server.service.AnunciosLocService")
public class AnunciosLocServiceImpl implements AnunciosLocService {

    private UtilizadorRepository utilizadorRepo;
    private AnuncioRepository anuncioRepo;
    private InfraestruturaRepository infraRepo;
    private QuorumManager quorumManager;

    public AnunciosLocServiceImpl() {
        this.utilizadorRepo = new UtilizadorRepository();
        this.anuncioRepo = new AnuncioRepository();
        this.infraRepo = new InfraestruturaRepository();

        List<String> urls = Arrays.asList("http://localhost:8081/infra");
        this.quorumManager = new QuorumManager(urls);

        System.out.println("=== SERVIDOR INICIADO COM MYSQL ===");
        System.out.println("Base de dados: anunciosloc");
        System.out.println("================================");
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
            System.out.println("Utilizador registado no Kerberos: " + email);
        } catch (Exception e) {
            System.err.println("Erro ao registar no Kerberos: " + e.getMessage());
        }
    }

    @Override
    public String ping() {
        return "Servidor AnunciosLoc ativo com MySQL!";
    }

    @Override
    public String ativarUtilizador(String email, String password, String nome) {
        try {
            if (utilizadorRepo.existe(email)) {
                return "Erro: Utilizador ja existe: " + email;
            }

            if (email == null || email.isEmpty())
                return "Erro: Email e obrigatorio!";
            if (password == null || password.length() < 4)
                return "Erro: Password deve ter pelo menos 4 caracteres!";
            if (nome == null || nome.isEmpty())
                return "Erro: Nome e obrigatorio!";

            Utilizador novo = new Utilizador(email, password, nome);
            novo.setSaldo(10.0);
            utilizadorRepo.salvar(novo);
            quorumManager.escreverSaldo(email, 10);

            registarNoKerberos(email, password);

            return "Utilizador registado com sucesso!\nEmail: " + email + "\nNome: " + nome + "\nSaldo: 10 pontos";
        } catch (SQLException e) {
            return "Erro ao registar: " + e.getMessage();
        }
    }

    @Override
    public int consultarSaldo(String email) {
        try {
            Utilizador u = utilizadorRepo.buscarPorEmail(email);
            if (u == null || !u.isAtivo())
                throw new RuntimeException("Utilizador nao encontrado: " + email);
            return (int) u.getSaldo();
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao consultar saldo: " + e.getMessage());
        }
    }

    @Override
    public String atualizarSaldo(String email, int novoSaldo) {
        try {
            Utilizador u = utilizadorRepo.buscarPorEmail(email);
            if (u == null || !u.isAtivo())
                return "Utilizador nao encontrado: " + email;

            utilizadorRepo.atualizarSaldo(email, (double) novoSaldo);
            quorumManager.escreverSaldo(email, novoSaldo);
            return "Saldo atualizado para " + novoSaldo;
        } catch (SQLException e) {
            return "Erro ao atualizar saldo: " + e.getMessage();
        }
    }

    @Override
    public String eliminarUtilizador(String email) {
        try {
            utilizadorRepo.eliminar(email);
            return "Utilizador " + email + " eliminado!";
        } catch (SQLException e) {
            return "Erro ao eliminar: " + e.getMessage();
        }
    }

    @Override
    public String editarUtilizador(String email, String novoEmail, String novoNome) {
        return "Funcionalidade em implementacao com MySQL";
    }

    @Override
    public String[] listarUtilizadores() {
        try {
            List<Utilizador> utilizadores = utilizadorRepo.listarTodos();
            return utilizadores.stream()
                    .filter(u -> u.isAtivo())
                    .map(u -> u.getEmail() + " | " + u.getNome() + " | Saldo: " + (int) u.getSaldo())
                    .toArray(String[]::new);
        } catch (SQLException e) {
            return new String[] { "Erro ao listar: " + e.getMessage() };
        }
    }

    @Override
    public String alterarPassword(String email, String passwordAntiga, String passwordNova) {
        return "Funcionalidade em implementacao com MySQL";
    }

    @Override
    public String desativarConta(String email) {
        try {
            utilizadorRepo.desativar(email);
            return "Conta de " + email + " foi desativada.";
        } catch (SQLException e) {
            return "Erro ao desativar: " + e.getMessage();
        }
    }

    @Override
    public String reativarConta(String email) {
        try {
            utilizadorRepo.reativar(email);
            return "Conta de " + email + " foi reativada!";
        } catch (SQLException e) {
            return "Erro ao reativar: " + e.getMessage();
        }
    }

    @Override
    public Utilizador obterUtilizador(String email) {
        try {
            return utilizadorRepo.buscarPorEmail(email);
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao obter utilizador: " + e.getMessage());
        }
    }

    @Override
    public String postarMensagem(String email, String conteudo, String local) {
        try {
            Utilizador u = utilizadorRepo.buscarPorEmail(email);
            if (u == null || !u.isAtivo())
                return "Utilizador nao encontrado: " + email;

            // Verificar saldo
            if (u.getSaldo() < 5.0) {
                return "Saldo insuficiente. Precisa de 5 pontos para publicar.";
            }

            // Verificar tempo desde o ultimo anuncio
            if (!u.podePublicarAnuncio()) {
                return "Aguarde 5 minutos para publicar outro anuncio.";
            }

            // Debitar saldo
            boolean debitado = utilizadorRepo.debitarSaldo(email, 5.0);
            if (!debitado) {
                return "Erro ao debitar saldo.";
            }

            // Criar e salvar anuncio
            Anuncio anuncio = new Anuncio(conteudo, email, local);
            anuncioRepo.salvar(anuncio);

            // Atualizar ultimo anuncio
            utilizadorRepo.atualizarUltimoAnuncio(email, LocalDateTime.now());

            // Atualizar estatisticas
            utilizadorRepo.atualizarEstatisticas(email, u.getTotalAnunciosPublicados() + 1,
                    u.getTotalVisualizacoesRecebidas());

            // Atualizar quorum
            quorumManager.escreverSaldo(email, (int) (u.getSaldo() - 5.0));

            return "Anuncio publicado! ID: " + anuncio.getId();
        } catch (SQLException e) {
            return "Erro ao publicar: " + e.getMessage();
        }
    }

    @Override
    public String[] receberMensagens(String email, String local) {
        try {
            Utilizador u = utilizadorRepo.buscarPorEmail(email);
            if (u == null || !u.isAtivo())
                return new String[] { "Utilizador nao encontrado: " + email };

            List<Anuncio> anuncios = anuncioRepo.buscarPorLocal(local);
            return anuncios.stream()
                    .map(a -> "[" + a.getDataCriacao() + "] " + a.getConteudo())
                    .toArray(String[]::new);
        } catch (SQLException e) {
            return new String[] { "Erro ao receber mensagens: " + e.getMessage() };
        }
    }

    @Override
    public Infraestrutura[] listarInfraestruturas() {
        try {
            List<Infraestrutura> infraList = infraRepo.listarTodas();
            return infraList.toArray(new Infraestrutura[0]);
        } catch (SQLException e) {
            return new Infraestrutura[0];
        }
    }

    @Override
    public Infraestrutura obterInfoInfraestrutura(String nome) {
        try {
            return infraRepo.buscarPorNome(nome);
        } catch (SQLException e) {
            return null;
        }
    }

    @Override
    public String getQuorumStatus() {
        return quorumManager.getStatus();
    }

    @Override
    public String criarInfraestrutura(String nome, String localizacao, double latitude, double longitude,
            int capacidade, String url, String criadorEmail) {
        try {
            Infraestrutura infra = new Infraestrutura(nome, latitude, longitude, capacidade, url, criadorEmail);
            infra.setLocalizacao(localizacao);
            infraRepo.salvar(infra);
            return "Infraestrutura criada com sucesso: " + nome;
        } catch (SQLException e) {
            return "Erro ao criar: " + e.getMessage();
        }
    }

    @Override
    public String editarInfraestrutura(String nome, String novoNome, String localizacao,
            double latitude, double longitude, int capacidade, String url) {
        return "Funcionalidade em implementacao";
    }

    @Override
    public String eliminarInfraestrutura(String nome) {
        try {
            infraRepo.eliminar(nome);
            return "Infraestrutura eliminada!";
        } catch (SQLException e) {
            return "Erro ao eliminar: " + e.getMessage();
        }
    }

    @Override
    public String ativarInfraestrutura(String nome) {
        try {
            infraRepo.ativar(nome);
            return "Infraestrutura ativada!";
        } catch (SQLException e) {
            return "Erro ao ativar: " + e.getMessage();
        }
    }

    @Override
    public String desativarInfraestrutura(String nome) {
        try {
            infraRepo.desativar(nome);
            return "Infraestrutura desativada!";
        } catch (SQLException e) {
            return "Erro ao desativar: " + e.getMessage();
        }
    }

    @Override
    public String incrementarUtilizadores(String nome) {
        return "Funcionalidade em implementacao";
    }

    @Override
    public String decrementarUtilizadores(String nome) {
        return "Funcionalidade em implementacao";
    }

    @Override
    public String incrementarAnuncios(String nome) {
        return "Funcionalidade em implementacao";
    }

    @Override
    public String incrementarEntregas(String nome) {
        return "Funcionalidade em implementacao";
    }

    @Override
    public String[] listarAnuncios() {
        try {
            List<Anuncio> anuncios = anuncioRepo.listarTodos();
            return anuncios.stream()
                    .map(a -> "[" + a.getDataCriacao() + "] " +
                            a.getAutorEmail() + ": " +
                            a.getConteudo() +
                            " (" + a.getLocal() + ")")
                    .toArray(String[]::new);
        } catch (SQLException e) {
            return new String[] { "Erro ao listar anuncios: " + e.getMessage() };
        }
    }

    @Override
    public String[] listarAnunciosPorUtilizador(String email) {
        try {
            List<Anuncio> anuncios = anuncioRepo.buscarPorAutor(email);
            return anuncios.stream()
                    .map(a -> "[" + a.getDataCriacao() + "] " +
                            a.getConteudo() +
                            " (" + a.getLocal() + ")")
                    .toArray(String[]::new);
        } catch (SQLException e) {
            return new String[] { "Erro ao listar anuncios: " + e.getMessage() };
        }
    }

    @Override
    public String[] listarLocaisCoordenadas() {
        try {
            String sql = "SELECT l.id, l.nome, l.tipo, l.latitude, l.longitude, l.raio, l.wifi_ssid, " +
                    "i.nome as nome_infraestrutura " +
                    "FROM locais l " +
                    "LEFT JOIN infraestruturas i ON l.infraestrutura_id = i.id";

            List<String> result = new ArrayList<>();

            try (Connection conn = ConnectionFactory.getConnection();
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {
                    String nomeLocal = rs.getString("nome");
                    String tipo = rs.getString("tipo");
                    double latitude = rs.getDouble("latitude");
                    double longitude = rs.getDouble("longitude");
                    double raio = rs.getDouble("raio");
                    String wifiSsid = rs.getString("wifi_ssid");
                    String nomeInfraestrutura = rs.getString("nome_infraestrutura");

                    String data;
                    if ("GPS".equals(tipo)) {
                        data = nomeLocal + "|" +
                                tipo + "|" +
                                latitude + "|" +
                                longitude + "|" +
                                raio + "|" +
                                (nomeInfraestrutura != null ? nomeInfraestrutura : "Sem infraestrutura");
                    } else {
                        data = nomeLocal + "|" +
                                tipo + "|" +
                                (wifiSsid != null ? wifiSsid : "N/A") + "|" +
                                (nomeInfraestrutura != null ? nomeInfraestrutura : "Sem infraestrutura");
                    }
                    result.add(data);
                }
            }

            return result.toArray(new String[0]);
        } catch (SQLException e) {
            System.err.println("Erro ao listar locais coordenadas: " + e.getMessage());
            return new String[0];
        }
    }

    @Override
    public String salvarPreferencia(String email, String chave, String valor) {
        try {
            Utilizador u = utilizadorRepo.buscarPorEmail(email);
            if (u == null)
                return "Utilizador nao encontrado";

            PerfilUtilizadorRepository perfilRepo = new PerfilUtilizadorRepository();
            perfilRepo.salvarPerfil(u.getId(), chave, valor);
            return "Preferencia salva com sucesso";
        } catch (SQLException e) {
            return "Erro ao salvar preferencia: " + e.getMessage();
        }
    }

    @Override
    public String obterPreferencia(String email, String chave) {
        try {
            Utilizador u = utilizadorRepo.buscarPorEmail(email);
            if (u == null)
                return "";

            PerfilUtilizadorRepository perfilRepo = new PerfilUtilizadorRepository();
            String valor = perfilRepo.obterPreferencia(u.getId(), chave);
            return valor != null ? valor : "";
        } catch (SQLException e) {
            return "";
        }
    }

    @Override
    public String[] obterPerfilUtilizador(String email) {
        try {
            Utilizador u = utilizadorRepo.buscarPorEmail(email);
            if (u == null)
                return new String[0];

            PerfilUtilizadorRepository perfilRepo = new PerfilUtilizadorRepository();
            Map<String, String> perfil = perfilRepo.obterPerfil(u.getId());

            List<String> result = new ArrayList<>();
            for (Map.Entry<String, String> entry : perfil.entrySet()) {
                result.add(entry.getKey() + "|" + entry.getValue());
            }
            return result.toArray(new String[0]);
        } catch (SQLException e) {
            return new String[0];
        }
    }

    @Override
    public String removerPreferencia(String email, String chave) {
        try {
            Utilizador u = utilizadorRepo.buscarPorEmail(email);
            if (u == null)
                return "Utilizador nao encontrado";

            PerfilUtilizadorRepository perfilRepo = new PerfilUtilizadorRepository();
            perfilRepo.removerPreferencia(u.getId(), chave);
            return "Preferencia removida com sucesso";
        } catch (SQLException e) {
            return "Erro ao remover preferencia: " + e.getMessage();
        }
    }

    @Override
    public String adicionarRestricao(String anuncioId, String tipo, String chave, String valor) {
        // VALIDACAO: Verificar se anuncioId e valido
        if (anuncioId == null || anuncioId.trim().isEmpty()) {
            return "Erro: ID do anuncio nao pode ser vazio";
        }

        try {
            Long id = Long.parseLong(anuncioId);
            Restricao restricao = new Restricao(id, tipo, chave, valor);
            RestricaoRepository repo = new RestricaoRepository();
            repo.salvarRestricao(restricao);
            return "Restricao adicionada com sucesso";
        } catch (NumberFormatException e) {
            return "Erro: ID do anuncio invalido: " + anuncioId;
        } catch (SQLException e) {
            return "Erro ao adicionar restricao: " + e.getMessage();
        }
    }

    @Override
    public String[] listarRestricoes(String anuncioId) {
        try {
            Long id = Long.parseLong(anuncioId);
            RestricaoRepository repo = new RestricaoRepository();
            List<Restricao> restricoes = repo.listarPorAnuncio(id);

            return restricoes.stream()
                    .map(r -> r.getTipo() + "|" + r.getChave() + "|" + r.getValor())
                    .toArray(String[]::new);
        } catch (SQLException e) {
            return new String[0];
        }
    }

    @Override
    public String[] receberAnunciosDeOutros(String email, String local) {
        System.out.println("=== RECEBER ANUNCIOS DE OUTROS ===");
        System.out.println("Email: " + email);
        System.out.println("Local: " + local);

        try {
            // 1. Verificar se o utilizador existe
            Utilizador u = utilizadorRepo.buscarPorEmail(email);
            if (u == null || !u.isAtivo()) {
                return new String[] { "Utilizador nao encontrado: " + email };
            }

            // 2. Buscar perfil do utilizador (para filtrar por restricoes)
            Map<String, String> perfil = obterPerfilUtilizadorMap(email);
            System.out.println("Perfil do utilizador: " + perfil);

            // 3. Buscar todos os anuncios ativos do local
            List<Anuncio> todosAnuncios = anuncioRepo.buscarPorLocalAtivo(local);
            System.out.println("Total de anuncios no local: " + todosAnuncios.size());

            // 4. Filtrar anuncios (excluir proprios, aplicar restricoes)
            List<String> anunciosVisiveis = new ArrayList<>();
            RestricaoRepository restricaoRepo = new RestricaoRepository();

            for (Anuncio anuncio : todosAnuncios) {
                // Nao mostrar os proprios anuncios
                if (anuncio.getAutorEmail().equals(email)) {
                    System.out.println("Ignorando anuncio proprio: " + anuncio.getAutorEmail());
                    continue;
                }

                // Verificar se o anuncio ainda esta ativo
                if (!anuncio.isActivo()) {
                    System.out.println("Anuncio inativo: " + anuncio.getId());
                    continue;
                }

                // Verificar se o anuncio nao expirou
                if (anuncio.isExpirado()) {
                    System.out.println("Anuncio expirado: " + anuncio.getId());
                    continue;
                }

                // Buscar ID do anuncio no banco
                Long anuncioId = obterAnuncioIdPorUUID(anuncio.getId());

                // Buscar restricoes do anuncio
                List<Restricao> restricoes = restricaoRepo.listarPorAnuncio(anuncioId);

                // Verificar se o utilizador satisfaz as restricoes
                if (satisfazRestricoes(perfil, restricoes)) {
                    String mensagem = formatarAnuncioParaExibicao(anuncio);
                    anunciosVisiveis.add(mensagem);

                    // Registrar visualizacao
                    anuncioRepo.incrementarVisualizacao(anuncio.getId());
                    System.out.println("Anuncio visivel para o utilizador: " + anuncio.getId());
                } else {
                    System.out.println("Anuncio bloqueado por restricoes: " + anuncio.getId());
                }
            }

            System.out.println("Total de anuncios visiveis: " + anunciosVisiveis.size());
            return anunciosVisiveis.toArray(new String[0]);

        } catch (SQLException e) {
            System.err.println("Erro ao receber anuncios: " + e.getMessage());
            return new String[] { "Erro: " + e.getMessage() };
        }
    }

    // Metodo auxiliar para obter perfil do utilizador
    private Map<String, String> obterPerfilUtilizadorMap(String email) throws SQLException {
        Utilizador u = utilizadorRepo.buscarPorEmail(email);
        if (u == null)
            return new HashMap<>();

        PerfilUtilizadorRepository perfilRepo = new PerfilUtilizadorRepository();
        return perfilRepo.obterPerfil(u.getId());
    }

    // Metodo auxiliar para verificar restricoes
    private boolean satisfazRestricoes(Map<String, String> perfil, List<Restricao> restricoes) {
        if (restricoes.isEmpty()) {
            return true; // Sem restricoes, todos veem
        }

        for (Restricao r : restricoes) {
            String valorPerfil = perfil.getOrDefault(r.getChave(), "");

            if (r.getTipo().equals("WHITELIST")) {
                // WHITELIST: so permite se o perfil tem exatamente a chave=valor
                if (!valorPerfil.equals(r.getValor())) {
                    return false;
                }
            } else if (r.getTipo().equals("BLACKLIST")) {
                // BLACKLIST: bloqueia se o perfil tem a chave=valor
                if (valorPerfil.equals(r.getValor())) {
                    return false;
                }
            }
        }
        return true;
    }

    // Metodo auxiliar para obter ID do anuncio pelo UUID
    private Long obterAnuncioIdPorUUID(String uuid) throws SQLException {
        String sql = "SELECT id FROM anuncios WHERE id = ?";
        try (Connection conn = ConnectionFactory.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, uuid);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getLong("id");
            }
            return null;
        }
    }

    // Metodo auxiliar para formatar anuncio
    private String formatarAnuncioParaExibicao(Anuncio anuncio) {
        return "[" + anuncio.getDataCriacao() + "] " +
                "De: " + anuncio.getAutorEmail() + "\n" +
                anuncio.getDescricao() + "\n" +
                "Local: " + anuncio.getLocal();
    }

    @Override
public String postarMensagemCompleta(String email, String titulo, String descricao, String local, int diasValidade) {
    try {
        // 1. Validar utilizador
        Utilizador u = utilizadorRepo.buscarPorEmail(email);
        if (u == null || !u.isAtivo()) {
            return "Erro: Utilizador nao encontrado ou conta desativada: " + email;
        }
        
        // 2. Validar titulo
        if (titulo == null || titulo.trim().isEmpty()) {
            return "Erro: Titulo do anuncio e obrigatorio!";
        }
        if (titulo.length() > 100) {
            return "Erro: Titulo excede 100 caracteres!";
        }
        
        // 3. Validar descricao
        if (descricao == null || descricao.trim().isEmpty()) {
            return "Erro: Descricao do anuncio e obrigatoria!";
        }
        if (descricao.length() > 1000) {
            return "Erro: Descricao excede 1000 caracteres!";
        }
        
        // 4. Validar local
        if (local == null || local.trim().isEmpty()) {
            return "Erro: Local do anuncio e obrigatorio!";
        }
        
        // 5. Validar dias de validade
        if (diasValidade < 1 || diasValidade > 365) {
            return "Erro: Dias de validade invalido! (1 a 365)";
        }
        
        // 6. Verificar saldo (custa 5 pontos)
        if (u.getSaldo() < 5.0) {
            return "Erro: Saldo insuficiente! Necessario 5 pontos para publicar. Seu saldo: " + (int) u.getSaldo();
        }
        
        // 7. Verificar tempo desde o ultimo anuncio (minimo 5 minutos)
        if (!u.podePublicarAnuncio()) {
            return "Erro: Aguarde 5 minutos para publicar outro anuncio.";
        }
        
        // 8. Verificar se o local existe
        Infraestrutura infra = infraRepo.buscarPorNome(local);
        if (infra == null) {
            return "Erro: Local '" + local + "' nao encontrado!";
        }
        
        // 9. Debitar saldo
        boolean debitado = utilizadorRepo.debitarSaldo(email, 5.0);
        if (!debitado) {
            return "Erro: Falha ao debitar saldo.";
        }
        
        // 10. Criar e salvar anuncio
        Anuncio anuncio = new Anuncio(titulo, descricao, email, local);
        anuncio.setDataExpiracao(java.time.LocalDateTime.now().plusDays(diasValidade));
        anuncio.setTotalVisualizacoes(0);
        anuncio.setActivo(true);
        
        anuncioRepo.salvar(anuncio);
        
        // 11. Atualizar estatisticas do utilizador
        utilizadorRepo.atualizarUltimoAnuncio(email, java.time.LocalDateTime.now());
        utilizadorRepo.atualizarEstatisticas(email, u.getTotalAnunciosPublicados() + 1, u.getTotalVisualizacoesRecebidas());
        
        // 12. Atualizar quorum
        quorumManager.escreverSaldo(email, (int) (u.getSaldo() - 5.0));
        
        // 13. Atualizar estatisticas da infraestrutura
        infra.setTotalAnuncios(infra.getTotalAnuncios() + 1);
        //infraRepo.atualizar(infra);
        
        return "Anuncio publicado com sucesso! ID: " + anuncio.getId() + 
               "\nTitulo: " + titulo +
               "\nLocal: " + local +
               "\nValidade: " + diasValidade + " dias" +
               "\nSaldo restante: " + (int) (u.getSaldo() - 5.0);
        
    } catch (SQLException e) {
        return "Erro ao publicar anuncio: " + e.getMessage();
    }
}

}
