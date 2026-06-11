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
    
    // Construtor padrao
    public Anuncio() {
        this.id = UUID.randomUUID().toString();
        this.dataCriacao = LocalDateTime.now();
        this.dataExpiracao = LocalDateTime.now().plusDays(30);
        this.totalVisualizacoes = 0;
        this.activo = true;
        this.custoAnuncio = 5.0;
    }
    
    // Construtor para compatibilidade com codigo antigo
    public Anuncio(String conteudo, String autorEmail, String local) {
        this();
        this.titulo = "Anuncio em " + local;
        this.descricao = conteudo;
        this.autorEmail = autorEmail;
        this.local = local;
    }
    
    // Construtor completo
    public Anuncio(String titulo, String descricao, String autorEmail, String local) {
        this();
        this.titulo = titulo;
        this.descricao = descricao;
        this.autorEmail = autorEmail;
        this.local = local;
    }
    
    // Construtor com data de expiracao personalizada
    public Anuncio(String titulo, String descricao, String autorEmail, String local, LocalDateTime dataExpiracao) {
        this(titulo, descricao, autorEmail, local);
        this.dataExpiracao = dataExpiracao;
    }
    
    // Getters e Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    
    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
    
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
    
    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }
    
    public double getCustoAnuncio() { return custoAnuncio; }
    public void setCustoAnuncio(double custoAnuncio) { this.custoAnuncio = custoAnuncio; }
    
    // Metodo para compatibilidade com codigo antigo
    public String getConteudo() { return descricao; }
    public void setConteudo(String conteudo) { 
        this.descricao = conteudo;
        if (this.titulo == null && conteudo != null) {
            this.titulo = conteudo.length() > 100 ? conteudo.substring(0, 100) : conteudo;
        }
    }
    
    // Metodo para compatibilidade
    public int getTotalEntregas() { return totalVisualizacoes; }
    public void setTotalEntregas(int totalEntregas) { this.totalVisualizacoes = totalEntregas; }
    
    // Metodos de utilidade
    public boolean isExpirado() {
        return LocalDateTime.now().isAfter(dataExpiracao);
    }
    
    public void incrementarVisualizacoes() {
        this.totalVisualizacoes++;
    }
    
    public void incrementarEntregas() {
        this.totalVisualizacoes++;
    }
    
    @Override
    public String toString() {
        return "[" + dataCriacao + "] " + titulo + ": " + descricao + " (" + local + ")";
    }
}