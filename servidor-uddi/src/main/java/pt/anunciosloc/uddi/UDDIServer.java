package pt.anunciosloc.uddi;

import jakarta.xml.ws.Endpoint;
import pt.anunciosloc.uddi.service.UDDIServiceImpl;

public class UDDIServer {
    public static void main(String[] args) {
        String url = "http://0.0.0.0:8090/uddi";
        
        System.out.println("=========================================");
        System.out.println("UDDI SERVER - Descoberta de Servicos");
        System.out.println("=========================================");
        System.out.println("Publicando UDDI em: " + url);
        
        Endpoint endpoint = Endpoint.publish(url, new UDDIServiceImpl());
        
        System.out.println("UDDI Server iniciado com sucesso!");
        System.out.println("WSDL: " + url + "?wsdl");
        System.out.println("=========================================");
        System.out.println("Prima ENTER para parar...");
        
        try {
            System.in.read();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        endpoint.stop();
        System.out.println("UDDI Server parado.");
    }
}