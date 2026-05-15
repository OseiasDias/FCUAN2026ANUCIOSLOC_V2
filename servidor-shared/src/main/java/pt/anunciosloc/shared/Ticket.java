package pt.anunciosloc.shared;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

public class Ticket implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String ticketId;
    private String clienteEmail;
    private String chaveSessao;
    private LocalDateTime validade;
    private boolean ativo;
    
    // Construtor vazio (necessário para JAXB)
    public Ticket() {}
    
    // Construtor com 3 parâmetros (o que estamos a usar)
    public Ticket(String clienteEmail, String chaveSessao, int duracaoSegundos) {
        this.ticketId = UUID.randomUUID().toString();
        this.clienteEmail = clienteEmail;
        this.chaveSessao = chaveSessao;
        this.validade = LocalDateTime.now().plusSeconds(duracaoSegundos);
        this.ativo = true;
    }
    
    // Construtor com 4 parâmetros (alternativo)
    public Ticket(String ticketId, String clienteEmail, String chaveSessao, int duracaoSegundos) {
        this.ticketId = ticketId;
        this.clienteEmail = clienteEmail;
        this.chaveSessao = chaveSessao;
        this.validade = LocalDateTime.now().plusSeconds(duracaoSegundos);
        this.ativo = true;
    }
    
    // Getters e Setters
    public String getTicketId() { return ticketId; }
    public void setTicketId(String ticketId) { this.ticketId = ticketId; }
    
    public String getClienteEmail() { return clienteEmail; }
    public void setClienteEmail(String clienteEmail) { this.clienteEmail = clienteEmail; }
    
    public String getChaveSessao() { return chaveSessao; }
    public void setChaveSessao(String chaveSessao) { this.chaveSessao = chaveSessao; }
    
    public LocalDateTime getValidade() { return validade; }
    public void setValidade(LocalDateTime validade) { this.validade = validade; }
    
    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { this.ativo = ativo; }
    
    public boolean isValid() {
        return ativo && LocalDateTime.now().isBefore(validade);
    }
}