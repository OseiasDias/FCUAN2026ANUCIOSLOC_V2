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
    private String titulo;
    private String descricao;
    private LocalDateTime dataCriacao;
    private LocalDateTime dataExpiracao;
    private String autorEmail;
    private String local;
    private int totalVisualizacoes;
    private boolean activo;
    private double custoAnuncio;
    
    public Anuncio() {
        this.id = UUID.randomUUID().toString();
        this.dataCriacao = LocalDateTime.now();
        this.dataExpiracao = this.dataCriacao.plusDays(30);
        this.totalVisualizacoes = 0;
        this.activo = true;
        this.custoAnuncio = 5.0;
    }
    
    public Anuncio(String conteudo, String autorEmail, String local) {
        this();
        this.titulo = conteudo.length() > 150 ? conteudo.substring(0, 150) : conteudo;
        this.descricao = conteudo;
        this.autorEmail = autorEmail;
        this.local = local;
    }
    
    public Anuncio(String titulo, String descricao, String autorEmail, String local) {
        this();
        this.titulo = titulo;
        this.descricao = descricao;
        this.autorEmail = autorEmail;
        this.local = local;
    }
    
    public Anuncio(String titulo, String descricao, String autorEmail, String local, LocalDateTime dataExpiracao) {
        this(titulo, descricao, autorEmail, local);
        this.dataExpiracao = dataExpiracao;
    }
    
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    
    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
    
    // Metodos para compatibilidade com codigo antigo
    public String getConteudo() { return descricao; }
    public void setConteudo(String conteudo) { 
        this.descricao = conteudo;
        if (conteudo != null && conteudo.length() > 150) {
            this.titulo = conteudo.substring(0, 150);
        } else if (conteudo != null) {
            this.titulo = conteudo;
        }
    }
    
    public LocalDateTime getDataCriacao() { return dataCriacao; }
    public void setDataCriacao(LocalDateTime dataCriacao) { this.dataCriacao = dataCriacao; }
    
    public LocalDateTime getDataExpiracao() { return dataExpiracao; }
    public void setDataExpiracao(LocalDateTime dataExpiracao) { this.dataExpiracao = dataExpiracao; }
    
    public String getAutorEmail() { return autorEmail; }
    public void setAutorEmail(String autorEmail) { this.autorEmail = autorEmail; }
    
    public String getLocal() { return local; }
    public void setLocal(String local) { this.local = local; }
    
    public int getTotalVisualizacoes() { return totalVisualizacoes; }
    public void setTotalVisualizacoes(int totalVisualizacoes) { this.totalVisualizacoes = totalVisualizacoes; }
    
    // Metodo para compatibilidade
    public int getTotalEntregas() { return totalVisualizacoes; }
    public void setTotalEntregas(int totalEntregas) { this.totalVisualizacoes = totalEntregas; }
    
    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }
    
    public double getCustoAnuncio() { return custoAnuncio; }
    public void setCustoAnuncio(double custoAnuncio) { this.custoAnuncio = custoAnuncio; }
    
    public boolean isExpirado() {
        return LocalDateTime.now().isAfter(dataExpiracao);
    }
    
    public void incrementarVisualizacoes() {
        this.totalVisualizacoes++;
    }
    
    // Metodo para compatibilidade
    public void incrementarEntregas() {
        this.totalVisualizacoes++;
    }
}