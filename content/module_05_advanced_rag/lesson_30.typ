#import "/template.typ": *

#show: doc => setup_book(title: "Ders 30: RAG Triad Otomasyonu: RAGAS Metodolojisi & LLM-as-a-Judge Mimarisi", doc)

#lesson_header(
  30,
  "RAG Triad Otomasyonu: RAGAS Metodolojisi & LLM-as-a-Judge Mimarisi",
  "Automated RAG Evaluation: RAGAS Framework & Implementing LLM-as-a-Judge",
  "İleri Düzey RAG (Advanced RAG) & Bilgi Getirme Optimizasyonu",
  "Advanced RAG & Information Retrieval Optimization"
)

#diagram_box[
```text
   [ RAG Pipeline Çıktısı ] ──▶ (Soru, Bağlam, Üretilen Yanıt)
                                      │
                                      ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │                     LLM-AS-A-JUDGE HAKEM MOTORU (GPT-4o)               │
   │                                                                        │
   │  Hakem Prompt'u:                                                       │
   │  "Sen tarafsız bir denetçisin. Aşağıdaki Yanıtın iddialarını           │
   │   Bağlam ile kıyasla. Her iddiayı [DOĞRULANDI] veya [HALÜSİNASYON]    │
   │   olarak etiketle. 1-5 arası puan ve JSON raporu üret."                │
   └──────────────────────────────────┬─────────────────────────────────────┘
                                      │
                                      ▼
   [ DEĞERLENDİRME RAPORU ] ──▶ Faithfulness: 5/5, Grounded: TRUE, CI/CD Gate: PASS
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir okulda 10.000 öğrencinin yazdığı kompozisyonları tek bir öğretmenin sabahlara kadar tek tek okuyup puanlaması imkansızdır (İnsanla değerlendirme çok yavaştır). Bunun yerine kıdemli bir başöğretmene (LLM-as-a-Judge) bir puanlama anahtarı verirsiniz: 'Şu 3 kurala bak, 1 ile 5 arasında not ver, nerede hata varsa altına yaz.' Başöğretmen her gece tüm ödevleri inceler ve sabah not çizelgesini masanıza koyar! LLM-as-a-Judge, yapay zekayı yapay zekaya denetleterek sistem kalitesini her kod gönderildiğinde (CI/CD) otomatik ölçmektir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Evaluating 100,000 production customer responses cannot be done manually by human reviewers (human annotation is slow and unscalable). Instead, you employ an impartial Senior Inspector model (LLM-as-a-Judge) armed with an invariant grading rubric: 'Deconstruct the response into individual claims. Cross-verify each claim against the retrieved snippet. Output a structured JSON audit with a score from 1 to 5.' LLM-as-a-Judge runs automatically inside your CI/CD test suite on every pull request!]
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
      LLM-as-a-Judge Mimarisi ve İstatistiki Yanlılıklar: 1) Hakem Önyargıları (Biases): a) Position Bias (İlk seçeneği üstün tutma). b) Verbosity Bias (Uzun ve süslü yanıtları daha kaliteli sanma). c) Self-Enhancement Bias (Modelin kendi ürettiği metinlere daha yüksek puan vermesi). 2) İki Taraflı Değerlendirme (Pairwise Evaluation with Swap): Seçeneklerin sırası ters çevrilerek hakeme iki kez sorulur; sadece iki seferde de aynı karar çıkarsa puan geçerli sayılır. 3) CI/CD Entegrasyonu: GitHub Actions üzerinde her PR açıldığında 50 adet altın soru (Gold Evaluation Dataset) test edilir; sadakat skoru %95'in altına düşerse PR kilitlenir!
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[LLM-as-a-Judge Vulnerabilities & CI/CD Gating: 1) Cognitive Judge Biases: a) Verbosity Bias: Models favor longer, eloquently worded responses regardless of precision. b) Position Bias: Predisposition to score Option A higher than Option B in pairwise tests. Countermeasure: execute bidirectional swaps (\$A/B\$ and \$B/A\$). c) Self-Preference Bias: GPT-4 exhibits affinity for GPT-generated prose over Claude or Llama. 2) CI/CD Automation: Run automated evaluation pipelines against a fixed 100-question Golden Dataset on every pull request. If regression drops Faithfulness below 95%, the deployment pipeline aborts.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: LLM-as-a-Judge ile Otomatik RAG Hakem Servisi
import org.springframework.ai.chat.client.ChatClient;

public class RagJudgeEvaluator {
    private final ChatClient judgeChatClient;

    public record EvaluationVerdict(double faithfulnessScore, String critique, boolean passed) {}

    public RagJudgeEvaluator(ChatClient.Builder builder) {
        this.judgeChatClient = builder.build();
    }

    public EvaluationVerdict auditRagResponse(String query, String context, String generatedAnswer) {
        return judgeChatClient.prompt()
            .system("""
                Sen MAANG seviyesinde katı bir yapay zeka denetçisisin.
                Görevin: Verilen Yanıt'ın SADECE ve SADECE Bağlam'daki bilgilere dayanıp dayanmadığını doğrulamak.
                Eğer yanıtta bağlamda geçmeyen tek bir iddia bile varsa faithfulnessScore < 0.50 olmalı ve passed = false dönmelidir.
                """)
            .user(u -> u.text("""
                SORU: {query}
                BAĞLAM: {context}
                ÜRETİLEN YANIT: {answer}
                """)
                .param("query", query)
                .param("context", context)
                .param("answer", generatedAnswer))
            .call()
            .entity(EvaluationVerdict.class);
    }
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
      Hakem Modeli Kuralı: Küçük modeller (GPT-4o-mini) karmaşık mantıksal denetimlerde hakemlik yapamaz; ince halüsinasyonları gözden kaçırır! Hakem modeli olarak DAİMA en zeki amiral gemisi model (GPT-4o veya o1) kullanılmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Judge capacity requirement: Never use miniature tier models (e.g. gpt-4o-mini) as judges. Sub-parameter models lack the cognitive reasoning required to identify subtle factual inconsistencies. The Judge model must strictly be Tier-1 (GPT-4o, Claude 3.5 Sonnet, or o1).]
    ]
  )
]

#takeaways_box((
    ("LLM-as-a-Judge, yüz binlerce RAG çıktısını otomatik ve ölçeklenebilir biçimde denetler.", "LLM-as-a-Judge scales quality assurance across millions of RAG interactions cost-effectively."),
    ("Hakem önyargılarını (Verbosity ve Position bias) kırmak için çift yönlü testler şarttır.", "Counteract verbosity and position biases via pairwise order swaps."),
    ("Altın test veri setleri (Golden Datasets) ile CI/CD pipeline'larında regresyonlar engellenir.", "Embedding evaluation suites in CI/CD ensures new prompts do not cause quality regressions."),
))
