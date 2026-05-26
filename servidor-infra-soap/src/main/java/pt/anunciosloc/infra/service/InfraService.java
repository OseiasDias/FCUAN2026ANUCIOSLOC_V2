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
    String criarLocal(
            @WebParam(name = "nome") String nome,
            @WebParam(name = "tipo") String tipo,
            @WebParam(name = "latitude") double latitude,
            @WebParam(name = "longitude") double longitude,
            @WebParam(name = "raio") double raio,
            @WebParam(name = "wifiSsid") String wifiSsid,
            @WebParam(name = "infraestruturaId") long infraestruturaId);

    @WebMethod
    int obterSaldo(@WebParam(name = "email") String email);

    @WebMethod
    String escreverSaldo(@WebParam(name = "email") String email,
            @WebParam(name = "valor") int valor);

    @WebMethod
    String incrementarUtilizadoresConectados();

    @WebMethod
    String decrementarUtilizadoresConectados();

    @WebMethod
    String incrementarAnunciosPublicados();

    @WebMethod
    String incrementarAnunciosEntregues();

    @WebMethod
    String registrarNoUDDI();

    @WebMethod
    String ping();
}