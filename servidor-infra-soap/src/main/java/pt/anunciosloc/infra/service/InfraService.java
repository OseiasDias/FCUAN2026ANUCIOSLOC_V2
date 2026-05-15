package pt.anunciosloc.infra.service;

import jakarta.jws.WebMethod;
import jakarta.jws.WebParam;
import jakarta.jws.WebService;
import jakarta.jws.soap.SOAPBinding;
import jakarta.jws.soap.SOAPBinding.Style;
import pt.anunciosloc.infra.model.Local;

@WebService
@SOAPBinding(style = Style.RPC)
public interface InfraService {
    
    @WebMethod
    String getNome();
    
    @WebMethod
    Local getLocal();
    
    @WebMethod
    int getCapacidade();
    
    @WebMethod
    int getUtilizadoresConectados();
    
    @WebMethod
    int getTotalAnuncios();
    
    @WebMethod
    int getTotalEntregas();
    
    @WebMethod
    String obterInfoInfraestrutura();
    
    @WebMethod
    String criarLocal(@WebParam(name = "local") Local local);
    
    @WebMethod
    int obterSaldo(@WebParam(name = "email") String email);
    
    @WebMethod
    String escreverSaldo(@WebParam(name = "email") String email, 
                         @WebParam(name = "valor") int valor);
    
    @WebMethod
    String registrarNoUDDI();
    
    @WebMethod
    String ping();
}