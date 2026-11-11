package com.cybershield.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.security.SecureRandom;

/**
 * Synchronizer-token CSRF protection.
 */
public final class CsrfUtil {

    public static final String SESSION_ATTRIBUTE = "csrfToken";
    public static final String PARAMETER = "csrfToken";

    private static final SecureRandom RANDOM = new SecureRandom();

    private CsrfUtil() {
    }

    public static String getToken(HttpSession session) {
        if (session == null) {
            return "";
        }
        Object existing = session.getAttribute(SESSION_ATTRIBUTE);
        if (existing instanceof String && !((String) existing).isEmpty()) {
            return (String) existing;
        }
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        StringBuilder token = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            token.append(String.format("%02x", b));
        }
        String value = token.toString();
        session.setAttribute(SESSION_ATTRIBUTE, value);
        return value;
    }

    public static boolean isValid(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        Object expected = session.getAttribute(SESSION_ATTRIBUTE);
        String supplied = request.getParameter(PARAMETER);
        return expected instanceof String
                && supplied != null
                && constantTimeEquals((String) expected, supplied);
    }

    private static boolean constantTimeEquals(String a, String b) {
        if (a.length() != b.length()) {
            return false;
        }
        int result = 0;
        for (int i = 0; i < a.length(); i++) {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        return result == 0;
    }
}
