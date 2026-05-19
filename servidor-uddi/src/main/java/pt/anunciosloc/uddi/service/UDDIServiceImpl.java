package pt.anunciosloc.uddi.service;

import jakarta.jws.WebService;
import pt.anunciosloc.shared.ServicoRegistado;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@WebService(endpointInterface = "pt.anunciosloc.uddi.service.UDDIService")
public class UDDIServiceImpl implements UDDIService {
    
    private Map<String, ServicoRegistado> servicos = new ConcurrentHashMap<>();
    
    public UDDIServiceImpl() {
        System.out.println("=== UDDI SERVER INICIADO ===");
        System.out.println("Registro de servicos vazio. Aguardando registos...");
        
        servicos.put("servidor-soap", new ServicoRegistado(
            "servidor-soap",
            "http://localhost:8082/ws/anunciosloc",
            "PRINCIPAL",
            "Luanda",
            -8.8383, 
            13.2344
        ));
        
        servicos.put("servidor-infra", new ServicoRegistado(
            "servidor-infra",
            "http://localhost:8081/infra",
            "INFRAESTRUTURA",
            "Belas Shopping, Luanda",
            -8.98, 
            13.18
        ));
        
        servicos.put("servidor-auth", new ServicoRegistado(
            "servidor-auth",
            "http://localhost:8085/auth",
            "AUTH",
            "Luanda",
            -8.8383, 
            13.2344
        ));
    }
    
    @Override
    public String registarServico(String nome, String url, String tipo, 
                                  String localizacao, double latitude, double longitude) {
        ServicoRegistado servico = new ServicoRegistado(nome, url, tipo, localizacao, latitude, longitude);
        servicos.put(nome, servico);
        System.out.println("Servico registado: " + nome + " em " + url);
        return "Servico '" + nome + "' registado com sucesso em " + url;
    }
    
    @Override
    public boolean removerServico(String nome) {
        ServicoRegistado removido = servicos.remove(nome);
        if (removido != null) {
            System.out.println("Servico removido: " + nome);
            return true;
        }
        return false;
    }
    
    @Override
    public ServicoRegistado[] listarServicos() {
        return servicos.values().toArray(new ServicoRegistado[0]);
    }
    
    @Override
    public ServicoRegistado[] listarServicosPorTipo(String tipo) {
        return servicos.values().stream()
                .filter(s -> s.getTipo().equalsIgnoreCase(tipo))
                .toArray(ServicoRegistado[]::new);
    }
    
    @Override
    public ServicoRegistado obterServico(String nome) {
        return servicos.get(nome);
    }
    
    @Override
    public ServicoRegistado[] listarServicosProximos(double latitude, double longitude, double maxDistancia) {
        return servicos.values().stream()
                .filter(s -> s.getTipo().equals("INFRAESTRUTURA"))
                .filter(s -> calcularDistancia(latitude, longitude, s.getLatitude(), s.getLongitude()) <= maxDistancia)
                .toArray(ServicoRegistado[]::new);
    }
    
    @Override
    public String ping() {
        return "UDDI Server ativo! Servicos registados: " + servicos.size();
    }
    
    private double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
        double dx = lat1 - lat2;
        double dy = lon1 - lon2;
        return Math.sqrt(dx * dx + dy * dy) * 111;
    }
}