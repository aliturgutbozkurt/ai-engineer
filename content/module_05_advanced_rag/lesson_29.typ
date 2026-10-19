#import "/template.typ": *

#show: doc => setup_book(title: "Ders 29: RAG Değerlendirmesi: RAG Triad Metrikleri (Context Relevance, Groundedness, Answer Relevance)", doc)

#lesson_header(
  29,
  "RAG Değerlendirmesi: RAG Triad Metrikleri (Context Relevance, Groundedness, Answer Relevance)",
  "The RAG Triad Evaluation: Context Relevance, Groundedness (Faithfulness) & Answer Relevance",
  "İleri Düzey RAG (Advanced RAG) & Bilgi Getirme Optimizasyonu",
  "Advanced RAG & Information Retrieval Optimization"
)

#diagram_box[
```text
                      [ KULLANICI SORUSU (Query) ]
                                    ▲       ▲
              Context Relevance     │       │     Answer Relevance
         (Bağlam soruyla alakalı mı?)│       │ (Cevap soruya hitap ediyor mu?)
                                    ▼       ▼
   [ GETİRİLEN BAĞLAM (Context) ] ──────▶ [ MODEL CEVABI (Response) ]
                               Groundedness (Faithfulness)
                        (Cevap SADECE bağlama mı dayanıyor?)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir mahkeme salonu düşünün: Hakim adil bir karar vermek için 3 şeye bakar: 1) Avukatın getirdiği delil olayla ilgili mi? (Context Relevance - Alakasız delil getirilirse dava uzar). 2) Karar SADECE masadaki delillere mi dayanıyor? (Groundedness / Faithfulness - Hakim kafasından uydurursa karar iptal edilir!). 3) Karar davacının sorduğu soruya net cevap veriyor mu? (Answer Relevance - Soru miras davası iken hakim trafik cezası kesemez!). RAG Triad bu 3 sorudur: Bu 3 bacağı sağlam kurarsanız RAG sisteminiz asla yalan söylemez!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Picture a high-stakes court trial evaluated across 3 non-negotiable legal standards: 1) Context Relevance: Are the exhibits submitted by the prosecutor actually pertinent to the crime? 2) Groundedness (Faithfulness): Does the verdict stem strictly from evidence admitted to the court docket, or did the jury hallucinate rumors? 3) Answer Relevance: Does the final judgment address the complaint filed by the plaintiff? The RAG Triad establishes these 3 mathematical checkpoints: score high on all three, and your AI is bulletproof!]
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
      RAG Triad Metriklerinin Matematiksel ve Operasyonel Tanımları: 1) Context Relevance: Getirilen metin parçalarının ne kadarı soruyla doğrudan ilgilidir? Düşükse: Chunking boyutunuz çok büyüktür veya Vektör benzerlik eşiğiniz çok düşüktür. 2) Groundedness (Faithfulness / Sadakat): Modelin ürettiği cümlenin her bir iddiası verilen bağlam dokümanından kanıtlanabiliyor mu? Düşükse: Model halüsinasyon görmektedir; Temperature çok yüksektir veya prompt gevşektir. 3) Answer Relevance: Üretilen yanıt kullanıcının orijinal sorusunu tam olarak yanıtlıyor mu? Düşükse: Model gevezelik yapmıştır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Mathematical Foundations of the RAG Triad (TruLens / Ragas): 1) Context Relevance: Precision of retrieved chunks relative to the user query. Low score indicates noisy embeddings or poor chunk boundaries. 2) Groundedness (Faithfulness): Ratio of claims in the generated completion that can be logically inferred from the retrieved context. A faithfulness score \<0.95 indicates active hallucination. 3) Answer Relevance: Semantic alignment between the completion and the original intent. Penalizes verbose tangents and evasive non-answers.]
    ]
  )
]

#java25_box[
```java
// Java 25: RAG Triad Değerlendirme Puan Kartı Modeli
public record RagTriadScorecard(
    double contextRelevance,   // 0.0 - 1.0 (Getirilen bağlamın isabeti)
    double groundednessScore,   // 0.0 - 1.0 (Halüsinasyonsuzluk / Sadakat)
    double answerRelevance      // 0.0 - 1.0 (Kullanıcı sorusuna uyum)
) {
    public boolean isProductionGrade() {
        return contextRelevance >= 0.80 
            && groundednessScore >= 0.95   // MAANG standardı: %95 üzeri sadakat zorunludur!
            && answerRelevance >= 0.85;
    }

    public double computeCompositeScore() {
        return (contextRelevance + (groundednessScore * 2.0) + answerRelevance) / 4.0;
    }
}

void main() {
    var scorecard = new RagTriadScorecard(0.88, 0.98, 0.92);
    IO.println("RAG Triad Birleşik Kalite Skoru: " + scorecard.computeCompositeScore());
    IO.println("Canlıya Çıkış İzni: " + (scorecard.isProductionGrade() ? "✅ ONAYLANDI" : "❌ GÜVENLİK SINIRI ALTINDA"));
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
      Kritik Metrik Hatası: Çoğu acemi ekip sadece 'Cevap güzel görünüyor mu' (Answer Relevance) diye bakar. Oysa cevap çok mantıklı ve akıcı görünse bile tamamen UYDURMA olabilir (Yüksek Answer Relevance, sıfır Groundedness)! Groundedness daima en öncelikli metriktir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[The Fluent Hallucination Trap: Evaluating AI systems solely by whether answers 'look articulate'. An answer can sound authoritative and convincing while being 100% fabricated. Groundedness (Faithfulness) is the single most critical safety metric.]
    ]
  )
]

#takeaways_box((
    ("RAG Triad; Context Relevance, Groundedness ve Answer Relevance ayaklarından oluşur.", "The RAG Triad comprises Context Relevance, Groundedness, and Answer Relevance."),
    ("Groundedness (Sadakat), cevabın tamamen verilen dokümana dayanıp dayanmadığını ölçer.", "Groundedness measures whether generated claims are strictly supported by context."),
    ("Kurumsal MAANG projelerinde Groundedness skoru %95'in altına düşemez.", "Enterprise production gates mandate Groundedness scores of >=95% to prevent liability."),
))
