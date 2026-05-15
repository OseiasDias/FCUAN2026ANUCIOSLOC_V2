package pt.anunciosloc.server.model;

import java.io.Serializable;
import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlRootElement;

@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD)
public class Infraestrutura implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String nome;
    private double latitude;
    private double longitude;
    private int capacidade;
    private String url;
    
    public Infraestrutura() {}
    
    public Infraestrutura(String nome, double latitude, double longitude, int capacidade, String url) {
        this.nome = nome;
        this.latitude = latitude;
        this.longitude = longitude;
        this.capacidade = capacidade;
        this.url = url;
    }
    
    // Getters e Setters (mantém os que já tens)
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    
    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }
    
    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }
    
    public int getCapacidade() { return capacidade; }
    public void setCapacidade(int capacidade) { this.capacidade = capacidade; }
    
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
}