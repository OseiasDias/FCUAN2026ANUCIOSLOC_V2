package pt.anunciosloc.shared;

import java.io.Serializable;
import java.time.LocalDateTime;
import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlRootElement;

@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD)
public class Ticket implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String ticketId;
    private String clienteEmail;
    private String chaveSessao;
    private LocalDateTime emissao;
    private LocalDateTime expiracao;
    
    public Ticket() {}
    
    public Ticket(String clienteEmail, String chaveSessao, int duracaoSegundos) {
        this.ticketId = java.util.UUID.randomUUID().toString();
        this.clienteEmail = clienteEmail;
        this.chaveSessao = chaveSessao;
        this.emissao = LocalDateTime.now();
        this.expiracao = this.emissao.plusSeconds(duracaoSegundos);
    }
    
    public String getTicketId() { return ticketId; }
    public void setTicketId(String ticketId) { this.ticketId = ticketId; }
    
    public String getClienteEmail() { return clienteEmail; }
    public void setClienteEmail(String clienteEmail) { this.clienteEmail = clienteEmail; }
    
    public String getChaveSessao() { return chaveSessao; }
    public void setChaveSessao(String chaveSessao) { this.chaveSessao = chaveSessao; }
    
    public LocalDateTime getEmissao() { return emissao; }
    public void setEmissao(LocalDateTime emissao) { this.emissao = emissao; }
    
    public LocalDateTime getExpiracao() { return expiracao; }
    public void setExpiracao(LocalDateTime expiracao) { this.expiracao = expiracao; }
    
    public boolean isValid() {
        return LocalDateTime.now().isBefore(expiracao);
    }
}