#import "/template.typ": *

#show: doc => setup_book(title: "Ders 57: Gözlemlenebilirlik (Observability), Tracing & LLM Metrikleri (OpenTelemetry, Langfuse)", doc)

#lesson_header(
  57,
  "Gözlemlenebilirlik (Observability), Tracing & LLM Metrikleri (OpenTelemetry, Langfuse)",
  "LLM Observability & Tracing: OpenTelemetry, Langfuse & Production Telemetry",
  "AI Güvenliği, Gözlemlenebilirlik & MAANG Mülakat Ustalığı",
  "AI Security, Observability & The MAANG Interview Mastery Rubric"
)

#diagram_box[
```text
   [ KULLANICI İSTEĞİ: TraceID = trc_9481 ]
                         │
                         ▼
   ┌────────────────────────────────────────────────────────┐
   │             DISTRIBUTED TRACING (OpenTelemetry)        │
   │                                                        │
   │  Span 1: Ingress Gateway (Latency: 15ms)               │
   │    └──▶ Span 2: Vector Search (HNSW Latency: 42ms)    │
   │           └──▶ Span 3: Re-ranker (Cohere Latency: 65ms)│
   │                  └──▶ Span 4: OpenAI Chat (1450ms)     │
   │                         • Model: gpt-4o                │
   │                         • Tokens: 1420 In / 310 Out    │
   │                         • Cost: $0.0066 USD            │
   └────────────────────────┬───────────────────────────────┘
                            │
                            ▼
     [ LANGFUSE / PROMETHEUS DASHBOARD: Canlı Maliyet, P99 Gecikme, Token Hızı ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir kargo gönderdiğinizde kargo takip numarasını sisteme girersiniz ve kargonun hangi aktarma merkezinde kaç dakika beklediğini adım adım görürsünüz (Tracing). Gözlemlenebilirlik (Observability) yapay zekanın kargo takip sistemidir! Bir kullanıcı 'Uygulama çok yavaşladı' dediğinde, yavaşlığın veritabanında mı, re-ranker'da mı yoksa OpenAI'ın sunucularında mı olduğunu milisaniye hassasiyetiyle ekranınızda görürsünüz. Hangi kullanıcının kaç kuruşluk token harcadığını kuruşu kuruşuna canlı gösterir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[When shipping a valuable parcel across the world, a tracking number lets you pinpoint the exact warehouse where the truck is currently idling (Distributed Tracing). LLM Observability is that flight-data recorder for AI pipelines! When a customer complains: 'The assistant is hanging', observability tools like OpenTelemetry and Langfuse visually graph every sub-span: did the vector search take 40ms? Did the reranker take 80ms? Did OpenAI take 2,000ms? It tracks token spend, latency, and hallucination rates in real time!]
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
      LLM Gözlemlenebilirlik Mimarisi: 1) OpenTelemetry Semantik Konvansiyonları (GenAI Spans): Her LLM çağrısı standart span etiketleriyle donatılır: `gen_ai.system: openai`, `gen_ai.request.model: gpt-4o`, `gen_ai.usage.input_tokens`, `gen_ai.usage.output_tokens`. 2) Tracing & Spans: `TraceId` kullanıcıdan başlar, Spring AI ChatClient üzerinden geçer ve veritabanı sorgusunu sarmalar. 3) Langfuse / Arize Phoenix: LLM'e özel açık kaynak izleme platformlarıdır; kullanıcının verdiği 'Beğen/Beğenme' (Thumbs Up/Down) geri bildirimlerini ilgili `trace_id` ile eşleştirir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[OpenTelemetry GenAI Semantic Conventions & Instrumentation: 1) Standardized Attributes: Spans must emit standard OpenTelemetry GenAI metadata (`gen_ai.operation.name`, `gen_ai.request.model`, `gen_ai.usage.prompt_tokens`, `gen_ai.usage.completion_tokens`, `gen_ai.response.finish_reasons`). 2) Distributed Span Hierarchy: Root trace spans originate at the HTTP gateway, bifurcating into child spans for VectorStore ANN search, Cohere Reranking, and OpenAI SSE streams. 3) Feedback Loop Association: Platforms like Langfuse link downstream user sentiment scores (thumbs-up/down) directly to specific prompt span IDs, pinpointing problematic model generations.]
    ]
  )
]

#java25_box[
```java
// Java 25: OpenTelemetry Uyumlu LLM Telemetry Metrik Modeli
public record LlmTraceSpan(
    String traceId,
    String modelName,
    long durationMillis,
    int inputTokens,
    int outputTokens,
    double calculatedCostUsd
) {
    public static LlmTraceSpan recordSpan(String traceId, String model, long durationMs, int inTokens, int outTokens) {
        // GPT-4o maliyet hesabı ($2.50 / $10.00 per 1M)
        double cost = ((inTokens / 1_000_000.0) * 2.50) + ((outTokens / 1_000_000.0) * 10.0);
        return new LlmTraceSpan(traceId, model, durationMs, inTokens, outTokens, cost);
    }
}

void main() {
    var trace = LlmTraceSpan.recordSpan("trc_94812", "gpt-4o", 1250, 1850, 220);
    IO.println("Trace ID: " + trace.traceId());
    IO.println("Model: " + trace.modelName() + " | Toplam Süre: " + trace.durationMillis() + " ms");
    IO.println("Harcanan Token: " + (trace.inputTokens() + trace.outputTokens()) + " (" + trace.inputTokens() + " in / " + trace.outputTokens() + " out)");
    IO.println("Hesaplanan Maliyet: $" + String.format("%.6f", trace.calculatedCostUsd()));
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
      Gizlilik Uyarısı: Loglama ve Tracing yaparken kullanıcıların özel promptlarını ve şifrelerini DÜZ METİN (Cleartext) olarak log dosyalarına basmayın! Loglar sızdığında veri ihlali cezası doğar. Tracing platformlarına göndermeden önce hassas veriler maskelenmeli veya sadece token sayıları loglanmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Telemetry privacy violation: Blindly logging full prompt and response payloads to centralized tracing tools (Datadog, Langfuse) stores raw customer PII and credentials in log indexes. Always sanitize and redact spans before publishing to telemetry collectors.]
    ]
  )
]

#takeaways_box((
    ("OpenTelemetry GenAI standartları, LLM sistemlerinin izlenebilirliğini tekilleştirir.", "OpenTelemetry GenAI semantic conventions standardize LLM observability across tools."),
    ("Dağıtık Tracing, gecikmenin nerede yaşandığını (Vektör mü, LLM mi) anında gösterir.", "Distributed tracing pinpoints whether latency bottlenecks stem from vector search or model APIs."),
    ("Canlı maliyet ve token metrikleri izlenmeden hiçbir AI sistemi üretime çıkarılamaz.", "Inference spend and token velocity must be actively monitored to prevent budget overruns."),
))
