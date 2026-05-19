package pt.anunciosloc.shared;

import jakarta.jws.WebMethod;
import jakarta.jws.WebParam;
import jakarta.jws.WebService;
import jakarta.jws.soap.SOAPBinding;
import jakarta.jws.soap.SOAPBinding.Style;

@WebService(targetNamespace = "http://service.infra.anunciosloc.pt/")
@SOAPBinding(style = Style.RPC)
public interface InfraService {
    
    @WebMethod
    String getNome();
    
    @WebMethod
    int obterSaldo(@WebParam(name = "email") String email);
    
    @WebMethod
    String escreverSaldo(@WebParam(name = "email") String email, 
                         @WebParam(name = "valor") int valor);
    
    @WebMethod
    String ping();
}