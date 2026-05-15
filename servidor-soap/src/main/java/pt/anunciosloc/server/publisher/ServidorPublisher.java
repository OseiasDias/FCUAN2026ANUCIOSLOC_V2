package pt.anunciosloc.server.publisher;

import jakarta.xml.ws.Endpoint;
import pt.anunciosloc.server.service.AnunciosLocServiceImpl;

public class ServidorPublisher {
    public static void main(String[] args) {
        // Porta 8082 (nova porta)
        String url = "http://0.0.0.0:8082/ws/anunciosloc";
        
        System.out.println("Publicando Web Service em: " + url);
        
        Endpoint endpoint = Endpoint.publish(url, new AnunciosLocServiceImpl());
        
        System.out.println("✅ Servidor SOAP iniciado na porta 8082!");
        System.out.println("📄 WSDL: " + url + "?wsdl");
        System.out.println("Prima ENTER para parar...");
        
        try {
            System.in.read();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        endpoint.stop();
        System.out.println(" Servidor parado.");
    }
}