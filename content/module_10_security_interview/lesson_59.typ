#import "/template.typ": *

#show: doc => setup_book(title: "Ders 59: AI Mülakatlarında 'Trade-off' Savunusu: Latency vs Quality vs Cost", doc)

#lesson_header(
  59,
  "AI Mülakatlarında 'Trade-off' Savunusu: Latency vs Quality vs Cost",
  "The Holy Trinity of AI Trade-offs: Latency vs Quality vs Cost Trilemma",
  "AI Güvenliği, Gözlemlenebilirlik & MAANG Mülakat Ustalığı",
  "AI Security, Observability & The MAANG Interview Mastery Rubric"
)

#diagram_box[
```text
                        [ KALİTE (Quality / Accuracy) ]
                                      ▲
                                     / \
                                    /   \
                                   /     \
                                  /       \
  (GPT-4o + Heavy Re-ranker)     /  MAANG  \    (Streaming + Prompt Cache)
  Yüksek Kalite & Pahalı       /  OPTIMAL  \   Düşük Gecikme & Ucuz
                              /             \
                             /               \
  [ GECİKME (Low Latency) ] ◄─────────────────► [ MALİYET (Low Cost) ]
  (150ms TTFT, mini model)                      (Yerel model / Cache-hit)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir restoranda yemek yerken üç şey istersiniz: Yemek dünyanın en lezzetli yemeği olsun (Kalite), masanıza 1 dakikada gelsin (Düşük Gecikme) ve fiyatı sadece 10 TL olsun (Düşük Maliyet)! Gerçek hayatta bu üçünün aynı anda olması imkansızdır (Trilemma): Ya lezzetli ve hızlı olur ama pahalıdır; ya ucuz ve hızlıdır ama lezzetsizdir. Bir AI Engineer'ın ustalığı bu üçgenin ortasında durabilmektir: Basit soruları ucuz ve hızlı çözüp, sadece kritik kararlarda en kaliteli modeli devreye sokarak mükemmel dengeyi kurmaktır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[The classic engineering trilemma applied to AI: You demand Michelin-star quality, instantaneous 100ms delivery, and a price tag of \$0.001. In reality, you can only pick two! Maximizing quality (GPT-4o + multi-agent debate + cross-encoder rerank) blows your latency and token budget. Minimizing cost and latency (quantized local model with zero context) destroys answer quality. A Staff+ AI Engineer masterfully balances this triangle through dynamic caching, speculative routing, and tiered fallbacks!]
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
      Trilemma Dengeleme Stratejileri: 1) Kalite Odaklı Senaryolar (Hukuk, Tıp, Finans): Gecikme ve maliyet ikinci plandadır. GPT-4o, HyDE, Cross-Encoder Re-ranking ve LLM-as-a-Judge zorunludur. 2) Gecikme Odaklı Senaryolar (Kod tamamlama, Sesli Asistan): Kaliteden ufak ödün verilebilir. GPT-4o-mini, Streaming (SSE), küçük chunk boyutları ve aggressively debounced çağrılar kullanılır. 3) Maliyet Odaklı Senaryolar (Kitle müşteri desteği): Semantik önbellekleme (Cache hit oranı %60+), Prompt Caching ve Model Routing ile maliyet %80 baskılanır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Engineering the Trilemma Trade-Off Surface: 1) High-Stakes Domains (Medical, Financial, Legal): Quality is non-negotiable. Accept +1,000ms latency and \$0.05/call using GPT-4o, multi-step ReAct, and dual cross-encoders. 2) Real-Time Interactive Surfaces (Voice, Code Autocomplete): Latency is king (SLA \<200ms). Sacrifice marginal accuracy by deploying GPT-4o-mini with speculative streaming. 3) Massive Consumer Scale (Free Tier Support): Unit economics dominate. Drive cache-hit ratios past 60% via Redis semantic caches and aggressive prompt prefix deduplication.]
    ]
  )
]

#java25_box[
```java
// Java 25: AI Trilemma Strateji Seçici Modeli
public class AiTrilemmaGovernor {
    public enum PriorityProfile { QUALITY_FIRST, LATENCY_FIRST, COST_FIRST, BALANCED_PRODUCTION }

    public record ExecutionStrategy(String model, boolean useReranker, boolean enableStreaming, boolean checkCache) {}

    public static ExecutionStrategy determineStrategy(PriorityProfile profile) {
        return switch (profile) {
            case QUALITY_FIRST -> new ExecutionStrategy("gpt-4o", true, false, false);
            case LATENCY_FIRST -> new ExecutionStrategy("gpt-4o-mini", false, true, true);
            case COST_FIRST    -> new ExecutionStrategy("gpt-4o-mini", false, false, true);
            case BALANCED_PRODUCTION -> new ExecutionStrategy("gpt-4o-mini", true, true, true);
        };
    }
}

void main() {
    var strategy = AiTrilemmaGovernor.determineStrategy(AiTrilemmaGovernor.PriorityProfile.BALANCED_PRODUCTION);
    IO.println("MAANG Dengeli Üretim Stratejisi:");
    IO.println("Model: " + strategy.model() + " | Re-ranker: " + strategy.useReranker() + " | Streaming: " + strategy.enableStreaming());
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
      Mülakatın Altın Kuralı: 'Biz sistemimizde her yerde en büyük modeli kullandık, hiçbir maliyet hesabı yapmadık' demek bir mühendis için intihardır. Mülakatçıya daima 'Bu kararım şu kadar maliyet tasarrufu sağladı ancak gecikmeyi 50ms artırdı; bu bizim SLA sınırlarımız içindedir' şeklinde takas (Trade-off) analizi sunun.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Cardinal interview sin: Stating that 'we always use the biggest model with unlimited context because it gives the best answer'. Senior engineers justify every millisecond and every micro-cent: 'We accept a 40ms reranking latency overhead because it elevates our precision\@3 by 22%, saving downstream support escalations.']
    ]
  )
]

#takeaways_box((
    ("AI Sistem Tasarımı; Kalite, Gecikme ve Maliyet arasındaki üçlü dengeyi (Trilemma) yönetme sanatıdır.", "AI engineering is the discipline of navigating the Quality, Latency, and Cost trilemma."),
    ("Hiçbir mimari karar 'mükemmel' değildir; her kararın bir bedeli ve ödünleşimi (Trade-off) vardır.", "No architecture is unilaterally perfect; every design choice carries explicit trade-offs."),
    ("Mülakatçıları etkileyen şey en yeni teknolojiler değil, bu ödünleşimleri sayısal savunabilmenizdir.", "Interviewers are swayed by your ability to quantify and defend these architectural trade-offs."),
))
