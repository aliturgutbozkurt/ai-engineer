#import "/template.typ": *

#show: doc => setup_book(title: "Ders 3: Model Parametrelerinin Sırları: Temperature, Top-P, Top-K & Penalty Ayarları", doc)

#lesson_header(
  3,
  "Model Parametrelerinin Sırları: Temperature, Top-P, Top-K & Penalty Ayarları",
  "Hyperparameter Secrets: Temperature, Top-P, Top-K & Frequency/Presence Penalties",
  "AI Engineer Rolü, LLM Anatomisi & MAANG Mülakat Çerçevesi",
  "The AI Engineer Role, LLM Anatomy & The MAANG Interview Framework"
)

#diagram_box[
```text
   [ SOFTMAX OLASILIK DAĞILIMI (Logits) ]
    
    Temperature = 0.0 (Deterministik / Robotik)
    ┌────────────────────────┐
    │ Paris: 99.9%           │ ──▶ Her zaman "Paris" seçilir (Kod, JSON, SQL)
    └────────────────────────┘
    
    Temperature = 0.7 (Dengeli / Doğal Dil)
    ┌──────────────┬──────────────┬────────────┐
    │ Paris: 60%   │ Şehir: 25%   │ Başkent: 15%│ ──▶ Akıcı, yaratıcı konuşma
    └──────────────┴──────────────┴────────────┘
    
    Top-P (Nucleus Sampling = 0.90)
    ┌───────────────────────────────────┐  [ Düşük olasılıklı ]
    │ Kümülatif %90'a girenler adaydır  │  │ saçma kelimeler │ ──▶ ÇÖPE ATILIR!
    └───────────────────────────────────┘  └─────────────────┘
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir restoranda garsona 'Bana bir yemek öner' dediğinizde iki seçeneğiniz vardır: Garsonun her defasında menünün en çok satan standart yemeğini getirmesini mi istersiniz (Temperature = 0, tam deterministik); yoksa arada sırada şefin özel spesiyallerini denemesini mi (Temperature = 0.8, yaratıcı)? Eğer SQL sorgusu veya JSON kod üretiyorsanız garsonun fantezi yapmasını istemezsiniz (T=0)! Ama bir pazarlama metni veya hikaye yazdırıyorsanız biraz yaratıcılık gerekir.
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Imagine dining at a restaurant and asking the chef for a dish. Temperature = 0 means the chef strictly prepares the mathematically #1 top-selling item every single time (deterministic, ideal for code and JSON). Temperature = 0.8 allows the chef to explore delicious variations across top ingredients. If you are generating financial reports, SQL, or JSON APIs, any Temperature > 0 risks syntactic corruption!]
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
      Parametrelerin matematiksel anatomisi: 1) Temperature: Logit değerlerini (z_i / T) şeklinde böler. T -> 0 iken dağılım argmax'a dönüşür (tam deterministik). T > 1 iken tüm kelimelerin olasılığı birbirine yaklaşır, halüsinasyon riski fırlar. 2) Top-P (Nucleus Sampling): Olasılıkları azalan sırada sıralar ve toplam kümülatif olasılık P eşiğine (ör. 0.90) ulaşana kadar olan en iyi kelime kümesini alır; kuyruktaki saçma token'ları budar. 3) Frequency & Presence Penalty: Frequency penalty tekrar eden token'ların olasılığını oransal cezalandırır; Presence penalty ise bir kelimenin metinde sadece bir kez geçmiş olmasına ceza keserek modelin yeni konulara geçmesini sağlar.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Mathematical dynamics of sampling hyperparameters: 1) Temperature (T): Scales the raw logits before Softmax (p_i = exp(z_i / T) / Σ exp(z_j / T)). As T -> 0, entropy drops to zero, yielding deterministic greedy decoding. 2) Top-P (Nucleus Sampling): Dynamically truncates the probability mass to the smallest subset of tokens whose cumulative sum exceeds P (e.g. 0.9). 3) Frequency vs Presence Penalty: Frequency penalizes repeated token occurrences proportionally; Presence penalizes any token having appeared at least once, encouraging broader topical exploration.]
    ]
  )
]

#java25_box[
```java
// Java 25 & LangChain4j: Deterministik JSON Üretimi için Model Ayarları
import dev.langchain4j.model.openai.OpenAiChatModel;

public class ModelParameterFactory {
    // Kurumsal API ve JSON çıktıları için sıfır halüsinasyon modeli
    public static OpenAiChatModel createStrictJsonModel(String apiKey) {
        return OpenAiChatModel.builder()
            .apiKey(apiKey)
            .modelName("gpt-4o-mini")
            .temperature(0.0)      // Kesinlikle deterministik
            .topP(1.0)
            .presencePenalty(0.0)
            .frequencyPenalty(0.0)
            .maxRetries(3)
            .build();
    }

    // Yaratıcı Pazarlama ve Metin Yazarlığı Modeli
    public static OpenAiChatModel createCreativeModel(String apiKey) {
        return OpenAiChatModel.builder()
            .apiKey(apiKey)
            .modelName("gpt-4o")
            .temperature(0.75)     // Zengin ve doğal dil
            .topP(0.90)            // Düşük ihtimalli saçmalıkları buda
            .build();
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
      Kritik Mülakat Kuralı: Aynı anda hem yüksek Temperature (ör. 0.9) hem de düşük Top-P (ör. 0.2) kullanmayın! Bu iki hiperparametre birbiriyle yarışır. OpenAI resmi rehberi: Ya Temperature'ı ya da Top-P'yi değiştirin, ikisini aynı anda kurcalamayın.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Production guideline: Never tune Temperature and Top-P concurrently. OpenAI officially recommends altering either Temperature OR Top-P, never both simultaneously, to avoid conflicting probability distributions.]
    ]
  )
]

#takeaways_box((
    ("JSON, kod ve SQL üretiminde Temperature daima 0.0 olmalıdır.", "For JSON, code generation, and SQL querying, Temperature must strictly be 0.0."),
    ("Top-P (Nucleus Sampling), modelin saçma ve alakasız kelimeleri seçmesini önler.", "Top-P truncates the long tail of low-probability hallucinated tokens."),
    ("Production sistemlerde hiperparametreler harici konfigürasyondan dinamik yönetilmelidir.", "In production systems, hyperparameters should be dynamically configured per use-case."),
))
