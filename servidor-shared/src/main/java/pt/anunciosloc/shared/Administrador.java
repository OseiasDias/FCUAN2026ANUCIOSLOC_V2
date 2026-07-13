package pt.anunciosloc.shared;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Administrador implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private Long id;
    private String email;
    private String nome;
    private String passwordHash;
    private String role;
    private boolean ativo;
    private LocalDateTime dataRegisto;
    private LocalDateTime ultimoAcesso;
    
    public Administrador() {
        this.ativo = true;
        this.role = "ADMIN";
        this.dataRegisto = LocalDateTime.now();
    }
    
    public Administrador(String email, String nome, String passwordHash) {
        this();
        this.email = email;
        this.nome = nome;
        this.passwordHash = passwordHash;
    }
    
    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { this.ativo = ativo; }
    
    public LocalDateTime getDataRegisto() { return dataRegisto; }
    public void setDataRegisto(LocalDateTime dataRegisto) { this.dataRegisto = dataRegisto; }
    
    public LocalDateTime getUltimoAcesso() { return ultimoAcesso; }
    public void setUltimoAcesso(LocalDateTime ultimoAcesso) { this.ultimoAcesso = ultimoAcesso; }
}