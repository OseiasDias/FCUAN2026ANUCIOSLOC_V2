package pt.anunciosloc.server.quorum;

import pt.anunciosloc.server.client.InfraClient;
import java.util.*;
import java.util.concurrent.*;

public class QuorumManager {
    
    private List<InfraClient> replicas;
    private int N;
    private int W;
    private int R;
    
    public QuorumManager(List<String> urls) {
        this.replicas = new ArrayList<>();
        
        System.out.println("🔌 Conectando às réplicas...");
        
        for (String url : urls) {
            InfraClient client = new InfraClient(url);
            if (client.ping()) {
                replicas.add(client);
                System.out.println("✅ Réplica conectada: " + url);
            } else {
                System.out.println("❌ Réplica falhou: " + url);
            }
        }
        
        this.N = this.replicas.size();
        this.W = (N / 2) + 1;
        this.R = (N / 2) + 1;
        
        System.out.println("=== QUORUM CONFIGURADO ===");
        System.out.println("N (réplicas ativas): " + N);
        System.out.println("W (escrita min): " + W);
        System.out.println("R (leitura min): " + R);
        System.out.println("==========================");
    }
    
    public boolean escreverSaldo(String email, int valor) {
        if (replicas.isEmpty()) {
            System.err.println("❌ Nenhuma réplica disponível!");
            return false;
        }
        
        int sucessos = 0;
        List<CompletableFuture<Boolean>> futures = new ArrayList<>();
        
        System.out.println("✍️ Escrevendo saldo " + valor + " para " + email);
        
        for (InfraClient replica : replicas) {
            CompletableFuture<Boolean> future = CompletableFuture.supplyAsync(() -> 
                replica.escreverSaldo(email, valor)
            );
            futures.add(future);
        }
        
        for (CompletableFuture<Boolean> future : futures) {
            try {
                if (future.get(5, TimeUnit.SECONDS)) {
                    sucessos++;
                }
            } catch (Exception e) {
                System.err.println("Erro na escrita: " + e.getMessage());
            }
        }
        
        boolean sucesso = sucessos >= W;
        System.out.println("Resultado: " + sucessos + "/" + N + " sucessos - " + 
                          (sucesso ? "✅ SUCESSO" : "❌ FALHA"));
        
        return sucesso;
    }
    
    public int lerSaldo(String email) {
        if (replicas.isEmpty()) {
            System.err.println("❌ Nenhuma réplica disponível!");
            return -1;
        }
        
        Map<Integer, Integer> votos = new HashMap<>();
        List<CompletableFuture<Integer>> futures = new ArrayList<>();
        
        System.out.println("📖 Lendo saldo para " + email);
        
        for (InfraClient replica : replicas) {
            CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> 
                replica.obterSaldo(email)
            );
            futures.add(future);
        }
        
        for (CompletableFuture<Integer> future : futures) {
            try {
                int saldo = future.get(5, TimeUnit.SECONDS);
                if (saldo >= 0) {
                    votos.put(saldo, votos.getOrDefault(saldo, 0) + 1);
                }
            } catch (Exception e) {
                System.err.println("Erro na leitura: " + e.getMessage());
            }
        }
        
        int valorFinal = -1;
        int maxVotos = 0;
        for (Map.Entry<Integer, Integer> entry : votos.entrySet()) {
            if (entry.getValue() > maxVotos) {
                maxVotos = entry.getValue();
                valorFinal = entry.getKey();
            }
        }
        
        boolean sucesso = maxVotos >= R;
        System.out.println("Resultado: " + maxVotos + "/" + N + " concordam - " + 
                          (sucesso ? "✅ SUCESSO" : "❌ FALHA"));
        
        return sucesso ? valorFinal : -1;
    }
    
    public String getStatus() {
        StringBuilder sb = new StringBuilder();
        sb.append("\n=== ESTADO DAS RÉPLICAS ===\n");
        for (int i = 0; i < replicas.size(); i++) {
            boolean ativa = replicas.get(i).ping();
            sb.append("Réplica ").append(i + 1).append(": ")
              .append(ativa ? " ATIVA" : " INATIVA").append("\n");
        }
        sb.append("===========================\n");
        return sb.toString();
    }
}