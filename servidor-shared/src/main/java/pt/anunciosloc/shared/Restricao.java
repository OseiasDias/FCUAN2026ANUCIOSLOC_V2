package pt.anunciosloc.shared;

import java.io.Serializable;
import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlRootElement;

@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD)
public class Restricao implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private Long id;
    private Long anuncioId;
    private String tipo;
    private String chave;
    private String valor;
    
    public Restricao() {}
    
    public Restricao(Long anuncioId, String tipo, String chave, String valor) {
        this.anuncioId = anuncioId;
        this.tipo = tipo;
        this.chave = chave;
        this.valor = valor;
    }
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Long getAnuncioId() { return anuncioId; }
    public void setAnuncioId(Long anuncioId) { this.anuncioId = anuncioId; }
    
    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }
    
    public String getChave() { return chave; }
    public void setChave(String chave) { this.chave = chave; }
    
    public String getValor() { return valor; }
    public void setValor(String valor) { this.valor = valor; }
}