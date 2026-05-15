package pt.anunciosloc.server.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Utilizador implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String email;
    private String password;
    private String nome;
    private int saldo;
    private LocalDateTime ultimoAnuncio;
    private boolean ativo;
    private LocalDateTime dataRegisto;
    
    public Utilizador() {
        this.saldo = 10;
        this.ativo = true;
        this.dataRegisto = LocalDateTime.now();
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
    
    // Getters e Setters
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    
    public int getSaldo() { return saldo; }
    public void setSaldo(int saldo) { this.saldo = saldo; }
    
    public LocalDateTime getUltimoAnuncio() { return ultimoAnuncio; }
    public void setUltimoAnuncio(LocalDateTime ultimoAnuncio) { 
        this.ultimoAnuncio = ultimoAnuncio; 
    }
    
    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { this.ativo = ativo; }
    
    public LocalDateTime getDataRegisto() { return dataRegisto; }
    public void setDataRegisto(LocalDateTime dataRegisto) { this.dataRegisto = dataRegisto; }
    
    // Métodos auxiliares
    public void creditarSaldo(int valor) { this.saldo += valor; }
    public void debitarSaldo(int valor) { this.saldo -= valor; }
}