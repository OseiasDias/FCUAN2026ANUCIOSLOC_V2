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
    private double saldo;
    private int versao;
    
    public SaldoUtilizador() {}
    
    public SaldoUtilizador(String email, double saldo) {
        this.email = email;
        this.saldo = saldo;
        this.versao = 1;
    }
    
    public SaldoUtilizador(String email, double saldo, int versao) {
        this.email = email;
        this.saldo = saldo;
        this.versao = versao;
    }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public double getSaldo() { return saldo; }
    public void setSaldo(double saldo) { this.saldo = saldo; }
    
    public int getVersao() { return versao; }
    public void setVersao(int versao) { this.versao = versao; }
    
    public void incrementarVersao() { this.versao++; }
}