package com.tap.util;

import java.util.Properties;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class EmailUtil {

    public static void sendEmail(String toEmail, String otp) throws Exception {

        final String fromEmail = "CULINOVA_EMAIL";
        final String appPassword = "CULINOVA_EMAIL_APP_PASSWORD";

        Properties properties = new Properties();

        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(properties,
                new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(
                                fromEmail,
                                appPassword
                        );
                    }
                });

        Message message = new MimeMessage(session);

        message.setFrom(new InternetAddress(fromEmail));
        message.setRecipients(
                Message.RecipientType.TO,
                InternetAddress.parse(toEmail)
        );

        message.setSubject("Culinova - Password Reset OTP");

        message.setText(
                "Your Culinova password reset OTP is: " + otp
                + "\n\nThis OTP is valid for 5 minutes."
        );

        Transport.send(message);
    }
}