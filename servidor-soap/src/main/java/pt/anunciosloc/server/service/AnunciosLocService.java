package pt.anunciosloc.server.service;

import java.util.Map;

import jakarta.jws.WebMethod;
import jakarta.jws.WebParam;
import jakarta.jws.WebService;
import jakarta.jws.soap.SOAPBinding;
import jakarta.jws.soap.SOAPBinding.Style;
import pt.anunciosloc.server.model.Infraestrutura;
import pt.anunciosloc.server.model.Utilizador;
import pt.anunciosloc.server.repository.PerfilUtilizadorRepository;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

@WebService
@SOAPBinding(style = Style.RPC)
public interface AnunciosLocService {

        @WebMethod
        String ping();

        @WebMethod
        String ativarUtilizador(@WebParam(name = "email") String email,
                        @WebParam(name = "password") String password,
                        @WebParam(name = "nome") String nome);

        @WebMethod
        int consultarSaldo(@WebParam(name = "email") String email);

        @WebMethod
        String atualizarSaldo(@WebParam(name = "email") String email,
                        @WebParam(name = "novoSaldo") int novoSaldo);

        @WebMethod
        String eliminarUtilizador(@WebParam(name = "email") String email);

        @WebMethod
        String editarUtilizador(@WebParam(name = "email") String email,
                        @WebParam(name = "novoEmail") String novoEmail,
                        @WebParam(name = "novoNome") String novoNome);

        @WebMethod
        String[] listarUtilizadores();

        @WebMethod
        String alterarPassword(@WebParam(name = "email") String email,
                        @WebParam(name = "passwordAntiga") String passwordAntiga,
                        @WebParam(name = "passwordNova") String passwordNova);

        @WebMethod
        String desativarConta(@WebParam(name = "email") String email);

        @WebMethod
        String reativarConta(@WebParam(name = "email") String email);

        @WebMethod
        Utilizador obterUtilizador(@WebParam(name = "email") String email);

        @WebMethod
        String postarMensagem(@WebParam(name = "email") String email,
                        @WebParam(name = "conteudo") String conteudo,
                        @WebParam(name = "local") String local);

        @WebMethod
        String[] receberMensagens(@WebParam(name = "email") String email,
                        @WebParam(name = "local") String local);

        @WebMethod
        String criarInfraestrutura(@WebParam(name = "nome") String nome,
                        @WebParam(name = "localizacao") String localizacao,
                        @WebParam(name = "latitude") double latitude,
                        @WebParam(name = "longitude") double longitude,
                        @WebParam(name = "capacidade") int capacidade,
                        @WebParam(name = "url") String url,
                        @WebParam(name = "criadorEmail") String criadorEmail);

        @WebMethod
        String editarInfraestrutura(@WebParam(name = "nome") String nome,
                        @WebParam(name = "novoNome") String novoNome,
                        @WebParam(name = "localizacao") String localizacao,
                        @WebParam(name = "latitude") double latitude,
                        @WebParam(name = "longitude") double longitude,
                        @WebParam(name = "capacidade") int capacidade,
                        @WebParam(name = "url") String url);

        @WebMethod
        String eliminarInfraestrutura(@WebParam(name = "nome") String nome);

        @WebMethod
        String ativarInfraestrutura(@WebParam(name = "nome") String nome);

        @WebMethod
        String desativarInfraestrutura(@WebParam(name = "nome") String nome);

        @WebMethod
        String incrementarUtilizadores(@WebParam(name = "nome") String nome);

        @WebMethod
        String decrementarUtilizadores(@WebParam(name = "nome") String nome);

        @WebMethod
        String incrementarAnuncios(@WebParam(name = "nome") String nome);

        @WebMethod
        String incrementarEntregas(@WebParam(name = "nome") String nome);

        @WebMethod
        Infraestrutura[] listarInfraestruturas();

        @WebMethod
        Infraestrutura obterInfoInfraestrutura(@WebParam(name = "nome") String nome);

        @WebMethod
        String getQuorumStatus();

        @WebMethod
        String[] listarAnuncios();

        @WebMethod
        String[] listarAnunciosPorUtilizador(@WebParam(name = "email") String email);

        @WebMethod
        String[] listarLocaisCoordenadas();

        @WebMethod
        String salvarPreferencia(@WebParam(name = "email") String email,
                        @WebParam(name = "chave") String chave,
                        @WebParam(name = "valor") String valor);

        @WebMethod
        String obterPreferencia(@WebParam(name = "email") String email,
                        @WebParam(name = "chave") String chave);

        @WebMethod
        String[] obterPerfilUtilizador(@WebParam(name = "email") String email);

        @WebMethod
        String removerPreferencia(@WebParam(name = "email") String email,
                        @WebParam(name = "chave") String chave);

        @WebMethod
        String adicionarRestricao(@WebParam(name = "anuncioId") String anuncioId,
                        @WebParam(name = "tipo") String tipo,
                        @WebParam(name = "chave") String chave,
                        @WebParam(name = "valor") String valor);

        @WebMethod
        String[] listarRestricoes(@WebParam(name = "anuncioId") String anuncioId);

        @WebMethod
        String[] receberAnunciosDeOutros(@WebParam(name = "email") String email,
                        @WebParam(name = "local") String local);

        @WebMethod
String postarMensagemCompleta(@WebParam(name = "email") String email,
                              @WebParam(name = "titulo") String titulo,
                              @WebParam(name = "descricao") String descricao,
                              @WebParam(name = "local") String local,
                              @WebParam(name = "diasValidade") int diasValidade);
}