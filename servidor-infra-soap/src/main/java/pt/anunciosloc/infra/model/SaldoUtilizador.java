package pt.anunciosloc.infra.model;

import java.io.Serializable;
import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlRootElement;

@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD)
public class SaldoUtilizador implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String email;
    private int saldo;
    
    public SaldoUtilizador() {}
    
    public SaldoUtilizador(String email, int saldo) {
        this.email = email;
        this.saldo = saldo;
    }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public int getSaldo() { return saldo; }
    public void setSaldo(int saldo) { this.saldo = saldo; }
}