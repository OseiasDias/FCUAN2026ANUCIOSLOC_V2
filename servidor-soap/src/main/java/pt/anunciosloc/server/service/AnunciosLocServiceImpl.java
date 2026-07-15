package pt.anunciosloc.server.service;

import jakarta.jws.WebMethod;
import jakarta.jws.WebParam;
import jakarta.jws.WebService;
import pt.anunciosloc.server.config.ConnectionFactory;
import pt.anunciosloc.server.model.*;
import pt.anunciosloc.server.quorum.QuorumManager;
import pt.anunciosloc.server.repository.UtilizadorRepository;
import pt.anunciosloc.shared.Administrador;
import pt.anunciosloc.shared.Restricao;
import pt.anunciosloc.server.repository.AnuncioRepository;
import pt.anunciosloc.server.repository.InfraestruturaRepository;
import pt.anunciosloc.server.repository.PerfilUtilizadorRepository;
import pt.anunciosloc.server.repository.RestricaoRepository;
import java.sql.Statement;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.*;

import java.net.URL;
import java.sql.Timestamp;

import jakarta.xml.ws.Service;
import javax.xml.namespace.QName;
import pt.anunciosloc.shared.AuthService;
import pt.anunciosloc.shared.LoginResponse;
import pt.anunciosloc.shared.Ticket;
import pt.anunciosloc.server.repository.AdminRepository;

@WebService(endpointInterface = "pt.anunciosloc.server.service.AnunciosLocService")
public class AnunciosLocServiceImpl implements AnunciosLocService {

    private UtilizadorRepository utilizadorRepo;
    private AnuncioRepository anuncioRepo;
    private InfraestruturaRepository infraRepo;
    private QuorumManager quorumManager;
    private AuthService authService;

    public AnunciosLocServiceImpl() {
        this.utilizadorRepo = new UtilizadorRepository();
        this.anuncioRepo = new AnuncioRepository();
        this.infraRepo = new InfraestruturaRepository();

        List<String> urls = Arrays.asList("http://localhost:8081/infra");
        this.quorumManager = new QuorumManager(urls);
        inicializarAdmin();
        conectarAoKerberos();

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

            System.out.println("=== LISTAR ANUNCIOS POR UTILIZADOR ===");
            System.out.println("Email: " + email);
            System.out.println("Total de anuncios: " + anuncios.size());

            if (anuncios.isEmpty()) {
                return new String[] { "Nenhum anuncio encontrado" };
            }

            return anuncios.stream()
                    .map(a -> {
                        // VERIFICAR SE OS DADOS EXISTEM
                        String titulo = a.getTitulo() != null ? a.getTitulo() : "Sem titulo";
                        String descricao = a.getDescricao() != null ? a.getDescricao() : "Sem descricao";
                        String local = a.getLocal() != null ? a.getLocal() : "Sem local";
                        String data = a.getDataCriacao() != null ? a.getDataCriacao().toString()
                                : LocalDateTime.now().toString();
                        int visualizacoes = a.getTotalVisualizacoes();
                        int entregas = a.getTotalEntregas();
                        String ativo = a.isActivo() ? "1" : "0";
                        String expirado = a.isExpirado() ? "1" : "0";

                        String resultado = titulo + "|" +
                                descricao + "|" +
                                local + "|" +
                                data + "|" +
                                visualizacoes + "|" +
                                entregas + "|" +
                                ativo + "|" +
                                expirado;

                        System.out.println("Anuncio: " + resultado);
                        return resultado;
                    })
                    .toArray(String[]::new);
        } catch (SQLException e) {
            System.err.println("Erro ao listar anuncios: " + e.getMessage());
            return new String[] { "Erro: " + e.getMessage() };
        }
    }

    @WebMethod
    public String[] listarAnunciosCompletosPorUtilizador(@WebParam(name = "email") String email) {
        try {
            List<Anuncio> anuncios = anuncioRepo.buscarPorAutor(email);
            return anuncios.stream()
                    .map(a -> {
                        // Formato completo:
                        // id|titulo|descricao|local|data|visualizacoes|entregas|ativo|expirado
                        return a.getId() + "|" +
                                a.getTitulo() + "|" +
                                a.getDescricao() + "|" +
                                a.getLocal() + "|" +
                                a.getDataCriacao().toString() + "|" +
                                a.getTotalVisualizacoes() + "|" +
                                a.getTotalEntregas() + "|" +
                                (a.isActivo() ? "1" : "0") + "|" +
                                (a.isExpirado() ? "1" : "0") + "|" +
                                a.getDataExpiracao().toString();
                    })
                    .toArray(String[]::new);
        } catch (SQLException e) {
            return new String[] { "Erro: " + e.getMessage() };
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
                return new String[] { "Erro: Utilizador nao encontrado: " + email };
            }

            // 2. Buscar o ID do local (case-insensitive)
            String sqlLocal = "SELECT id FROM locais WHERE LOWER(TRIM(nome)) = LOWER(TRIM(?))";
            Long localId = null;

            try (Connection conn = ConnectionFactory.getConnection();
                    PreparedStatement stmt = conn.prepareStatement(sqlLocal)) {
                stmt.setString(1, local);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    localId = rs.getLong("id");
                    System.out.println("Local encontrado: " + local + " (ID: " + localId + ")");
                }
            }

            if (localId == null) {
                System.out.println("Local nao encontrado: " + local);
                return new String[] { "Erro: Local nao encontrado: " + local };
            }

            // 3. Buscar anúncios do local (excluindo os do próprio utilizador)
            String sqlAnuncios = "SELECT a.id, a.titulo, a.descricao, u.email as autor_email, a.data_criacao " +
                    "FROM anuncios a " +
                    "JOIN utilizadores u ON a.utilizador_id = u.id " +
                    "WHERE a.local_id = ? " +
                    "AND a.activo = 1 " +
                    "AND a.data_expiracao > NOW() " +
                    "AND u.email != ? " +
                    "ORDER BY a.data_criacao DESC";

            List<String> anuncios = new ArrayList<>();

            try (Connection conn = ConnectionFactory.getConnection();
                    PreparedStatement stmt = conn.prepareStatement(sqlAnuncios)) {

                stmt.setLong(1, localId);
                stmt.setString(2, email);
                ResultSet rs = stmt.executeQuery();

                System.out.println("Executando query para local_id: " + localId);
                System.out.println("Excluindo email: " + email);

                int count = 0;
                while (rs.next()) {
                    count++;
                    String mensagem = "📢 " + rs.getString("titulo") + "\n" +
                            rs.getString("descricao") + "\n" +
                            "👤 De: " + rs.getString("autor_email") + "\n" +
                            "📅 " + rs.getTimestamp("data_criacao");
                    anuncios.add(mensagem);
                    System.out.println("Anuncio #" + count + ": " + rs.getString("titulo"));
                }
            }

            System.out.println("Total de anuncios encontrados: " + anuncios.size());

            if (anuncios.isEmpty()) {
                return new String[] { "Nenhum anuncio encontrado neste local." };
            }

            return anuncios.toArray(new String[0]);

        } catch (SQLException e) {
            System.err.println("Erro ao receber anuncios: " + e.getMessage());
            e.printStackTrace();
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
    public String postarMensagemCompleta(String email, String titulo, String descricao, String local,
            int diasValidade) {
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
            utilizadorRepo.atualizarEstatisticas(email, u.getTotalAnunciosPublicados() + 1,
                    u.getTotalVisualizacoesRecebidas());

            // 12. Atualizar quorum
            quorumManager.escreverSaldo(email, (int) (u.getSaldo() - 5.0));

            // 13. Atualizar estatisticas da infraestrutura
            infra.setTotalAnuncios(infra.getTotalAnuncios() + 1);
            // infraRepo.atualizar(infra);

            return "Anuncio publicado com sucesso! ID: " + anuncio.getId() +
                    "\nTitulo: " + titulo +
                    "\nLocal: " + local +
                    "\nValidade: " + diasValidade + " dias" +
                    "\nSaldo restante: " + (int) (u.getSaldo() - 5.0);

        } catch (SQLException e) {
            return "Erro ao publicar anuncio: " + e.getMessage();
        }
    }

    @Override
    public String[] receberAnunciosPorLocalizacao(String email, double latitude, double longitude) {
        System.out.println("=== RECEBER ANUNCIOS POR LOCALIZACAO ===");
        System.out.println("Email: " + email);
        System.out.println("Latitude: " + latitude);
        System.out.println("Longitude: " + longitude);

        try {
            // 1. Verificar se o utilizador existe
            Utilizador u = utilizadorRepo.buscarPorEmail(email);
            if (u == null || !u.isAtivo()) {
                return new String[] { "Erro: Utilizador nao encontrado: " + email };
            }

            // 2. Buscar TODOS os locais (com raio)
            List<Infraestrutura> locais = infraRepo.listarTodas(); // ← JÁ TEM RAIO!

            System.out.println("📍 Total de locais encontrados: " + locais.size());

            // 3. Encontrar o local onde o utilizador está
            Infraestrutura localEncontrado = null;
            double distanciaMinima = Double.MAX_VALUE;

            for (Infraestrutura local : locais) {
                double distancia = calcularDistancia(
                        latitude, longitude,
                        local.getLatitude(), local.getLongitude());

                double raio = local.getRaio(); // ← AGORA FUNCIONA!

                System.out.println("📏 Distancia para " + local.getNome() +
                        ": " + String.format("%.2f", distancia) + "m (raio: " + raio + "m)");

                if (distancia <= raio && distancia < distanciaMinima) {
                    distanciaMinima = distancia;
                    localEncontrado = local;
                }
            }

            if (localEncontrado == null) {
                return new String[] { "Nenhum local encontrado para as coordenadas fornecidas." };
            }

            System.out.println("✅ Local detectado: " + localEncontrado.getNome() +
                    " (distancia: " + String.format("%.2f", distanciaMinima) + "m)");

            // 4. Buscar anúncios do local
            String sqlAnuncios = "SELECT a.id, a.titulo, a.descricao, u.email as autor_email, a.data_criacao " +
                    "FROM anuncios a " +
                    "JOIN utilizadores u ON a.utilizador_id = u.id " +
                    "WHERE a.local_id = ? " +
                    "AND a.activo = 1 " +
                    "AND a.data_expiracao > NOW() " +
                    "AND u.email != ? " +
                    "ORDER BY a.data_criacao DESC";

            List<String> anuncios = new ArrayList<>();

            try (Connection conn = ConnectionFactory.getConnection();
                    PreparedStatement stmt = conn.prepareStatement(sqlAnuncios)) {

                stmt.setLong(1, localEncontrado.getId());
                stmt.setString(2, email);
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    String mensagem = rs.getString("titulo") + "|" +
                            rs.getString("descricao") + "|" +
                            rs.getString("autor_email") + "|" +
                            rs.getTimestamp("data_criacao").toString();
                    anuncios.add(mensagem);
                }
            }

            System.out.println(" Total de anuncios encontrados: " + anuncios.size());
            return anuncios.toArray(new String[0]);

        } catch (SQLException e) {
            System.err.println(" Erro ao receber anuncios: " + e.getMessage());
            return new String[] { "Erro: " + e.getMessage() };
        }
    }

    // Método para calcular distância (Haversine)
    private double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
        final int RAIO_TERRA = 6371000; // metros

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return RAIO_TERRA * c;
    }

    // ==================== ADMINISTRADOR ====================

    private Administrador adminAtual;

    // ==================== MÉTODOS ADMIN ====================

    // ==================== ADMIN ====================

    private void inicializarAdmin() {
        try (Connection conn = ConnectionFactory.getConnection()) {
            AdminRepository adminRepo = new AdminRepository(conn);
            adminRepo.criarTabela();
            adminRepo.inserirAdminPadrao();

            Administrador admin = adminRepo.findByEmail("admin@anunciosloc.com");
            if (admin != null) {
                System.out.println("========================================");
                System.out.println("🔐 ADMIN INICIALIZADO");
                System.out.println("📧 Email: admin@anunciosloc.com");
                System.out.println("🔑 Password: admin123");
                System.out.println("👤 Role: " + admin.getRole());
                System.out.println("========================================");
            }
        } catch (SQLException e) {
            System.err.println("❌ Erro ao inicializar admin: " + e.getMessage());
        }
    }

 private void conectarAoKerberos() {
    try {
        URL wsdlUrl = new URL("http://localhost:8085/auth?wsdl");

        // Namespace e nome do serviço
        QName qname = new QName(
            "http://service.auth.anunciosloc.pt/",
            "AuthServiceImplService"
        );

        Service service = Service.create(wsdlUrl, qname);
        this.authService = service.getPort(AuthService.class);

        System.out.println("Conectado ao Kerberos (porta 8085)");
    } catch (Exception e) {
        System.err.println("Erro ao conectar ao Kerberos: " + e.getMessage());
        e.printStackTrace();
        this.authService = null;
    }
}
    // ==================== ADMIN LOGIN ====================
    // ==================== ADMIN LOGIN ====================

    @Override
    public String loginAdmin(String email, String password) {
        try (Connection conn = ConnectionFactory.getConnection()) {
            // 1. Verificar se admin existe no banco
            AdminRepository adminRepo = new AdminRepository(conn);
            if (!adminRepo.existeAdmin(email)) {
                return "Administrador nao encontrado";
            }

            // 2. Autenticar via Auth Service (Kerberos)
            if (authService == null) {
                return "Servidor de autenticacao indisponivel";
            }

            try {
                // Chamar o Auth Service - usar solicitarTicketAdmin para SOAP
                Ticket ticket = authService.solicitarTicketAdmin(email, password);

                if (ticket != null && ticket.getTicketId() != null) {
                    // 3. Atualizar ultimo acesso
                    adminRepo.atualizarUltimoAcesso(email);

                    return "Login realizado com sucesso\n" +
                            "Ticket: " + ticket.getTicketId() + "\n" +
                            "Email: " + ticket.getClienteEmail();
                }

                return "Credenciais invalidas";

            } catch (Exception e) {
                return "Erro na autenticacao: " + e.getMessage();
            }

        } catch (SQLException e) {
            return "Erro no banco de dados: " + e.getMessage();
        }
    }

    @Override
    public String getAdminInfo(String email) {
        try (Connection conn = ConnectionFactory.getConnection()) {
            AdminRepository adminRepo = new AdminRepository(conn);
            Administrador admin = adminRepo.findByEmail(email);
            if (admin == null) {
                return "❌ Administrador não encontrado";
            }
            return "👤 Nome: " + admin.getNome() +
                    "\n📧 Email: " + admin.getEmail() +
                    "\n🔑 Role: " + admin.getRole() +
                    "\n📅 Registo: " + admin.getDataRegisto();
        } catch (SQLException e) {
            return "❌ Erro: " + e.getMessage();
        }
    }

    @Override
    public String atualizarAdmin(String email, String nome, String password) {
        try (Connection conn = ConnectionFactory.getConnection()) {
            StringBuilder sql = new StringBuilder("UPDATE administradores SET ");
            List<Object> params = new ArrayList<>();

            if (nome != null && !nome.isEmpty()) {
                sql.append("nome = ?, ");
                params.add(nome);
            }

            if (password != null && !password.isEmpty()) {
                sql.append("password_hash = ?, ");
                params.add(hashPassword(password));
            }

            if (params.isEmpty()) {
                return "❌ Nenhum campo para atualizar";
            }

            sql.setLength(sql.length() - 2);
            sql.append(" WHERE email = ?");
            params.add(email);

            try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    stmt.setObject(i + 1, params.get(i));
                }
                stmt.executeUpdate();
            }
            return "✅ Administrador atualizado com sucesso!";
        } catch (SQLException e) {
            return "❌ Erro: " + e.getMessage();
        }
    }

    private String hashPassword(String password) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            return password;
        }
    }

    @Override
public String cadastrarAdmin(String email, String password, String nome, String role) {
    try (Connection conn = ConnectionFactory.getConnection()) {
        // Verificar se já existe
        String sqlCheck = "SELECT 1 FROM administradores WHERE email = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sqlCheck)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return "❌ Administrador já existe: " + email;
            }
        }
        
        // Inserir novo admin
        String sql = "INSERT INTO administradores (email, nome, password_hash, role, ativo) VALUES (?, ?, ?, ?, 1)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.setString(2, nome);
            stmt.setString(3, hashPassword(password));
            stmt.setString(4, role != null && !role.isEmpty() ? role : "ADMIN");
            stmt.executeUpdate();
            
            return "✅ Administrador cadastrado com sucesso!\n" +
                   "📧 Email: " + email + "\n" +
                   "👤 Nome: " + nome + "\n" +
                   "🔑 Role: " + (role != null && !role.isEmpty() ? role : "ADMIN");
        }
    } catch (SQLException e) {
        return "❌ Erro ao cadastrar admin: " + e.getMessage();
    }
}



// ==================== CONTAGEM DE UTILIZADORES ====================

@Override
public int contarUtilizadores() {
    try {
        String sql = "SELECT COUNT(*) FROM utilizadores WHERE sessao_activa = 1";
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    } catch (SQLException e) {
        System.err.println("Erro ao contar utilizadores: " + e.getMessage());
        return 0;
    }
}

// ==================== CONTAGEM DE ANUNCIOS ====================

@Override
public int contarAnuncios() {
    try {
        String sql = "SELECT COUNT(*) FROM anuncios";
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    } catch (SQLException e) {
        System.err.println("Erro ao contar anuncios: " + e.getMessage());
        return 0;
    }
}

@Override
public int contarAnunciosPorUtilizador(String email) {
    try {
        String sql = "SELECT COUNT(*) FROM anuncios a " +
                     "JOIN utilizadores u ON a.utilizador_id = u.id " +
                     "WHERE u.email = ?";
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    } catch (SQLException e) {
        System.err.println("Erro ao contar anuncios do utilizador: " + e.getMessage());
        return 0;
    }
}

@Override
public int contarAnunciosPorLocal(String local) {
    try {
        String sql = "SELECT COUNT(*) FROM anuncios a " +
                     "JOIN locais l ON a.local_id = l.id " +
                     "WHERE l.nome = ?";
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, local);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    } catch (SQLException e) {
        System.err.println("Erro ao contar anuncios do local: " + e.getMessage());
        return 0;
    }
}

@Override
public int contarAnunciosAtivos() {
    try {
        String sql = "SELECT COUNT(*) FROM anuncios WHERE activo = 1 AND data_expiracao > NOW()";
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    } catch (SQLException e) {
        System.err.println("Erro ao contar anuncios ativos: " + e.getMessage());
        return 0;
    }
}

@Override
public int contarAnunciosExpirados() {
    try {
        String sql = "SELECT COUNT(*) FROM anuncios WHERE activo = 1 AND data_expiracao <= NOW()";
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    } catch (SQLException e) {
        System.err.println("Erro ao contar anuncios expirados: " + e.getMessage());
        return 0;
    }
}

// ==================== CONTAGEM DE LOCAIS ====================

@Override
public int contarLocais() {
    try {
        String sql = "SELECT COUNT(*) FROM locais";
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    } catch (SQLException e) {
        System.err.println("Erro ao contar locais: " + e.getMessage());
        return 0;
    }
}

@Override
public int contarInfraestruturasAtivas() {
    try {
        String sql = "SELECT COUNT(*) FROM infraestruturas WHERE ativo = 1";
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    } catch (SQLException e) {
        System.err.println("Erro ao contar infraestruturas ativas: " + e.getMessage());
        return 0;
    }
}

// ==================== ESTATISTICAS COMPLETAS ====================

@Override
public String getEstatisticasCompletas() {
    try {
        int totalUtilizadores = contarUtilizadores();
        int totalAnuncios = contarAnuncios();
        int totalLocais = contarLocais();
        int totalAnunciosAtivos = contarAnunciosAtivos();
        int totalAnunciosExpirados = contarAnunciosExpirados();
        int totalInfraestruturasAtivas = contarInfraestruturasAtivas();
        
        return "ESTATISTICAS DO SISTEMA\n" +
               "================================\n" +
               "Utilizadores ativos: " + totalUtilizadores + "\n" +
               "Total de anuncios: " + totalAnuncios + "\n" +
               "Anuncios ativos: " + totalAnunciosAtivos + "\n" +
               "Anuncios expirados: " + totalAnunciosExpirados + "\n" +
               "Locais cadastrados: " + totalLocais + "\n" +
               "Infraestruturas ativas: " + totalInfraestruturasAtivas + "\n" +
               "================================\n";
    } catch (Exception e) {
        return "Erro ao obter estatisticas: " + e.getMessage();
    }
}

@Override
public String eliminarAnuncio(String id) {
    try {
        System.out.println(" Tentando eliminar anúncio ID: " + id);
        
        // Verificar se o anúncio existe
        Anuncio anuncio = anuncioRepo.buscarPorId(id);
        if (anuncio == null) {
            return "ERRO: Anúncio não encontrado com ID: " + id;
        }
        
        // Verificar se o anúncio está ativo (opcional)
        if (!anuncio.isActivo()) {
            return "ERRO: Anúncio já está inativo ou foi removido: " + id;
        }
        
        // Remover o anúncio
        anuncioRepo.eliminar(id);
        
        System.out.println(" Anúncio eliminado com sucesso: " + id);
        return "Anúncio eliminado com sucesso! ID: " + id;
        
    } catch (SQLException e) {
        System.err.println(" Erro ao eliminar anúncio: " + e.getMessage());
        return "ERRO: " + e.getMessage();
    } catch (Exception e) {
        System.err.println(" Erro inesperado: " + e.getMessage());
        return "ERRO: " + e.getMessage();
    }
}
 
}