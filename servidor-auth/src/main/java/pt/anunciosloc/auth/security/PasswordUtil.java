package pt.anunciosloc.auth.security;

import java.security.MessageDigest;

public class PasswordUtil {

    public static String hash(String password) {
        return sha256(password);
    }

    public static boolean verify(String password, String hash) {
        return sha256(password).equalsIgnoreCase(hash);
    }

    private static String sha256(String base) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(base.getBytes("UTF-8"));

            StringBuilder hexString = new StringBuilder();

            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }

            return hexString.toString();
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }
}