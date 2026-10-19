#import "/template.typ": *

#show: doc => setup_book(title: "Ders 45: Streaming Gecikmesi & TTFT (Time to First Token) Optimizasyonu", doc)

#lesson_header(
  45,
  "Streaming Gecikmesi & TTFT (Time to First Token) Optimizasyonu",
  "Latency Engineering: Optimizing TTFT (Time to First Token) & Token Per Second (TPS)",
  "LLM Performansı, Caching, Maliyet & Gecikme Optimizasyonu",
  "LLM Performance Engineering: Caching, Model Routing & Cost Optimization"
)

#diagram_box[
```text
   [ KULLANICI İSTEĞİ ] ──▶ T=0ms
                                │
               ┌────────────────┴────────────────┐
               ▼ (STANDART API)                  ▼ (STREAMING OPTİMİZE)
               İstek Gönderildi (T=0)            İstek Gönderildi (T=0)
               Model bekletiyor...               Model bekletiyor...
               Model bekletiyor...               ┌──────────────────────────────┐
               Model bekletiyor...               │ TTFT: 280ms (İLK TOKEN GELDİ!)│
               Model bekletiyor...               └──────────────┬───────────────┘
               T=4800ms: BÜTÜN CEVAP GELDİ!                     │ (Kelimeler akıyor...)
               (Kullanıcı 5 saniye bekledi!)     Kullanıcı okumaya başladı bile!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir yarış arabasının iki önemli göstergesi vardır: Sıfırdan 100 km hıza kaç saniyede çıktığı (TTFT - Time to First Token) ve son süratinin kaç km olduğu (TPS - Tokens Per Second). Kullanıcı için en sinir bozucu şey, gaza bastıktan sonra arabanın 5 saniye boyunca hiç tepki vermemesidir! Yapay zekada da kullanıcının ekranda ilk kelimeyi görme süresi (TTFT) 300 milisaniyenin altındaysa, sistem sihirli ve ışık hızında hissettirir. Kelimeler aktığı sürece toplam sürenin 5 saniye sürmesi kimseyi rahatsız etmez!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[A supercar is benchmarked on two metrics: 0-to-60 acceleration (TTFT - Time to First Token) and top track speed (TPS - Tokens Per Second). For human users, the most excruciating friction is tapping a button and enduring a frozen screen for 5 seconds. If your Time-to-First-Token drops under 300ms, the interface feels instantaneous. As long as text streams smoothly at human reading speed (15-20 TPS), total completion duration is psychologically imperceptible!]
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
      Gecikme Anatomisi ve Optimizasyon Teknikleri: 1) TTFT (Time to First Token) Neleri Kapsar?: DNS çözümleme, TLS el sıkışması, Prompt Caching kontrolü ve modelin tüm girdi token'larını tek seferde işleme süresi (Prefill Phase). 2) Prefill Phase vs Decoding Phase: Girdi token sayısı arttıkça (ör. büyük RAG bağlamı) Prefill süresi uzar ve TTFT fırlar! Çözüm: Prompt'u kısa tutmak ve Prompt Caching kullanmaktır. 3) HTTP/2 Multiplexing: Çoklu token akışlarının tek bir TCP bağlantısı üzerinden paralel akıtılması TLS gecikmesini sıfırlar.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Latency Decomposition & GPU Phase Physics: 1) TTFT Components: Network RTT + TLS handshake + Gateway dispatch + GPU Prefill Phase. 2) The Prefill Bottleneck: Before emitting token #1, the transformer must compute attention keys and values for every prompt token concurrently in memory. A 10,000-token prompt causes a 1,500ms prefill lag! Mitigation: Leverage prompt caching to bypass prefill passes on static prefixes. 3) Generation Phase (Memory-Bound): Generating subsequent tokens is memory-bandwidth bound. Optimizing TPS requires speculative decoding or smaller quantized models.]
    ]
  )
]

#java25_box[
```java
// Java 25: TTFT ve Token Akış Hızı (TPS) Performans Monitörü
public class LatencyMetricsTracker {
    private final long requestStartNanos;
    private long firstTokenNanos = 0;
    private int tokenCount = 0;

    public LatencyMetricsTracker() {
        this.requestStartNanos = System.nanoTime();
    }

    public synchronized void onTokenReceived() {
        if (firstTokenNanos == 0) {
            firstTokenNanos = System.nanoTime(); // TTFT yakalandı!
        }
        tokenCount++;
    }

    public double getTtftMillis() {
        if (firstTokenNanos == 0) return 0.0;
        return (firstTokenNanos - requestStartNanos) / 1_000_000.0;
    }

    public double getTokensPerSecond() {
        long durationNanos = System.nanoTime() - firstTokenNanos;
        if (durationNanos <= 0 || tokenCount <= 1) return 0.0;
        return (tokenCount - 1) / (durationNanos / 1_000_000_000.0);
    }
}

void main() {
    var tracker = new LatencyMetricsTracker();
    // Simüle edilmiş ilk token gelişi (280ms sonra)
    try { Thread.sleep(280); } catch (Exception e) {}
    tracker.onTokenReceived();

    IO.println("Time to First Token (TTFT): " + String.format("%.2f", tracker.getTtftMillis()) + " ms");
    IO.println("MAANG Üretim Standardı (<400ms): " + (tracker.getTtftMillis() < 400 ? "✅ BAŞARILI" : "❌ YAVAŞ"));
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
      Gecikme Tuzağı: İstemciye streaming yaparken araya ağır bir senkron Re-ranker veya JSON validator koyarsanız, streaming başlayamaz ve TTFT saniyelerce ertelenir. Ağır doğrulama gerektiren işlerde streaming değil, asenkron bildirimler kullanılmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Architectural sequencing trap: Inserting blocking post-processors or deep cross-encoders in the path of a streaming pipeline delays the initial token release, defeating the purpose of streaming. Keep the path to first token strictly non-blocking.]
    ]
  )
]

#takeaways_box((
    ("TTFT (Time to First Token), kullanıcının sistem hızını algılamasındaki en kritik metriktir.", "TTFT is the single most decisive factor shaping user perception of application speed."),
    ("Büyük prompt bağlamları GPU Prefill süresini uzatarak ilk token gecikmesini artırır.", "Massive prompt contexts inflate GPU prefill duration, spiking TTFT latency."),
    ("Prompt Caching, prefill fazını atlayarak TTFT'yi %80'e kadar hızlandırır.", "Prompt caching bypasses prefill recalculations to accelerate TTFT by up to 80%."),
))
