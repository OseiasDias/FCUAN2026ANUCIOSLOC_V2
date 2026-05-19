package pt.anunciosloc.shared;

import jakarta.jws.WebMethod;
import jakarta.jws.WebParam;
import jakarta.jws.WebService;
import jakarta.jws.soap.SOAPBinding;
import jakarta.jws.soap.SOAPBinding.Style;

@WebService
@SOAPBinding(style = Style.RPC)
public interface AuthService {
    
    @WebMethod
    String ping();
    
    @WebMethod
    Ticket solicitarTicket(@WebParam(name = "email") String email,
                          @WebParam(name = "password") String password);
    
    @WebMethod
    boolean validarTicket(@WebParam(name = "ticketId") String ticketId,
                         @WebParam(name = "email") String email);
    
    @WebMethod
    boolean invalidarTicket(@WebParam(name = "ticketId") String ticketId);
    
    @WebMethod
    String registarUtilizador(@WebParam(name = "email") String email,
                              @WebParam(name = "password") String password);
}