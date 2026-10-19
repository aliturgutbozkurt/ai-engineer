#import "/template.typ": *

#show: doc => setup_book(title: "Ders 58: MAANG AI Sistem Tasarımı Mülakatında 45 Dakikalık Zaman Çizelgesi", doc)

#lesson_header(
  58,
  "MAANG AI Sistem Tasarımı Mülakatında 45 Dakikalık Zaman Çizelgesi",
  "The 45-Minute MAANG AI System Design Interview Blueprint: Whiteboard Pacing",
  "AI Güvenliği, Gözlemlenebilirlik & MAANG Mülakat Ustalığı",
  "AI Security, Observability & The MAANG Interview Mastery Rubric"
)

#diagram_box[
```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                 MAANG AI SYSTEM DESIGN 45-MINUTE WHITEBOARD PACING          │
└─────────────────────────────────────────────────────────────────────────────┘
  [0-5 min]       [5-15 min]           [15-30 min]          [30-45 min]
 ┌──────────┐    ┌──────────────┐     ┌──────────────┐     ┌───────────────┐
 │ STEP 1   │───▶│ STEP 2       │────▶│ STEP 3       │────▶│ STEP 4        │
 │ Clarify  │    │ High-Level   │     │ AI Core Deep │     │ Trade-Offs    │
 │ Scope &  │    │ Architecture │     │ Dive & RAG   │     │ Cost, Safety  │
 │ Metrics  │    │ & Ingestion  │     │ & Tools      │     │ & Scale       │
 └──────────┘    └──────────────┘     └──────────────┘     └───────────────┘
  • DAU / QPS     • Ingestion ETL      • Chunking & Index   • Hallucination
  • TTFT & Cost   • Vector Store       • Reranking & Model  • Prompt Injection
  • Precision     • Orchestrator API   • Streaming & Cache  • Model Fallbacks
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      45 dakikalık bir MAANG mülakatı Formula 1 yarışına benzer: Pit-stop sürenizi iyi ayarlayamazsanız yarış biter! İlk 5 dakikada hemen tahtaya kutular çizmeye başlarsanız duvara toslarsınız. Önce mülakatçıya sorular sorup yarışı planlarsınız (Scope). Sonra sistemin ana haritasını çizersiniz (High-Level). Ardından asıl uzmanlığınızı gösterip motorun (RAG, Vektörler, Ajanlar) içini açıp incelersiniz (Deep Dive). En son da araba kaza yaparsa ne olacağını (Güvenlik, Hata, Maliyet) anlatıp çizgiyi birinci bitirirsiniz!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[A 45-minute MAANG system design round is like a Formula 1 Grand Prix: reckless pacing causes a terminal crash. Diving immediately into drawing vector database boxes guarantees immediate rejection. You pace the session systematically: clarify ambiguity and SLA numbers (Step 1), construct the macro-architecture (Step 2), deep-dive into the critical AI engine components (Step 3), and stress-test trade-offs under scale, failure, and adversarial attacks (Step 4)!]
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
      45 Dakikanın Altın Zaman Yönetimi: 1) Dakika 0-5 (Kapsam & Metrikler): Fonksiyonel (Hangi sorular yanıtlanacak?) ve Non-Fonksiyonel (QPS, TTFT \< 300ms, P99 \< 2s, Bütçe sınırı, Hallucination \< %2). 2) Dakika 5-15 (Yüksek Seviye Mimari): Ingestion Pipeline (Kafka, Tika, Splitter), Vector DB (pgvector/Pinecone), AI Gateway (Spring AI/Java 25) ve Model (GPT-4o). 3) Dakika 15-30 (Derinlemesine İnceleme): Chunking stratejisi (500 token recursive + overlap), Hibrit arama (RRF), Re-ranking ve Tool calling akışı. 4) Dakika 30-45 (Darboğazlar & Staff+ Savunusu): Prompt Caching, HitL onayı, Token budgeting ve Prompt Injection koruması.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[The 45-Minute Execution Playbook: 1) Min 0-5 (Clarification & SLA Bounds): Functional bounds (domain corpus, languages) vs Non-Functional metrics (1,000 QPS, TTFT \< 300ms, target P99 \< 1,500ms, cost ceiling \$0.005/query, faithfulness >= 98%). 2) Min 5-15 (High-Level Topology): Diagram data ingestion, decoupled vector stores, orchestrator microservices, and client streaming gateways. 3) Min 15-30 (Deep Dive): Drill down into the hardest component: recursive chunking, hybrid dense/sparse indexing, cross-encoder rerankers, and deterministic tool schemas. 4) Min 30-45 (Staff+ Hardening): Address single-points-of-failure, model provider outages (fallback routers), prompt injection, and continuous evaluation in CI/CD.]
    ]
  )
]

#java25_box[
```java
// Java 25: MAANG Mülakat Metrikleri ve SLA Sözleşmesi Modeli
public record MaangInterviewSlaContract(
    String systemName,
    int targetQps,
    int maxTtftMillis,
    double maxCostPerQueryUsd,
    double targetFaithfulness
) {
    public static MaangInterviewSlaContract createDefault() {
        return new MaangInterviewSlaContract(
            "Enterprise Knowledge Copilot",
            500,    // 500 QPS zirve trafik
            250,    // TTFT < 250ms
            0.004,  // İstek başı $0.004 bütçe tavanı
            0.98    // %98 Sadakat (Minimum halüsinasyon)
        );
    }
}

void main() {
    var sla = MaangInterviewSlaContract.createDefault();
    IO.println("=== MAANG AI Mülakat Hedef SLA Tablosu ===");
    IO.println("Sistem: " + sla.systemName());
    IO.println("Hedef QPS: " + sla.targetQps() + " req/sec");
    IO.println("Hedef TTFT: " + sla.maxTtftMillis() + " ms");
    IO.println("Maksimum Maliyet: $" + sla.maxCostPerQueryUsd());
    IO.println("Hedef Sadakat Skoru: %" + (int)(sla.targetFaithfulness() * 100));
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
      En Yaygın Hata: Mülakatçıyla konuşmadan sessizce tahtaya çizim yapmaktır. Mülakat bir monolog veya sınav değil; gelecekteki iş arkadaşınızla yaptığınız mimari bir beyin fırtınasıdır (Collaborative Dialogue). Her kararınızı ('Burada pgvector seçiyorum çünkü...') sesli olarak gerekçelendirin.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[The Silent Monologue Failure: Working in absolute silence while frantically sketching boxes on the whiteboard. A system design round is an interactive engineering collaboration. Always narrate your trade-offs aloud: 'I am opting for PostgreSQL pgvector here over Pinecone because our query volume is sub-1M vectors and we require ACID joins with user ACL tables.']
    ]
  )
]

#takeaways_box((
    ("İlk 5 dakikayı mutlaka gereksinimleri netleştirmeye ve QPS/TTFT sayılarını belirlemeye ayırın.", "Devote the first 5 minutes strictly to scope clarification and non-functional SLA targets."),
    ("Mimariyi basitten başlatın; ardından ölçek, gecikme ve güvenlik katmanlarıyla derinleştirin.", "Start with an intuitive baseline architecture, then evolve it under scale and security pressure."),
    ("Mülakat boyunca her seçimin ardındaki 'Trade-off'u mutlaka sesli olarak ifade edin.", "Articulate the precise trade-offs behind every vector store, model, and chunking decision."),
))
