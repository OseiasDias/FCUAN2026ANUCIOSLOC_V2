package pt.anunciosloc.uddi;

import jakarta.xml.ws.Endpoint;
import pt.anunciosloc.uddi.service.UDDIServiceImpl;

public class UDDIServer {
    public static void main(String[] args) {
        String url = "http://localhost:8090/uddi";
        
        System.out.println("=========================================");
        System.out.println(" UDDI SERVER - Descoberta de Serviços");
        System.out.println("=========================================");
        System.out.println("Publicando UDDI em: " + url);
        
        Endpoint endpoint = Endpoint.publish(url, new UDDIServiceImpl());
        
        System.out.println(" UDDI Server iniciado com sucesso!");
        System.out.println(" WSDL: " + url + "?wsdl");
        System.out.println("=========================================");
        System.out.println("Comandos para testar:");
        System.out.println("  - Listar serviços: POST para " + url);
        System.out.println("  - Ping: GET " + url + "?wsdl");
        System.out.println("=========================================");
        System.out.println("Prima ENTER para parar...");
        
        try {
            System.in.read();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        endpoint.stop();
        System.out.println(" UDDI Server parado.");
    }
}