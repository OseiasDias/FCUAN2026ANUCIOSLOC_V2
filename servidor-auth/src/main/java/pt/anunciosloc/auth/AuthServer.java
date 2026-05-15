package pt.anunciosloc.auth;

import jakarta.xml.ws.Endpoint;
import pt.anunciosloc.auth.service.AuthServiceImpl;

public class AuthServer {
    public static void main(String[] args) {
        //String url = "http://localhost:8085/auth";
        String url = "http://0.0.0.0:8085/auth";
        
        System.out.println("=========================================");
        System.out.println(" KERBEROS AUTHENTICATION SERVER");
        System.out.println("=========================================");
        System.out.println("Publicando em: " + url);
        
        Endpoint endpoint = Endpoint.publish(url, new AuthServiceImpl());
        
        System.out.println(" Servidor iniciado!");
        System.out.println(" WSDL: " + url + "?wsdl");
        System.out.println("=========================================");
        System.out.println("Credenciais:");
        System.out.println("  joao@gmail.com / 123456");
        System.out.println("  maria@gmail.com / abcdef");
        System.out.println("=========================================");
        System.out.println("Prima ENTER para parar...");
        
        try {
            System.in.read();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        endpoint.stop();
        System.out.println("Servidor parado.");
    }
}