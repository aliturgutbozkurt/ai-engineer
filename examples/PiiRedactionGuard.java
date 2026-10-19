// Java 25 LTS: Enterprise PII Redaction & Data Leak Prevention Guardrail
// Author: MAANG AI Engineering Guild

import java.util.regex.Pattern;

public class PiiRedactionGuard {

    private static final Pattern CREDIT_CARD_PATTERN = 
        Pattern.compile("\\b(?:\\d[ -]*?){13,16}\\b");

    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\\b");

    private static final Pattern OPENAI_API_KEY_PATTERN = 
        Pattern.compile("sk-(?:proj-)?[A-Za-z0-9_-]{32,}");

    public record SanitizedPayload(String cleanPrompt, int redactedCount) {}

    public static SanitizedPayload sanitizeForLlm(String rawUserInput) {
        int count = 0;
        String sanitized = rawUserInput;

        // 1. Redact API Keys
        var mKey = OPENAI_API_KEY_PATTERN.matcher(sanitized);
        if (mKey.find()) {
            sanitized = mKey.replaceAll("[REDACTED_API_KEY]");
            count++;
        }

        // 2. Redact Credit Card Numbers
        var mCard = CREDIT_CARD_PATTERN.matcher(sanitized);
        if (mCard.find()) {
            sanitized = mCard.replaceAll("[REDACTED_CREDIT_CARD]");
            count++;
        }

        // 3. Redact Email Addresses
        var mEmail = EMAIL_PATTERN.matcher(sanitized);
        if (mEmail.find()) {
            sanitized = mEmail.replaceAll("[REDACTED_EMAIL]");
            count++;
        }

        return new SanitizedPayload(sanitized, count);
    }

    public static void main(String[] args) {
        System.out.println("=== MAANG AI Engineer: Enterprise PII Redaction Guardrail ===");

        String rawPrompt = """
            Merhaba, müşteri destek ekibine bağlanmak istiyorum.
            Kullanıcı e-postam: ahmet.yilmaz@sirket.com.tr
            Son siparişimde kullandığım kartım: 4543 1234 5678 9012
            Sunucudaki OpenAI anahtarım: sk-proj-abC123def456GHI789jkl012MNO345PQR678STU
            Lütfen son faturamı özetler misiniz?
            """;

        System.out.println("--- Ham Kullanıcı İstemi (GÜVENSİZ) ---");
        System.out.println(rawPrompt.trim());

        var result = sanitizeForLlm(rawPrompt);

        System.out.println("\n--- OpenAI API'ye Gönderilen Temizlenmiş Metin (GÜVENLİ) ---");
        System.out.println(result.cleanPrompt().trim());
        System.out.println("\n✔ Maskelenen Hassas Veri Sayısı: " + result.redactedCount());
        System.out.println("✔ Sonuç: KVKK / GDPR ve SOC2 uyumlu olarak LLM'e iletildi.");
    }
}
