#import "/template.typ": *

#show: doc => setup_book(title: "Ders 48: Token Budgeting, Sliding Window Truncation ve Maliyet Sınırlandırma", doc)

#lesson_header(
  48,
  "Token Budgeting, Sliding Window Truncation ve Maliyet Sınırlandırma",
  "Token Budgeting, Sliding Window Truncation & Cost Bounding Policies",
  "LLM Performansı, Caching, Maliyet & Gecikme Optimizasyonu",
  "LLM Performance Engineering: Caching, Model Routing & Cost Optimization"
)

#diagram_box[
```text
   [ MAKSİMUM TOKEN BÜTÇESİ: 4000 TOKEN ]
   ┌────────────────────────────────────────────────────────────────────────┐
   │ 1. Sistem Rolü (Sabit)        : 500 Token   [Kesilemez / Korumalı]     │
   │ 2. RAG Bağlamı (Dinamik)      : 2000 Token  [Top 3 Parça ile Sınırlı]  │
   │ 3. Kullanıcı Sorusu           : 300 Token   [Gerekirse budanır]        │
   │ 4. Ayrılan Yanıt Bütçesi      : 1200 Token  [Modelin üretmesine izin]  │
   └──────────────────────────────────┬─────────────────────────────────────┘
                                      │
                                      ▼
   Toplam: 4000 Token ──▶ Sınır Aşımı Yok! Bütçe ve Maliyet %100 Kontrol Altında!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Tatile çıkarken bavulunuzun havayolu sınırı 20 kilodur (Token Bütçesi). Bavulun içine rastgele eşya fırlatırsanız havaalanında ceza ödersiniz. Akıllı bir yolcu bütçeleme yapar: '5 kilo temel giysiler (Sistem Prompt), 8 kilo iş evrakları (RAG Dokümanları), 2 kilo kişisel eşyalar (Kullanıcı Sorusu) ve 5 kilo da tatilden dönerken alacağım hediyelikler için boş yer bırak (Modelin Yanıt Bütçesi)!' Token bütçeleme tam olarak budur: Modelin sınırları aşmasını ve faturanın patlamasını önceden matematiksel olarak garantilemektir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[When boarding a budget flight, your luggage allowance is capped at 20 kilograms (The Token Budget). Tossing random clothes inside incurs steep overweight fees at the gate. A seasoned traveler allocates weight methodically: 5kg for essential clothing (System Prompt), 8kg for work gear (RAG Context), 2kg for toiletries (User Query), leaving a guaranteed 5kg reserve for souvenirs brought home (Completion Token Budget). Token Budgeting calculates and enforces discrete byte-level boundaries before payloads hit the API!]
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
      Token Bütçeleme Mühendisliği: 1) Hard Capping vs Soft Truncation: Prompt gönderilmeden önce BPE tokenizer ile token sayısı hesaplanır (`tiktoken` veya `JTokkit`). Eğer (Tokens_prompt + MaxTokens_gen > Budget) ise, en eski RAG parçası veya sohbet geçmişi dinamik olarak budanır (FIFO Truncation). 2) Asimetrik Rezervasyon: Yanıt için ayrılan `max_tokens` (veya `max_completion_tokens`) asla kısılmamalıdır; aksi takdirde model cümlesinin tam ortasında kesilir (`finish_reason: length`) ve JSON çıktısı bozulur. 3) Bütçe Alarmı: Günlük harcama limiti aşıldığında PagerDuty/Slack alarmı tetiklenmeli ve API otomatik olarak ucuz modele geçmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Token Bounding Mechanics: 1) Pre-Flight Token Counting: Compute exact token counts locally before network dispatch using high-performance tokenizers (e.g. `JTokkit` for Java). 2) Asymmetric Reservation Protocol: The completion budget must remain strictly reserved; choking completion tokens causes mid-sentence cutoff (`finish_reason: length`), corrupting JSON payloads. 3) Dynamic Context Degradation: If a long query breaches budget, shed the lowest-ranked RAG chunk first, then truncate conversation history, never truncating the core system instructions.]
    ]
  )
]

#java25_box[
```java
// Java 25: Sıkı Token Bütçe Yöneticisi (Token Budget Enforcer)
public class TokenBudgetEnforcer {
    private final int totalBudget;
    private final int reservedForCompletion;

    public TokenBudgetEnforcer(int totalBudget, int reservedForCompletion) {
        this.totalBudget = totalBudget;
        this.reservedForCompletion = reservedForCompletion;
    }

    public int getAvailablePromptTokens() {
        return totalBudget - reservedForCompletion;
    }

    public boolean validateBudget(int currentPromptTokens) {
        return currentPromptTokens <= getAvailablePromptTokens();
    }
}

void main() {
    var enforcer = new TokenBudgetEnforcer(4096, 1024); // 4096 toplam, 1024 yanıta ayrıldı
    int promptTokens = 2500;

    IO.println("İzin Verilen Maksimum Prompt Token: " + enforcer.getAvailablePromptTokens());
    IO.println("Bütçe Kontrolü (2500 token): " + (enforcer.validateBudget(promptTokens) ? "✅ GEÇERLİ" : "❌ BÜTÇE AŞILDI"));
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
      JSON Bozulma Tuzağı: Modelden JSON beklerken `max_tokens` değerini çok küçük tutarsanız (ör. 100 token), model JSON'ı kapatamadan kesilir (`{"name": "Ahmet", "stat...`) ve Jackson parser JSONSyntaxException patlatır! JSON çıktılarında completion bütçesi daima cömert tutulmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[JSON truncation disaster: Constraining `max_tokens` too tightly when expecting structured outputs causes the generation to abort mid-object (`{"status": "SUCC...`), yielding malformed JSON that crashes downstream deserializers. Always provision ample completion headroom.]
    ]
  )
]

#takeaways_box((
    ("Token bütçeleme, beklenmeyen fatura patlamalarını ve bağlam aşımını önler.", "Token budgeting prevents unexpected billing spikes and context window overflows."),
    ("Yanıta ayrılan completion token bütçesi JSON bozulmalarını önlemek için daima korunmalıdır.", "Completion token reservations must be safeguarded to avoid truncated JSON payloads."),
    ("Token sınırına yaklaşıldığında sistem promptu değil, en eski RAG parçaları budanmalıdır.", "When shedding tokens, prune low-ranked RAG chunks first, never core system instructions."),
))
