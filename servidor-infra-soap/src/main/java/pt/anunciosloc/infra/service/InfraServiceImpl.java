package pt.anunciosloc.infra.service;

import jakarta.jws.WebService;
import pt.anunciosloc.shared.InfraService;
import pt.anunciosloc.infra.model.Local;
import java.util.*;

@WebService(endpointInterface = "pt.anunciosloc.shared.InfraService")
public class InfraServiceImpl implements InfraService {
    
    private String nome;
    private Map<String, Integer> saldos;
    
    public InfraServiceImpl() {
        this.nome = "Infra-BelasShopping";
        this.saldos = new HashMap<>();
        saldos.put("admin@teste.com", 100);
        
        System.out.println("=== INFRAESTRUTURA INICIADA ===");
        System.out.println("Nome: " + nome);
        System.out.println("Porta: 8081");
        System.out.println("===============================");
    }
    
    @Override
    public String getNome() {
        return nome;
    }
    
    @Override
    public int obterSaldo(String email) {
        int saldo = saldos.getOrDefault(email, 0);
        System.out.println(" Consultando saldo: " + email + " = " + saldo);
        return saldo;
    }
    
    @Override
    public String escreverSaldo(String email, int valor) {
        saldos.put(email, valor);
        System.out.println(" Saldo atualizado: " + email + " = " + valor);
        return "Saldo de " + email + " atualizado para " + valor;
    }
    
    @Override
    public String ping() {
        return "Infraestrutura '" + nome + "' ativa!";
    }
}