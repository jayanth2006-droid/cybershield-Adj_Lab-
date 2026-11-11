package com.cybershield.util;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Locale;

public final class FormatUtil {

    private FormatUtil() {
    }

    public static String dateTime(Timestamp value) {
        if (value == null) {
            return "—";
        }
        return new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH)
                .format(value);
    }

    public static String date(Timestamp value) {
        if (value == null) {
            return "—";
        }
        return new SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH)
                .format(value);
    }

    public static String shortText(String value, int max) {
        if (value == null) {
            return "";
        }
        String normalized = value.replaceAll("\\s+", " ").trim();
        if (normalized.length() <= max) {
            return normalized;
        }
        return normalized.substring(0, Math.max(0, max - 1)) + "…";
    }

    public static String statusLabel(String status) {
        if (status == null) {
            return "UNKNOWN";
        }
        switch (status) {
            case "IN_PROGRESS":
                return "In Progress";
            default:
                return status.charAt(0)
                        + status.substring(1).toLowerCase(Locale.ENGLISH);
        }
    }

    public static String cssToken(String value) {
        return value == null ? "unknown"
                : value.toLowerCase(Locale.ENGLISH).replace('_', '-');
    }
}
