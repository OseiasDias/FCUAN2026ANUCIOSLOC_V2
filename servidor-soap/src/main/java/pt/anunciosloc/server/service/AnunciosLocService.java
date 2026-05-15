package pt.anunciosloc.server.service;

import jakarta.jws.WebMethod;
import jakarta.jws.WebParam;
import jakarta.jws.WebService;
import jakarta.jws.soap.SOAPBinding;
import jakarta.jws.soap.SOAPBinding.Style;
import pt.anunciosloc.server.model.Infraestrutura;
import pt.anunciosloc.server.model.Utilizador;

@WebService
@SOAPBinding(style = Style.RPC)
public interface AnunciosLocService {

    // ===================== TESTE =====================
    @WebMethod
    String ping();

    // ===================== UTILIZADORES =====================
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

    // ===================== ANÚNCIOS =====================
    @WebMethod
    String postarMensagem(@WebParam(name = "email") String email,
                          @WebParam(name = "conteudo") String conteudo,
                          @WebParam(name = "local") String local);

    @WebMethod
    String[] receberMensagens(@WebParam(name = "email") String email,
                              @WebParam(name = "local") String local);

    // ===================== INFRAESTRUTURAS (COMPLETO) =====================

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

    // ===================== QUORUM =====================
    @WebMethod
    String getQuorumStatus();
}