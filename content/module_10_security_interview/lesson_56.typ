#import "/template.typ": *

#show: doc => setup_book(title: "Ders 56: Çıktı Doğrulama ve Hallucination Filtresi (Structured Guardrails)", doc)

#lesson_header(
  56,
  "Çıktı Doğrulama ve Hallucination Filtresi (Structured Guardrails)",
  "Output Guardrails: Output Verification, PII Redaction & Hallucination Suppression",
  "AI Güvenliği, Gözlemlenebilirlik & MAANG Mülakat Ustalığı",
  "AI Security, Observability & The MAANG Interview Mastery Rubric"
)

#diagram_box[
```text
   [ MODEL ÇIKTISI ÜRETİLDİ ] ──▶ "Ali'nin kart no: 4543 9812 3456 7890, Bakiye: 500TL"
                                             │
                                             ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │                   OUTPUT GUARDRAIL PIPELINE (Java 25)                  │
   │                                                                        │
   │  1. PII Redaction Filter ──▶ Regex/NER: Kredi kartını maskele          │
   │                             "Ali'nin kart no: ****-****-****-7890"     │
   │  2. Hallucination Check  ──▶ Factual Consistency (RAG ile teyit et)    │
   │  3. Toxic / Brand Safety ──▶ Şirket itibarını zedeleyecek küfür engeli │
   └──────────────────────────────────┬─────────────────────────────────────┘
                                      │
                                      ▼
   [ TEMİZLENMİŞ GÜVENLİ YANIT ] ──▶ Kullanıcının ekranına güvenle iletilir!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Canlı televizyon yayınlarında küfürlü veya sakıncalı bir durum olduğunda yayını hemen kesebilmek için 7 saniyelik bir gecikme koyarlar (Canlı Yayın Filtresi). Çıktı Doğrulama (Output Guardrail) tam olarak bu filtredir! Model bir cevap ürettiğinde, o cevap doğrudan kullanıcının ekranına düşmez. Önce güvenlik odasından geçer: 'Cevabın içinde kredi kartı veya müşteri TC kimlik numarası sızmış mı?' (PII Redaction), 'Model kafasından uydurma bir sözleşme maddesi mi yazdı?' (Hallucination Check). Temizse onay damgası basılır ve ekrana verilir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Live television broadcasts maintain a mandatory 7-second buffer to dump profanities or inappropriate wardrobe malfunctions before signals reach public homes. Output Guardrails provide this exact defensive buffer for LLMs! When the model finishes token generation, the output is not displayed blindly. It passes through an automated sanitization audit: Are credit card numbers leaking? (PII Redaction), Did the model invent a non-existent company policy? (Hallucination Check). Only sanitized text reaches the user!]
    ]
  )
]

#deep_dive_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("334155"), size: 9pt)[🇹🇷 MAANG DERİNLEMESİNE ANALİZ]\
      #v(3pt)
      Çıktı Güvenliği Katmanları: 1) PII Redaction (Kişisel Veri Maskeleme): Kredi kartı (Luhn algoritması), e-posta, telefon ve TC kimlik numaraları tespit edilerek `****` şeklinde maskelenir. 2) Structural Schema Validation: JSON dönmesi gereken bir modelin çıktısı Jackson/JsonSchema ile doğrulanır; şema bozuksa istemciye 500 hatası gitmez, model sessizce arkada tekrar çağrılır (Self-Healing JSON). 3) Hallucination Suppression: RAG dokümanında geçmeyen tarih ve para miktarları regex ile tespit edilip elenir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Output Guardrail Engineering: 1) Automated PII Redaction: Deterministic regex and NER scanners inspect completions for payment card numbers (validating against the Luhn algorithm), social security numbers, and email patterns, replacing them with tokens (`[REDACTED]`). 2) Self-Healing Schema Validation: If a structured output response fails JSON deserialization, the raw error trace is fed back into a rapid repair prompt to synthesize a corrected payload before throwing runtime errors. 3) Semantic Toxicity & Compliance: Enforce brand and legal boundaries, blocking model-generated liability claims.]
    ]
  )
]

#java25_box[
```java
// Java 25: Hassas Veri (PII) ve Kredi Kartı Maskeleme Filtresi (Output Guardrail)
import java.util.regex.Pattern;

public class PiiRedactionOutputGuard {
    private static final Pattern CREDIT_CARD_PATTERN = Pattern.compile(
        "\\b(?:\\d{4}[ -]?){3}\\d{4}\\b"
    );

    public static String redactSensitiveData(String modelOutput) {
        if (modelOutput == null) return "";
        // Kredi kartı numaralarını maskele: ****-****-****-1234
        return CREDIT_CARD_PATTERN.matcher(modelOutput).replaceAll("****-****-****-XXXX");
    }
}

void main() {
    String rawLlmResponse = "Müşteri ödemeyi tamamladı. Kart: 4532-1234-5678-9012 onaylandı.";
    String sanitized = PiiRedactionOutputGuard.redactSensitiveData(rawLlmResponse);

    IO.println("Ham Model Çıktısı   : " + rawLlmResponse);
    IO.println("Maskelenmiş Güvenli : " + sanitized);
}
```
]

#warning_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("b45309"), size: 9pt)[🇹🇷 MÜLAKAT TUZAĞI VE HALÜSİNASYON]\
      #v(3pt)
      Yasal Sorumluluk Riski: Modelin kullanıcılara 'Tıbbi teşhis' veya 'Kesin hukuki tavsiye' vermesi şirketinizi milyonlarca dolarlık davalarla karşı karşıya bırakabilir. Çıktı filtrelerinde otomatik olarak 'Bu bir yatırım/sağlık tavsiyesi değildir' yasal feragatnamesi (Disclaimer) eklenmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Legal liability vulnerability: Allowing an enterprise model to emit definitive medical diagnoses or binding financial advice triggers severe regulatory and civil liability. Output filters must append automated statutory disclaimers ('This information is advisory only and does not constitute formal financial counsel').]
    ]
  )
]

#takeaways_box((
    ("Model çıktıları asla filtrelenmeden doğrudan son kullanıcıya sunulmamalıdır.", "Never display raw LLM completions directly to users without passing output guardrails."),
    ("Kredi kartı ve kişisel veriler (PII) regex ve Luhn algoritmalarıyla maskelenmelidir.", "PII and financial card data must be scrubbed deterministically via regex and Luhn checks."),
    ("Şema doğrulaması başarısız olursa Self-Healing mekanizması ile model tekrar tetiklenmelidir.", "Failed schema generations should trigger self-healing prompt retries automatically."),
))
