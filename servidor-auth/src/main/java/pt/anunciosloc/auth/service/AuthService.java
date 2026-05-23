package pt.anunciosloc.auth.service;

import jakarta.jws.WebMethod;
import jakarta.jws.WebParam;
import jakarta.jws.WebService;
import jakarta.jws.soap.SOAPBinding;
import jakarta.jws.soap.SOAPBinding.Style;
import pt.anunciosloc.auth.model.LoginResponse;

@WebService
@SOAPBinding(style = Style.RPC)
public interface AuthService {
    
    @WebMethod
    String ping();
    
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
}