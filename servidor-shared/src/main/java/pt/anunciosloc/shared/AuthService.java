package pt.anunciosloc.shared;

import jakarta.jws.WebMethod;
import jakarta.jws.WebParam;
import jakarta.jws.WebService;
import jakarta.jws.soap.SOAPBinding;
import jakarta.jws.soap.SOAPBinding.Style;

@WebService(targetNamespace = "http://service.auth.anunciosloc.pt/")
@SOAPBinding(style = Style.RPC)
public interface AuthService {
    
    @WebMethod
    String ping();
    
    // ==================== JWT (REST) ====================
    
    @WebMethod
    LoginResponse login(@WebParam(name = "email") String email,
                        @WebParam(name = "password") String password);
    
    @WebMethod
    LoginResponse refreshToken(@WebParam(name = "refreshToken") String refreshToken);
    
    @WebMethod
    boolean validarToken(@WebParam(name = "token") String token);
    
    @WebMethod
    String registarUtilizador(@WebParam(name = "email") String email,
                              @WebParam(name = "password") String password);
    
    // ==================== ADMIN (SOAP) ====================
    
    @WebMethod
    Ticket solicitarTicketAdmin(@WebParam(name = "email") String email,
                               @WebParam(name = "password") String password);
    
    @WebMethod
    boolean validarTicketAdmin(@WebParam(name = "ticketId") String ticketId,
                              @WebParam(name = "email") String email);
}