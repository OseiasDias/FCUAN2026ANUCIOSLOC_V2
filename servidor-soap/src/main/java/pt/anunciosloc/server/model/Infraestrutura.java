package pt.anunciosloc.server.model;

import java.io.Serializable;

public class Infraestrutura implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String nome;
    private String localizacao;
    private double latitude;
    private double longitude;
    private int capacidade;
    private String url;
    private int utilizadoresConectados;
    private int totalAnuncios;
    private int totalEntregas;
    private String criadorEmail;      // ← NOVO CAMPO!
    private boolean ativo;
    
    public Infraestrutura() {}
    
    // Construtor completo
    public Infraestrutura(String nome, double latitude, double longitude, int capacidade, String url, String criadorEmail) {
        this.nome = nome;
        this.localizacao = null; // ou passado no construtor
        this.latitude = latitude;
        this.longitude = longitude;
        this.capacidade = capacidade;
        this.url = url;
        this.criadorEmail = criadorEmail;
        this.ativo = true;
        this.totalAnuncios = 0;
        this.totalEntregas = 0;
        this.utilizadoresConectados = 0;
    }

    
    
    // Getters e Setters
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    
    public String getLocalizacao() { return localizacao; }
    public void setLocalizacao(String localizacao) { this.localizacao = localizacao; }
    
    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }
    
    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }
    
    public int getCapacidade() { return capacidade; }
    public void setCapacidade(int capacidade) { this.capacidade = capacidade; }
    
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
    
    public int getUtilizadoresConectados() { return utilizadoresConectados; }
    public void setUtilizadoresConectados(int utilizadoresConectados) { 
        this.utilizadoresConectados = utilizadoresConectados; 
    }
    
    public int getTotalAnuncios() { return totalAnuncios; }
    public void setTotalAnuncios(int totalAnuncios) { 
        this.totalAnuncios = totalAnuncios; 
    }
    
    public int getTotalEntregas() { return totalEntregas; }
    public void setTotalEntregas(int totalEntregas) { 
        this.totalEntregas = totalEntregas; 
    }
    
    public String getCriadorEmail() { return criadorEmail; }
    public void setCriadorEmail(String criadorEmail) { this.criadorEmail = criadorEmail; }
    
    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { this.ativo = ativo; }
}