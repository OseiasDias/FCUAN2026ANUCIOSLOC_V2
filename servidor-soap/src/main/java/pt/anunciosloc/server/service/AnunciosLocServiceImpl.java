package pt.anunciosloc.server.service;

import jakarta.jws.WebService;
import pt.anunciosloc.server.model.*;
import pt.anunciosloc.server.quorum.QuorumManager;
import pt.anunciosloc.server.repository.UtilizadorRepository;
import pt.anunciosloc.server.repository.AnuncioRepository;
import pt.anunciosloc.server.repository.InfraestruturaRepository;
import pt.anunciosloc.server.repository.PerfilUtilizadorRepository;

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

            Anuncio anuncio = new Anuncio(conteudo, email, local);
            anuncioRepo.salvar(anuncio);
            utilizadorRepo.atualizarUltimoAnuncio(email, LocalDateTime.now());
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
            List<Infraestrutura> infraList = infraRepo.listarTodas();
            List<String> result = new ArrayList<>();
            for (Infraestrutura infra : infraList) {
                String data = infra.getNome() + "|" +
                        infra.getLatitude() + "|" +
                        infra.getLongitude() + "|" +
                        infra.getCapacidade();
                result.add(data);
            }
            return result.toArray(new String[0]);
        } catch (SQLException e) {
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

}