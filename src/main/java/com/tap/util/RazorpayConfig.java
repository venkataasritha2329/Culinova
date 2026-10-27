
package com.tap.util;

public final class RazorpayConfig {

    private RazorpayConfig() {
        // Prevent object creation.
    }

    // Read the Razorpay Test Mode Key ID from Tomcat VM arguments.
    public static String getKeyId() {
        return System.getProperty("RAZORPAY_TEST_KEY_ID");
    }

    // Read the Razorpay Test Mode Key Secret from Tomcat VM arguments.
    public static String getKeySecret() {
        return System.getProperty("RAZORPAY_TEST_KEY_SECRET");
    }

    // Check whether both credentials are available.
    public static boolean isConfigured() {
        String keyId = getKeyId();
        String keySecret = getKeySecret();

        return keyId != null && !keyId.isBlank()
                && keySecret != null && !keySecret.isBlank();
    }

    // Validate configuration and print safe diagnostic messages.
    public static void validate() {
        String keyId = getKeyId();
        String keySecret = getKeySecret();

        boolean keyIdAvailable =
                keyId != null && !keyId.isBlank();

        boolean keySecretAvailable =
                keySecret != null && !keySecret.isBlank();

        System.out.println(
                "Razorpay Key ID available: " + keyIdAvailable);

        System.out.println(
                "Razorpay Key Secret available: " + keySecretAvailable);

        if (!keyIdAvailable || !keySecretAvailable) {
            throw new IllegalStateException(
                    "Razorpay Test Mode configuration is missing.");
        }
    }
}
