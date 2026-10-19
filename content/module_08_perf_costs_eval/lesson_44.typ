#import "/template.typ": *

#show: doc => setup_book(title: "Ders 44: Dinamik Model Yönlendirme (Model Routing: GPT-4o vs GPT-4o-mini vs Yerel)", doc)

#lesson_header(
  44,
  "Dinamik Model Yönlendirme (Model Routing: GPT-4o vs GPT-4o-mini vs Yerel)",
  "Dynamic Model Routing: Cascading between GPT-4o, GPT-4o-mini & On-Prem LLMs",
  "LLM Performansı, Caching, Maliyet & Gecikme Optimizasyonu",
  "LLM Performance Engineering: Caching, Model Routing & Cost Optimization"
)

#diagram_box[
```text
   [ KULLANICI GİRDİSİ ]
            │
            ▼
   ┌────────────────────────────────────────────────────────┐
   │             INTELLIGENT MODEL ROUTER                   │
   │  Karmaşıklık, Maliyet ve Gizlilik Analizi Yap          │
   └────────────────────────┬───────────────────────────────┘
                            │
       ┌────────────────────┼────────────────────┐
       ▼ (Basit / Sınıflandırma)   ▼ (Karmaşık Akıl Yürütme)    ▼ (Hassas Sağlık/Finans)
   [ GPT-4o-mini ]          [ GPT-4o / o1 ]      [ YEREL OLLAMA / LLAMA-3 ]
   • $0.15 / M Token        • $2.50 / M Token    • $0 API (GPU Maliyeti)
   • 150ms Gecikme          • Yüksek Zeka        • Veri Dışarı Çıkmaz!
   • %80 Trafik             • %15 Trafik         • %5 Trafik
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bakkaldan bir ekmek almak için evin garajındaki 10 tonluk devasa vinci çalıştırmazsınız; bisiklete binip gidersiniz (Hızlı, ucuz, pratik)! Ama koca bir inşaat demiri taşıyacaksanız vinç zorunludur. Model Yönlendirme (Routing) tam olarak budur: Kullanıcı sadece 'Merhaba, nasılsın?' dediğinde veya basit bir e-postayı sınıflandırırken en pahalı amiral gemisi modeli (GPT-4o) çağırmak para yakmaktır! Küçük ve ışık hızında çalışan ucuz bir model (GPT-4o-mini) işi 10 kat daha ucuza halleder. Sadece karmaşık mimari ve analiz gerektiren zor sorularda büyük modeller devreye girer!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[You don't fire up a 40-ton industrial crane to buy milk from the local grocer; you hop on a bicycle (fast, agile, near-zero cost). But if you are lifting a 20-ton steel bridge girder, the heavy crane is indispensable. Model Routing applies this intelligence to inference: if a user texts 'Hello, help me reset my password', firing up GPT-4o or o1 burns enterprise budget unnecessarily. A lightweight tier model (GPT-4o-mini) resolves the query in 150ms at 1/15th the cost!]
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
      Model Routing Stratejileri: 1) Kural Tabanlı Yönlendirme (Rule-based): Regex veya keyword analiziyle sınıflandırma soruları doğrudan mini modele yönlendirilir. 2) Embedding Tabanlı Intent Router: Sorgunun embedding'i alınır; önceden etiketlenmiş 'Zor Sorular' kümesine yakınsa büyük modele, 'Kolay Sorular' kümesine yakınsa ucuz modele yönlendirilir. 3) LLM-Cascading (Fällback): Önce ucuz model çağrılır; eğer güven skoru (Confidence / Logprobs) düşükse veya JSON doğrulamasından geçemezse istek otomatik olarak GPT-4o'ya yükseltilir (Escalation).
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Model Routing Topologies & Cascading: 1) Heuristic & Regex Gateways: Deterministic rule engines routing keyword tasks (intent classification, translation) to miniature models. 2) Semantic Intent Embeddings: Computes embedding proximity against centroid clusters representing task complexity tiers. 3) LLM Cascading & Speculative Routing: Always dispatch to the cheapest model first. If model confidence (log probabilities) or schema validator checks fail, cascade the request upwards to GPT-4o or reasoning models (o1). This hybrid routing typically slashes enterprise LLM bills by 65-80%.]
    ]
  )
]

#java25_box[
```java
// Java 25: Akıllı Model Yönlendirici (Model Router)
public class IntelligentModelRouter {
    public enum ModelTier { TIER1_EXPENSIVE_GPT4O, TIER2_CHEAP_MINI, TIER3_ONPREM_PRIVATE }

    public static ModelTier routeQuery(String query, boolean containsSensitivePii) {
        if (containsSensitivePii) {
            return ModelTier.TIER3_ONPREM_PRIVATE; // Gizlilik gereği dışarı çıkamaz
        }
        
        // Basit sınıflandırma ve formatlama işleri için ucuz model
        String lower = query.toLowerCase();
        if (lower.startsWith("sınıflandır") || lower.startsWith("tarihi formatla") || query.length() < 50) {
            return ModelTier.TIER2_CHEAP_MINI;
        }

        // Karmaşık sistem tasarımı, kod ve analiz için büyük model
        return ModelTier.TIER1_EXPENSIVE_GPT4O;
    }
}

void main() {
    IO.println("Sorgu 1 Yönlendirmesi: " + IntelligentModelRouter.routeQuery("Bu metni İngilizceye çevir: Selam", false));
    IO.println("Sorgu 2 Yönlendirmesi: " + IntelligentModelRouter.routeQuery("Bana çok bölgeli Kafka mimarisi tasarla", false));
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
      Hata Uyarısı: Hassas kullanıcı verilerini (TC Kimlik, Kredi Kartı, Sağlık Verisi) kontrol etmeden OpenAI gibi genel bulut API'lerine yönlendirmek KVKK ve GDPR cezalarına yol açar. PII tespiti yapıldığında yönlendirici isteği yerel on-prem modellere veya anonimleştiriciye (Data Masking) yönlendirmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Compliance vulnerability: Routing raw PII or HIPAA-governed health records directly to third-party public LLM endpoints triggers catastrophic regulatory fines. The router must inspect payloads and shunt sensitive records to on-premise local models or anonymization filters.]
    ]
  )
]

#takeaways_box((
    ("Trafik genelde %80 basit, %20 karmaşık sorulardan oluşur; tek bir model kullanmak israftır.", "Traffic is typically 80% routine and 20% complex; routing to a single model is fiscally irresponsible."),
    ("Model Routing, kurumsal yapay zeka harcamalarını %60-%80 oranında düşürür.", "Intelligent model routing cuts enterprise inference expenditure by 60-80%."),
    ("Hassas veriler router seviyesinde filtrelenerek yerel modellere yönlendirilmelidir.", "Sensitive data must be intercepted at the router layer and routed to compliant on-prem models."),
))
