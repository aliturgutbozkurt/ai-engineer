#import "/template.typ": *

#show: doc => setup_book(title: "Ders 46: Fine-Tuning Ne Zaman Gerekir? RAG vs Fine-Tuning vs Prompting Karar Matrisi", doc)

#lesson_header(
  46,
  "Fine-Tuning Ne Zaman Gerekir? RAG vs Fine-Tuning vs Prompting Karar Matrisi",
  "When to Fine-Tune? The Architectural Decision Matrix: RAG vs Fine-Tuning",
  "LLM Performansı, Caching, Maliyet & Gecikme Optimizasyonu",
  "LLM Performance Engineering: Caching, Model Routing & Cost Optimization"
)

#diagram_box[
```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                 RAG vs FINE-TUNING vs PROMPTING DECISION MATRIX             │
└─────────────────────────────────────────────────────────────────────────────┘
                                  [ YENİ BİLGİ İHTİYACI ]
                                (Dinamik / Sürekli Güncellenen Veri)
                                           ▲
                                           │
                        RAG (Altın Standart)│  RAG + FINE-TUNING
                        • Şirket içi dokümanlar│  • Tıbbi teşhis RAG'i
                        • Güncel fiyatlar  │  • Hukuk doküman analizi
                                           │
  ─────────────────────────────────────────┼─────────────────────────────────────────▶
                                           │   [ ÖZEL FORMAT / TONLAMA İHTİYACI ]
                        PROMPT ENGINEERING │  FINE-TUNING (Ağırlık Eğitimi)
                        • Few-Shot örnekler│  • Özel SQL/JSON sözdizimi
                        • Standart sohbet  │  • Müşteri hizmetleri tonu
                                           │  • Küçük modelde (mini) uzmanlık
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir yabancıya İstanbul'daki güncel trafik durumunu öğretmek için ona beyin ameliyatı yapıp hafızasına yeni nöronlar eklemezsiniz (Fine-Tuning)! Eline bir navigasyon cihazı verirsiniz; cihaz anlık haritaya bakar ve söyler (RAG). Ama o yabancıya Türkçe'deki kibar konuşma tarzını ve ses tonunu öğretmek istiyorsanız birkaç ay boyunca dil kursuna gönderirsiniz (Fine-Tuning). Özetle: Bilgi eklemek için RAG; tarz, üslup ve format öğretmek için Fine-Tuning kullanılır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[To teach a visiting diplomat today's live traffic status, you don't perform invasive brain surgery to splice new neurons into their cerebral cortex (Fine-Tuning). You hand them a live smartphone GPS (RAG). But if you want that diplomat to speak with the precise dialect, ceremonial cadence, and etiquette of the royal court, you send them through rigorous vocal coaching (Fine-Tuning). Knowledge injection demands RAG; style, format, and syntax conditioning justify Fine-Tuning!]
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
      MAANG Seviyesinde Karar Ağacı: 1) RAG Ne Zaman Seçilir?: Veri sık değişiyorsa (fiyatlar, envanter), kaynak gösterimi (Citation) şartsa ve bütçe kısıtlıysa. RAG model ağırlıklarına dokunmaz, halüsinasyonu minimize eder. 2) Fine-Tuning Ne Zaman Seçilir?: a) Format/Syntax: Modelin standart olmayan özel bir DSL veya JSON formatında kusursuz çıktı üretmesi gerekiyorsa. b) Maliyet Düşürme: Büyük bir GPT-4o modelinin yeteneklerini küçük ve 20 kat daha ucuz bir GPT-4o-mini modeline damıtmak (Distillation) için. 3) Hibrid Yaklaşım: Model fine-tuning ile şirket jargonuyla konuşacak şekilde eğitilir, ancak güncel verileri RAG ile bağlamından alır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Enterprise Strategic Evaluation Framework: 1) Choose RAG: Dynamic datasets with frequent updates (inventories, policies), strict compliance demanding source citations, and zero tolerance for model weight drift. 2) Choose Fine-Tuning: Domain-specific stylistic alignment, complex proprietary DSLs, or Knowledge Distillation (training a 10x cheaper mini-model to replicate GPT-4o's performance on a narrow task). 3) The Hybrid Pattern: The pinnacle of production architecture: Fine-tune the model to internalize vocabulary, conciseness, and format; inject temporal enterprise facts dynamically via RAG.]
    ]
  )
]

#java25_box[
```java
// Java 25: RAG vs Fine-Tuning Mimari Karar Danışmanı
public class ArchitectureDecisionAdvisor {
    public enum Strategy { PROMPT_ENGINEERING, PURE_RAG, FINE_TUNING, HYBRID_RAG_AND_TUNING }

    public static Strategy evaluateArchitecture(boolean frequentDataUpdates, boolean customSyntaxRequired, boolean citationMandatory) {
        if (frequentDataUpdates && citationMandatory && !customSyntaxRequired) {
            return Strategy.PURE_RAG; // En hızlı, en ucuz ve doğrulanabilir çözüm!
        }
        if (frequentDataUpdates && customSyntaxRequired) {
            return Strategy.HYBRID_RAG_AND_TUNING;
        }
        if (!frequentDataUpdates && customSyntaxRequired) {
            return Strategy.FINE_TUNING;
        }
        return Strategy.PROMPT_ENGINEERING;
    }
}

void main() {
    var strategy = ArchitectureDecisionAdvisor.evaluateArchitecture(true, false, true);
    IO.println("MAANG Mülakatı Tavsiye Edilen Strateji: " + strategy); // PURE_RAG
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
      En Büyük Mülakat Hatası: 'Şirketimizin verilerini modele öğretmek için modeli şirket PDF'leriyle fine-tune ettik' demek anında elenme sebebidir! Fine-tuning modelin ağırlıklarını günceller ancak kesin olgusal bilgileri (Factual Knowledge) güvenilir şekilde ezberletemez; model halüsinasyon görmeye devam eder ve güncellenemez. Bilgi için çözüm DAİMA RAG'dir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[The Fatal Interview Blunder: Stating that 'we fine-tuned an LLM on our internal PDF manuals to teach it our company data'. Fine-tuning adjusts probabilistic model style, but fails miserably at reliable factual recall, causing severe hallucinations. Knowledge ingestion is exclusively the domain of RAG.]
    ]
  )
]

#takeaways_box((
    ("Bilgi eklemek (Knowledge Injection) için RAG; üslup ve format öğretmek için Fine-Tuning kullanılır.", "RAG is for dynamic knowledge injection; Fine-Tuning is for style, syntax, and tone conditioning."),
    ("Fine-tuning modelin halüsinasyon görmesini engellemez, hatta bazen artırabilir.", "Fine-tuning does not eliminate hallucinations and cannot substitute for verified context."),
    ("En güçlü kurumsal mimari: Üslubu eğitilmiş küçük bir model + güncel verileri getiren RAG'dir.", "The ultimate enterprise architecture couples a style-tuned compact model with dynamic RAG."),
))
