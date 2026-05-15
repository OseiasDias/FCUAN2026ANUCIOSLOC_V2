package pt.anunciosloc.server.client;

import jakarta.xml.ws.Service;
import pt.anunciosloc.shared.InfraService;
import java.net.URI;
import java.net.URL;
import javax.xml.namespace.QName;

public class InfraClient {
    
    private InfraService service;
    private String url;
    
    public InfraClient(String url) {
        this.url = url;
        try {
            URI uri = new URI(url + "?wsdl");
            URL wsdlUrl = uri.toURL();
            QName qname = new QName("http://service.infra.anunciosloc.pt/", "InfraServiceImplService");
            Service soapService = Service.create(wsdlUrl, qname);
            this.service = soapService.getPort(InfraService.class);
            System.out.println("✅ Cliente conectado a: " + url);
        } catch (Exception e) {
            System.err.println("❌ Erro ao conectar com " + url + ": " + e.getMessage());
        }
    }
    
    public int obterSaldo(String email) {
        try {
            if (service == null) return -1;
            return service.obterSaldo(email);
        } catch (Exception e) {
            System.err.println("Erro ao obter saldo: " + e.getMessage());
            return -1;
        }
    }
    
    public boolean escreverSaldo(String email, int valor) {
        try {
            if (service == null) return false;
            String resultado = service.escreverSaldo(email, valor);
            return resultado != null;
        } catch (Exception e) {
            System.err.println("Erro ao escrever saldo: " + e.getMessage());
            return false;
        }
    }
    
    public boolean ping() {
        try {
            if (service == null) return false;
            String resposta = service.ping();
            return resposta != null && resposta.contains("ativa");
        } catch (Exception e) {
            return false;
        }
    }
}