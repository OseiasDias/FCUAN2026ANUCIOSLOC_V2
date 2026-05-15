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
    
    // ===== TESTE =====
    @WebMethod
    String ping();
    
    // ===== UTILIZADORES =====
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
    
    // CORRIGIDO: String[] em vez de List<String>
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
    
    // ===== ANÚNCIOS =====
    @WebMethod
    String postarMensagem(@WebParam(name = "email") String email, 
                          @WebParam(name = "conteudo") String conteudo,
                          @WebParam(name = "local") String local);
    
    // CORRIGIDO: String[] em vez de List<String>
    @WebMethod
    String[] receberMensagens(@WebParam(name = "email") String email,
                              @WebParam(name = "local") String local);
    
    // ===== INFRAESTRUTURAS =====
    @WebMethod
    Infraestrutura[] listarInfraestruturas();
    
    @WebMethod
    Infraestrutura obterInfoInfraestrutura(@WebParam(name = "nome") String nome);
    
    // ===== QUORUM =====
    @WebMethod
    String getQuorumStatus();
}