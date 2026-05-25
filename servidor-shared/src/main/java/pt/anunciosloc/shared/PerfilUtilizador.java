package pt.anunciosloc.shared;

import java.io.Serializable;
import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlRootElement;

@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD)
public class PerfilUtilizador implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private Long id;
    private Long utilizadorId;
    private String chavePerfil;
    private String valorPerfil;
    
    public PerfilUtilizador() {}
    
    public PerfilUtilizador(Long utilizadorId, String chavePerfil, String valorPerfil) {
        this.utilizadorId = utilizadorId;
        this.chavePerfil = chavePerfil;
        this.valorPerfil = valorPerfil;
    }
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Long getUtilizadorId() { return utilizadorId; }
    public void setUtilizadorId(Long utilizadorId) { this.utilizadorId = utilizadorId; }
    
    public String getChavePerfil() { return chavePerfil; }
    public void setChavePerfil(String chavePerfil) { this.chavePerfil = chavePerfil; }
    
    public String getValorPerfil() { return valorPerfil; }
    public void setValorPerfil(String valorPerfil) { this.valorPerfil = valorPerfil; }
}