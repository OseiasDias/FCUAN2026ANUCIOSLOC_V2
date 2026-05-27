package pt.anunciosloc.infra;

import jakarta.xml.ws.Endpoint;
import pt.anunciosloc.infra.service.InfraServiceImpl;

public class InfraServer {
    public static void main(String[] args) {
        // Mudar para 0.0.0.0 para aceitar conexoes de qualquer IP
        String url = "http://0.0.0.0:8081/infra";
        
        System.out.println("=========================================");
        System.out.println("INFRAESTRUTURA SOAP");
        System.out.println("=========================================");
        System.out.println("Publicando servico em: " + url);
        
        Endpoint endpoint = Endpoint.publish(url, new InfraServiceImpl());
        
        System.out.println("Infraestrutura iniciada com sucesso!");
        System.out.println("WSDL: " + url + "?wsdl");
        System.out.println("=========================================");
        System.out.println("Prima ENTER para parar...");
        
        try {
            System.in.read();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        endpoint.stop();
        System.out.println("Infraestrutura parada.");
    }
}