package pt.anunciosloc.shared;

import java.io.Serializable;
import java.util.Date;

public class Ticket implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String ticketId;
    private String clienteEmail;
    private Date validade;
    
    public Ticket() {}
    
    public Ticket(String ticketId, String clienteEmail, Date validade) {
        this.ticketId = ticketId;
        this.clienteEmail = clienteEmail;
        this.validade = validade;
    }
    
    // ==================== GETTERS E SETTERS ====================
    
    public String getTicketId() {
        return ticketId;
    }
    
    public void setTicketId(String ticketId) {
        this.ticketId = ticketId;
    }
    
    public String getClienteEmail() {
        return clienteEmail;
    }
    
    public void setClienteEmail(String clienteEmail) {
        this.clienteEmail = clienteEmail;
    }
    
    public Date getValidade() {
        return validade;
    }
    
    public void setValidade(Date validade) {
        this.validade = validade;
    }
}