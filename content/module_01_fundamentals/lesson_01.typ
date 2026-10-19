#import "/template.typ": *

#show: doc => setup_book(title: "Ders 1: AI Engineer vs ML Engineer vs Data Scientist & MAANG Mülakat Beklentileri", doc)

#lesson_header(
  1,
  "AI Engineer vs ML Engineer vs Data Scientist & MAANG Mülakat Beklentileri",
  "AI Engineer vs ML Engineer vs Data Scientist & The MAANG Evaluation Rubric",
  "AI Engineer Rolü, LLM Anatomisi & MAANG Mülakat Çerçevesi",
  "The AI Engineer Role, LLM Anatomy & The MAANG Interview Framework"
)

#diagram_box[
```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                 MAANG AI SPECTRUM: WHERE DOES THE AI ENGINEER FIT?          │
└─────────────────────────────────────────────────────────────────────────────┘
  [DATA SCIENTIST]           [ML ENGINEER]             [AI ENGINEER (YOU!)]
  • Math & Statistics        • PyTorch & CUDA Kernels  • Application Engineering
  • Feature Engineering      • Distributed Training    • RAG, Agents & Tools
  • Jupyter & Pandas         • MLOps & Triton Deploy   • Spring AI / LangChain4j
  • "Which model wins?"      • "How to train faster?"  • "How to build reliable apps?"
 
                           MAANG AI INTERVIEW PILLARS
 ┌───────────────────────┬──────────────────────────┬────────────────────────┐
 │ 1. System Integration │ 2. Context & RAG Mastery │ 3. Evaluation & Safety │
 │ • Low latency stream  │ • Hybrid search (Vector) │ • Hallucination guards │
 │ • Rate limit & cache  │ • Chunking & Rerankers   │ • Human-in-the-Loop    │
 └───────────────────────┴──────────────────────────┴────────────────────────┘
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Eskiden elektrik santralini kuran mühendisler (ML Engineer) ile elektrikle çalışan buzdolabı ve televizyon tasarlayan mühendisler (AI Engineer) birdi. Artık OpenAI, Anthropic ve Google devasa santralleri kurdu! Bir AI Engineer'ın görevi 100 milyon dolarlık model eğitmek değil; o elektrik santraline bağlanıp prizden güvenli, hızlı, patlamayan ve harika çalışan akıllı uygulamalar üretmektir! MAANG mülakatında da size 'transformer katmanının türevini al' demezler; 'Bu LLM'i çökmeyen, halüsinasyon görmeyen kurumsal bir müşteri ajanına nasıl dönüştürürsün?' diye sorarlar!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Historically, the civil engineers building power plants (ML Engineers) and electrical engineers wiring appliances (AI Engineers) were conflated. Today, OpenAI and Google run the multi-billion-dollar power grids! An AI Engineer doesn't train trillion-parameter models from scratch; they orchestrate foundation models into robust, low-latency, hallucination-resistant production systems. In MAANG interviews, you aren't asked to derive backpropagation gradients; you are grilled on fault tolerance, context engineering, RAG latency, and agent loops!]
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
      MAANG AI Engineer rolünün teknik sorumlulukları: 1) Model Orkestrasyonu: Spring AI ve LangChain4j gibi modern enterprise SDK'lar ile LLM çağrılarını soyutlama. 2) Context Engineering: Token penceresini (Context Window) gereksiz veriyle doldurmadan en alakalı RAG parçalarını seçme. 3) Deterministik Çıktılar: Yapılandırılmış JSON şemaları (Structured Outputs) ile arka plan mikroservislerini güvenle besleme. 4) Maliyet & Gecikme (Latency) Optimizasyonu: TTFT (Time to First Token) metriklerini düşürmek için Streaming, Prompt Caching ve Model Routing uygulama.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Core competencies of a MAANG AI Engineer: 1) Model Orchestration: Abstracting model providers via resilient SDKs like Spring AI and LangChain4j. 2) Context Engineering: Maximizing context relevance while eliminating noise and staying within token budgets. 3) Deterministic Reliability: Forcing probabilistic LLMs into strict JSON schemas via structured outputs. 4) Latency & Unit Economics: Slashing Time-to-First-Token (TTFT) through Server-Sent Events (SSE), semantic caching, and dynamic model routing (e.g. GPT-4o vs GPT-4o-mini).]
    ]
  )
]

#java25_box[
```java
// Java 25: AI Engineer Mülakat Sistem Gereksinimleri Record Modeli
public record AiSystemRequirement(
    String systemName,
    int targetLatencyP99Millis,
    double maxCostPerThousandRequestsUsd,
    double minAnswerFaithfulnessScore // RAG Hallucination metriği (0.0 - 1.0)
) {
    public boolean passesMaangProductionGate() {
        return targetLatencyP99Millis <= 1200 
            && maxCostPerThousandRequestsUsd <= 5.0 
            && minAnswerFaithfulnessScore >= 0.95;
    }
}

void main() {
    var enterpriseRAG = new AiSystemRequirement("Enterprise Support Copilot", 850, 3.20, 0.98);
    IO.println("Sistem Adı: " + enterpriseRAG.systemName());
    IO.println("MAANG Üretim Onayı: " + (enterpriseRAG.passesMaangProductionGate() ? "✅ ONAYLANDI" : "❌ REDDEDİLDİ"));
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
      Mülakatçının tuzağı: 'Bizim her şeye kendi Llama-3 modelimizi fine-tune etmemiz gerekir mi?' sorusudur. Doğru cevap: 'Hayır! Çoğu problem için RAG + Prompt Engineering hem 100 kat daha ucuzdur hem de güncel verileri anında yansıtır. Fine-tuning sadece tonlama veya çok özel bir alan terminolojisi için düşünülmelidir.'
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Classic trap question: 'Should we fine-tune our own internal LLM for this product?' Senior answer: 'No! RAG + In-Context Prompting solves 95% of enterprise requirements at 1/100th the operational cost. Fine-tuning is strictly reserved for style, domain syntax, or latency reduction on narrow tasks.']
    ]
  )
]

#takeaways_box((
    ("AI Engineer, olasılıksal LLM çıktılarını deterministik kurumsal sistemlere bağlayan mimardır.", "The AI Engineer turns non-deterministic model outputs into reliable, deterministic enterprise systems."),
    ("MAANG mülakatlarında model eğitiminden ziyade RAG, Ajanlar, gecikme ve güvenlik ön plandadır.", "MAANG rounds focus on context retrieval, agent orchestration, token economics, and safety guardrails."),
    ("Spring AI ve LangChain4j, Java ekosisteminde enterprise standardı teşkil eder.", "Spring AI and LangChain4j represent the enterprise backbone for JVM-based AI engineering."),
))
