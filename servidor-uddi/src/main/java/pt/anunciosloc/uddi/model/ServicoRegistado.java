package pt.anunciosloc.uddi.model;

import java.io.Serializable;
import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlRootElement;

@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD)
public class ServicoRegistado implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String nome;
    private String url;
    private String tipo;  // "INFRAESTRUTURA" ou "PRINCIPAL"
    private String localizacao;  // opcional: onde está a infraestrutura
    private double latitude;
    private double longitude;
    private boolean ativo;
    
    public ServicoRegistado() {}
    
    public ServicoRegistado(String nome, String url, String tipo, String localizacao, double latitude, double longitude) {
        this.nome = nome;
        this.url = url;
        this.tipo = tipo;
        this.localizacao = localizacao;
        this.latitude = latitude;
        this.longitude = longitude;
        this.ativo = true;
    }
    
    // Getters e Setters
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
    
    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }
    
    public String getLocalizacao() { return localizacao; }
    public void setLocalizacao(String localizacao) { this.localizacao = localizacao; }
    
    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }
    
    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }
    
    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { this.ativo = ativo; }
}