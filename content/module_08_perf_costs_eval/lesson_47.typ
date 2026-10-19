#import "/template.typ": *

#show: doc => setup_book(title: "Ders 47: OpenAI Fine-Tuning API & JSONL Veri Hazırlığı", doc)

#lesson_header(
  47,
  "OpenAI Fine-Tuning API & JSONL Veri Hazırlığı",
  "OpenAI Fine-Tuning API & JSONL Data Engineering: Formatting & Validation",
  "LLM Performansı, Caching, Maliyet & Gecikme Optimizasyonu",
  "LLM Performance Engineering: Caching, Model Routing & Cost Optimization"
)

#diagram_box[
```text
   [ HAM ŞİRKET VERİLERİ (Destek Talepleri, SQL Örnekleri) ]
                                      │
                                      ▼ (Veri Temizleme & Doğrulama Pipeline'ı)
   ┌────────────────────────────────────────────────────────────────────────┐
   │ training_data.jsonl (Her satır bağımsız bir JSON nesnesidir!)          │
   │ {"messages": [{"role": "system", "content": "..."},                    │
   │               {"role": "user", "content": "Sipariş #102 iptal et"},   │
   │               {"role": "assistant", "content": "CANCEL_ORDER:102"}]}   │
   └──────────────────────────────────┬─────────────────────────────────────┘
                                      │
                                      ▼
                        ┌───────────────────────────┐
                        │   OPENAI FINE-TUNING API  │
                        │ • Model: gpt-4o-mini      │
                        │ • Epochs: 3               │
                        │ • Validation Split: %20   │
                        └─────────────┬─────────────┘
                                      │
                                      ▼
             [ ÖZELLEŞTİRİLMİŞ MODEL: ft:gpt-4o-mini:company:2026 ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir aşçı çırağına yemek yapmayı öğretmek için ona tek bir devasa ansiklopedi fırlatmazsınız. Önüne 500 tane küçük kart koyarsınız: Kartın ön yüzünde sipariş (User), arka yüzünde ise çırağın yapması gereken kusursuz tabak sunumu yazar (Assistant). Çırak bu 500 kartı tekrar tekrar çalışarak (Epoch) tam şefin istediği tarzda yemek çıkarmayı öğrenir. OpenAI Fine-Tuning tam olarak bu kart sistemidir; her satırda bir soru ve ideal bir cevap olan JSONL dosyalarıyla modeli eğitirsiniz!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[To train a line cook, you don't hand them a 1,000-page historical culinary encyclopedia. You give them 500 flashcards: the front displays the ticket order (User), and the back displays the chef's gold-standard plating presentation (Assistant). The cook drills these 500 pairs repeatedly across training epochs until the execution becomes muscle memory. The OpenAI Fine-Tuning API operates on these exact flashcards formatted as JSON Lines (`.jsonl`) files!]
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
      Fine-Tuning Veri Mühendisliği Kriterleri: 1) JSONL Formatı: Dosyadaki her satır geçerli bir Chat Completion nesnesi olmalıdır (`messages` dizisi: system, user, assistant). 2) Veri Dağılımı: En az 100-200 yüksek kaliteli örnek gerekir (Kalitesiz 10.000 örnek, kaliteli 200 örnekten çok daha kötü sonuç verir - 'Garbage in, garbage out'). 3) Overfitting (Aşırı Ezberleme): Epoch sayısı yüksek tutulursa model eğitim verilerini kelimesi kelimesine ezberler ve genelleme yeteneğini kaybeder. Validation Loss metriği dikkatle izlenmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Fine-Tuning Dataset Engineering & Training Protocol: 1) JSONL Serialization: Every line must form a discrete, valid JSON array of role messages. 2) Quality Over Quantity: 200 meticulously curated, diverse golden exemplars vastly outperform 10,000 noisy, uncurated conversational logs. 3) Hyperparameter Guardrails: Set training epochs between 2 and 4 to avoid catastrophic forgetting and overfitting. Monitor validation loss curves: an inflection where validation loss climbs while training loss drops signals severe over-fitting.]
    ]
  )
]

#java25_box[
```java
// Java 25: Fine-Tuning JSONL Veri Satırı Üretici ve Doğrulayıcı
import java.util.List;

public class FineTuningDataEngine {
    public record ChatMessage(String role, String content) {}
    public record FineTuningExample(List<ChatMessage> messages) {
        public String toJsonLine() {
            // Basit JSONL satır serialization simülasyonu
            return String.format("{"messages": [{"role":"system","content":"%s"},{"role":"user","content":"%s"},{"role":"assistant","content":"%s"}]}",
                messages.get(0).content(), messages.get(1).content(), messages.get(2).content());
        }
    }
}

void main() {
    var example = new FineTuningDataEngine.FineTuningExample(List.of(
        new FineTuningDataEngine.ChatMessage("system", "Sen bir SQL derleyicisisin."),
        new FineTuningDataEngine.ChatMessage("user", "Aktif kullanıcıları getir"),
        new FineTuningDataEngine.ChatMessage("assistant", "SELECT * FROM users WHERE status = 'ACTIVE';")
    ));

    IO.println("Üretilen Fine-Tuning JSONL Satırı:");
    IO.println(example.toJsonLine());
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
      Veri Sızıntısı (Data Contamination): Fine-tuning eğitim setine gizli kullanıcı kimlik numaralarını veya gerçek müşteri kredi kartı loglarını eklerseniz, model bu bilgileri ağırlıklarında depolar ve başka bir kullanıcının sorgusunda yanlışlıkla ifşa edebilir (PII Extraction Attack)! Veriler mutlaka anonimleştirilmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[PII exfiltration hazard: Fine-tuning on unredacted production logs embeds confidential user data directly into model weights. Adversaries can extract this training data via targeted prompt probing. All training sets must be strictly scrubbed and anonymized.]
    ]
  )
]

#takeaways_box((
    ("OpenAI Fine-Tuning API, JSONL formatında system-user-assistant üçlüleriyle eğitilir.", "OpenAI Fine-Tuning operates on JSONL files containing system-user-assistant conversational turns."),
    ("Veri kalitesi veri miktarından 10 kat daha önemlidir (Kaliteli 200 örnek yeterlidir).", "Dataset quality vastly outweighs volume: 200 curated examples outperform 5,000 noisy rows."),
    ("Eğitim verileri PII ve hassas şirket sırlarından kesinlikle arındırılmalıdır.", "Training corpora must be rigorously scrubbed of PII and proprietary secrets."),
))
