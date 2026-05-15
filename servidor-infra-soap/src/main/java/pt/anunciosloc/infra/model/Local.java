package pt.anunciosloc.infra.model;

import java.io.Serializable;
import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlRootElement;

@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD)
public class Local implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String nome;
    private String tipo;
    private double latitude;
    private double longitude;
    private double raio;
    
    public Local() {}
    
    public Local(String nome, String tipo, double latitude, double longitude, double raio) {
        this.nome = nome;
        this.tipo = tipo;
        this.latitude = latitude;
        this.longitude = longitude;
        this.raio = raio;
    }
    
    // Getters e Setters
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    
    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }
    
    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }
    
    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }
    
    public double getRaio() { return raio; }
    public void setRaio(double raio) { this.raio = raio; }
}