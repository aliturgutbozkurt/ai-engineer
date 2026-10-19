#import "/template.typ": *

#show: doc => setup_book(title: "Ders 2: LLM'ler Nasıl Düşünür? Tokenization (BPE), Context Window & Next-Token Prediction", doc)

#lesson_header(
  2,
  "LLM'ler Nasıl Düşünür? Tokenization (BPE), Context Window & Next-Token Prediction",
  "How LLMs Think: Tokenization (BPE), Context Windows & Next-Token Prediction",
  "AI Engineer Rolü, LLM Anatomisi & MAANG Mülakat Çerçevesi",
  "The AI Engineer Role, LLM Anatomy & The MAANG Interview Framework"
)

#diagram_box[
```text
   [ KULLANICI GİRDİSİ ] ──▶ "Sistem tasarımı harika!"
                                      │
                                      ▼ (Byte-Pair Encoding - BPE Tokenizer)
   [ TOKEN ID DİZİSİ ]   ──▶ [ 14210, 8923, 44102, 0 ] (~4 Token)
                                      │
                                      ▼ (Embedding Matrix + Self-Attention Layers)
   [ OLASILIK DAĞILIMI ] ──▶ Token: "çünkü"   (%42)  ◀─── [Seçilen Token]
                             Token: "ve"      (%28)
                             Token: "ancak"   (%12)
                                      │
   [ OTORAGRESİF DÖNGÜ ] ◀────────────┘ (Yeni token girişe eklenir, sonraki tahmin edilir!)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir LLM'in beyni sihirli bir falcı değildir; dünyanın en gelişmiş 'kelime tamamlama' motorudur! Cep telefonunuzda mesaj yazarken klavyenin üstünde çıkan 3 kelime önerisini düşünün. LLM de tam olarak bunu yapar, ancak arkasında milyarlarca parametrelik dev bir kütüphane vardır. LLM harfleri tek tek görmez; 'Token' adı verilen hece parçacıklarıyla düşünür (örneğin 'İstanbul' tek token olabilirken, nadir bir kelime 3 parçaya bölünebilir). Bir sonraki kelimeyi tahmin eder, cümleye ekler ve durma işareti (EOS) görene kadar bu döngüyü tekrarlar!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[An LLM is not a mystical sentient oracle; it is the ultimate mathematical autocomplete engine. When you type on your smartphone and the keyboard suggests the next three words, an LLM executes the exact same process with a multi-billion-parameter neural network. Crucially, models don't read raw text; they ingest integers representing 'Tokens' (via algorithms like Byte-Pair Encoding). It computes a softmax probability distribution over 100,000+ candidate tokens, picks one, appends it to context, and iterates until an End-of-Sequence (EOS) token fires!]
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
      LLM'in anatomik kısıtları: 1) Tokenization (BPE - tiktoken): 1000 kelime İngilizce metin yaklaşık 750 token ederken, Türkçe veya diller arası eklemeli dillerde morfolojik yapı nedeniyle 1000 kelime 1400 token tüketebilir! Bu durum API maliyetini ve gecikmeyi 2 katına çıkarır. 2) Context Window: GPT-4o 128k token context penceresine sahiptir. Ancak pencere doldukça 'Attention Degeneration' ve 'Lost-in-the-Middle' etkisi başlar. 3) Otoragresif Üretim: Her üretilen token bir sonraki adımın girdisi olur; bu yüzden üretim sıralıdır (Sequential) ve GPU paralelleştirmesi zordur.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Architectural constraints of autoregressive transformers: 1) Tokenization Economics: In English, 1,000 words correspond to ~750 tokens. For agglutinative or non-Latin languages, BPE splits words into multiple subwords, elevating token counts by 40-80% and directly inflating latency and billing. 2) Context Window Limits: While modern models support 128k-1M context windows, needle-in-a-haystack accuracy degrades when critical facts sit in the middle of long contexts. 3) KV Cache: During generation, key-value projections of previous tokens are cached in VRAM; memory grows linearly with context length.]
    ]
  )
]

#java25_box[
```java
// Java 25: Basit Bir Token Sayacı ve Context Window Maliyet Simülatörü
public record TokenCostEstimator(String modelName, double inputPricePerMillion, double outputPricePerMillion) {
    public double estimateCost(int promptTokens, int completionTokens) {
        double inputCost = (promptTokens / 1_000_000.0) * inputPricePerMillion;
        double outputCost = (completionTokens / 1_000_000.0) * outputPricePerMillion;
        return inputCost + outputCost;
    }
}

void main() {
    // OpenAI GPT-4o Fiyatlandırması (Örnek: $2.50 input, $10.00 output / 1M)
    var gpt4o = new TokenCostEstimator("gpt-4o", 2.50, 10.00);
    
    int promptTokens = 12_500;    // RAG bağlamı ile zenginleştirilmiş girdi
    int responseTokens = 850;     // Modelin ürettiği yanıt
    
    double totalUsd = gpt4o.estimateCost(promptTokens, responseTokens);
    IO.println("Model: " + gpt4o.modelName());
    IO.println("İstek Başına Tahmini Maliyet: $" + String.format("%.5f", totalUsd));
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
      En sık yapılan hata: 'Model nasılsa 128k token destekliyor, tüm 100 sayfalık PDF'i her prompt'a yapıştırayım' yaklaşımıdır. Bu hem saniyelerce süren korkunç bir gecikmeye yol açar hem de 'Lost in the Middle' etkisiyle modelin ortadaki kritik bilgileri görmezden gelmesine sebep olur!
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Architectural antipattern: Dumping 50 pages of raw unindexed text into a 128k context window. This balloons TTFT latency by seconds, skyrockets inference spend, and triggers 'Lost in the Middle' retrieval failures.]
    ]
  )
]

#takeaways_box((
    ("LLM'ler harf değil, Byte-Pair Encoding (BPE) ile bölünmüş token sayıları işler.", "LLMs process numeric token IDs computed via Byte-Pair Encoding, not raw characters."),
    ("Yanıt üretimi otoragresiftir: Her yeni kelime için tüm önceki metin yeniden değerlendirilir.", "Generation is autoregressive: each token appends to context for the next inference step."),
    ("Büyük context window, RAG'in yerini alamaz; gereksiz token maliyet ve gecikme demektir.", "Large context windows do not obsolete RAG; relevance-focused context is always faster and cheaper."),
))
