package pt.anunciosloc.shared;

import java.io.Serializable;

public class LoginResponse implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String accessToken;
    private String refreshToken;
    private String email;
    private double saldo;
    
    public LoginResponse() {}
    
    public LoginResponse(String accessToken, String refreshToken, String email, double saldo) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        this.email = email;
        this.saldo = saldo;
    }
    
    public String getAccessToken() { return accessToken; }
    public void setAccessToken(String accessToken) { this.accessToken = accessToken; }
    
    public String getRefreshToken() { return refreshToken; }
    public void setRefreshToken(String refreshToken) { this.refreshToken = refreshToken; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public double getSaldo() { return saldo; }
    public void setSaldo(double saldo) { this.saldo = saldo; }
}