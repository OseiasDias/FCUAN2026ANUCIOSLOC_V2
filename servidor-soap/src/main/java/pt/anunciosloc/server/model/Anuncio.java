package pt.anunciosloc.server.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;
import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlRootElement;

@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD)
public class Anuncio implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String id;
    private String conteudo;
    private LocalDateTime dataCriacao;
    private String autorEmail;
    private String local;
    private int totalEntregas;
    
    public Anuncio() {
        this.id = UUID.randomUUID().toString();
        this.dataCriacao = LocalDateTime.now();
        this.totalEntregas = 0;
    }
    
    public Anuncio(String conteudo, String autorEmail, String local) {
        this();
        this.conteudo = conteudo;
        this.autorEmail = autorEmail;
        this.local = local;
    }
    
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getConteudo() { return conteudo; }
    public void setConteudo(String conteudo) { this.conteudo = conteudo; }
    
    public LocalDateTime getDataCriacao() { return dataCriacao; }
    public void setDataCriacao(LocalDateTime dataCriacao) { this.dataCriacao = dataCriacao; }
    
    public String getAutorEmail() { return autorEmail; }
    public void setAutorEmail(String autorEmail) { this.autorEmail = autorEmail; }
    
    public String getLocal() { return local; }
    public void setLocal(String local) { this.local = local; }
    
    public int getTotalEntregas() { return totalEntregas; }
    public void setTotalEntregas(int totalEntregas) { this.totalEntregas = totalEntregas; }
    
    public void incrementarEntregas() { this.totalEntregas++; }
}