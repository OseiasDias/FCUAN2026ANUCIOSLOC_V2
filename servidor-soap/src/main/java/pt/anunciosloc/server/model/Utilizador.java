package pt.anunciosloc.server.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Utilizador implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private Long id;
    private String email;
    private String password;
    private String nome;
    private double saldo;
    private LocalDateTime ultimoAnuncio;
    private boolean sessaoActiva;
    private LocalDateTime dataRegisto;
    private int totalAnunciosPublicados;
    private int totalVisualizacoesRecebidas;
    
    public Utilizador() {
        this.saldo = 10.0;
        this.sessaoActiva = true;
        this.dataRegisto = LocalDateTime.now();
        this.totalAnunciosPublicados = 0;
        this.totalVisualizacoesRecebidas = 0;
    }
    
    public Utilizador(String email) {
        this();
        this.email = email;
        this.nome = email.substring(0, email.indexOf('@'));
    }
    
    public Utilizador(String email, String password, String nome) {
        this(email);
        this.password = password;
        this.nome = nome;
    }
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    
    public double getSaldo() { return saldo; }
    public void setSaldo(double saldo) { this.saldo = saldo; }
    
    public LocalDateTime getUltimoAnuncio() { return ultimoAnuncio; }
    public void setUltimoAnuncio(LocalDateTime ultimoAnuncio) { 
        this.ultimoAnuncio = ultimoAnuncio; 
    }
    
    public boolean isSessaoActiva() { return sessaoActiva; }
    public void setSessaoActiva(boolean sessaoActiva) { this.sessaoActiva = sessaoActiva; }
    
    // Metodo para compatibilidade com codigo antigo
    public boolean isAtivo() { return sessaoActiva; }
    public void setAtivo(boolean ativo) { this.sessaoActiva = ativo; }
    
    public LocalDateTime getDataRegisto() { return dataRegisto; }
    public void setDataRegisto(LocalDateTime dataRegisto) { this.dataRegisto = dataRegisto; }
    
    public int getTotalAnunciosPublicados() { return totalAnunciosPublicados; }
    public void setTotalAnunciosPublicados(int totalAnunciosPublicados) { 
        this.totalAnunciosPublicados = totalAnunciosPublicados; 
    }
    
    public int getTotalVisualizacoesRecebidas() { return totalVisualizacoesRecebidas; }
    public void setTotalVisualizacoesRecebidas(int totalVisualizacoesRecebidas) { 
        this.totalVisualizacoesRecebidas = totalVisualizacoesRecebidas; 
    }
    
    public void creditarSaldo(double valor) { 
        this.saldo += valor; 
    }
    
    public boolean debitarSaldo(double valor) { 
        if (this.saldo >= valor) {
            this.saldo -= valor;
            return true;
        }
        return false;
    }
    
    public void incrementarAnunciosPublicados() {
        this.totalAnunciosPublicados++;
    }
    
    public void incrementarVisualizacoesRecebidas() {
        this.totalVisualizacoesRecebidas++;
    }
    
    public boolean podePublicarAnuncio() {
        if (ultimoAnuncio == null) return true;
        return java.time.Duration.between(ultimoAnuncio, LocalDateTime.now()).toMinutes() >= 1;
    }
}