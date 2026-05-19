package pt.anunciosloc.uddi.service;

import jakarta.jws.WebMethod;
import jakarta.jws.WebParam;
import jakarta.jws.WebService;
import jakarta.jws.soap.SOAPBinding;
import jakarta.jws.soap.SOAPBinding.Style;
import pt.anunciosloc.shared.ServicoRegistado;

@WebService
@SOAPBinding(style = Style.RPC)
public interface UDDIService {
    
    @WebMethod
    String registarServico(@WebParam(name = "nome") String nome,
                          @WebParam(name = "url") String url,
                          @WebParam(name = "tipo") String tipo,
                          @WebParam(name = "localizacao") String localizacao,
                          @WebParam(name = "latitude") double latitude,
                          @WebParam(name = "longitude") double longitude);
    
    @WebMethod
    boolean removerServico(@WebParam(name = "nome") String nome);
    
    @WebMethod
    ServicoRegistado[] listarServicos();
    
    @WebMethod
    ServicoRegistado[] listarServicosPorTipo(@WebParam(name = "tipo") String tipo);
    
    @WebMethod
    ServicoRegistado obterServico(@WebParam(name = "nome") String nome);
    
    @WebMethod
    ServicoRegistado[] listarServicosProximos(@WebParam(name = "latitude") double latitude,
                                               @WebParam(name = "longitude") double longitude,
                                               @WebParam(name = "maxDistancia") double maxDistancia);
    
    @WebMethod
    String ping();
}