#import "/template.typ": *

#show: doc => setup_book(title: "Ders 26: Yeniden Sıralama (Re-ranking): Cross-Encoder Modelleri ve Cohere Rerank", doc)

#lesson_header(
  26,
  "Yeniden Sıralama (Re-ranking): Cross-Encoder Modelleri ve Cohere Rerank",
  "Two-Stage Retrieval: Cross-Encoders & Re-ranking with Cohere / BGE-Reranker",
  "İleri Düzey RAG (Advanced RAG) & Bilgi Getirme Optimizasyonu",
  "Advanced RAG & Information Retrieval Optimization"
)

#diagram_box[
```text
   [ KULLANICI SORUSU ]
            │
            ▼ (1. AŞAMA: Hızlı Bi-Encoder Vektör Arama - 100 Aday Getir)
   ┌────────────────────────────────────────────────────────┐
   │         VEKTÖR DEPOSU (Top 100 Kaba Aday)              │
   │  Hızlıdır (~5ms), ancak derin anlam ilişkisini kaçırır │
   └────────────────────────┬───────────────────────────────┘
                            │
                            ▼ 100 Doküman
   ┌────────────────────────────────────────────────────────┐
   │    2. AŞAMA: CROSS-ENCODER RE-RANKER (Cohere / BGE)    │
   │  (Soru + Doküman) çiftini birlikte tam attention'a sok │
   │  Ağır ve pahalıdır (~50ms) ama isabeti %99'dur!        │
   └────────────────────────┬───────────────────────────────┘
                            │
                            ▼ En İyi 3 Parçayı Seç
               [ PROMPT İÇİN EN İSABETLİ BAĞLAM ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir şirkete 10.000 kişi iş başvurusu yaptığında genel müdür 10.000 CV'nin hepsini tek tek 1 saat boyunca mülakat edemez (Cross-Encoder çok yavaştır). Önce İK bir filtre koyar: 'Mühendislik mezunu ilk 100 kişiyi ayır' (1. Aşama: Hızlı Vektör Arama). Sonra genel müdür bu 100 adayı masasına alır, her birinin gözünün içine bakarak detaylı mülakat yapar ve en iyi 3 kişiyi işe alır (2. Aşama: Re-ranking)! Re-ranking, arama motorunun getirdiği 50 parçayı tekrar okuyup en doğru ilk 3 parçayı öne çıkarma sanatıdır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[When 10,000 candidates apply for an engineering job, the VP of Engineering cannot conduct a 60-minute deep technical interview with all 10,000 (Cross-Encoder is computationally heavy). First, HR runs an automated keyword/vector filter to select the top 50 resumes in seconds (Stage 1: Bi-Encoder ANN Search). Then, the VP personally evaluates those 50 resumes with rigorous scrutiny to select the 3 best hires (Stage 2: Re-ranking). Two-stage retrieval pairs fast vector search with cross-encoder precision!]
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
      Bi-Encoder vs Cross-Encoder Mimarisi: 1) Bi-Encoder (Standart Embedding): Dokümanı ve sorguyu birbirinden bağımsız embed eder. Hızlıdır (O(1) karşılaştırma) ancak soru ile metin arasındaki çapraz dikkat (Cross-Attention) kurulamaz. 2) Cross-Encoder (Re-ranker): `(Sorgu, Doküman)` çiftini tek bir transformer modeline aynı anda sokar. Token'ların birbirine olan ilgisini tam olarak hesaplar. 1000 dokümanda çok yavaştır, ancak ilk 50 dokümanı yeniden sıralamak için idealdir (ör. Cohere Rerank, BGE-Reranker-v2). 3) Metrik Kazancı: Re-ranking aşaması RAG sistemlerinde NDCG\@10 ve MRR metriklerini %25'e kadar yükseltir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Bi-Encoder vs Cross-Encoder Computational Topologies: 1) Bi-Encoders: Map query and document independently into fixed-length vectors (f(q) and f(d)). Search relies on simple inner products (f(q) · f(d)). Extremely fast, but zero cross-token interaction. 2) Cross-Encoders: Ingest query and document concatenated as a single sequence ([CLS] ○ q ○ [SEP] ○ d). Every query token attends directly to every document token across all transformer layers. Prohibitively expensive across millions of documents, but unbeatable when re-scoring the top 20-50 candidates. 3) Impact: Typically elevates MRR\@10 and NDCG\@5 by 15-25% in enterprise benchmarks.]
    ]
  )
]

#java25_box[
```java
// Java 25 & LangChain4j: Cohere / ScoringModel ile Re-ranking Entegrasyonu
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.cohere.CohereScoringModel;
import dev.langchain4j.rag.query.Query;
import java.util.List;

public class ReRankingPipeline {
    private final CohereScoringModel scoringModel;

    public ReRankingPipeline(String cohereApiKey) {
        this.scoringModel = CohereScoringModel.builder()
            .apiKey(cohereApiKey)
            .modelName("rerank-v3.5")
            .build();
    }

    public List<TextSegment> reRankCandidates(String userQuery, List<TextSegment> initialCandidates, int topN) {
        var query = Query.from(userQuery);
        
        // Cross-encoder ile adayları puanla
        var scoredList = scoringModel.scoreAll(initialCandidates, userQuery).content();

        // En yüksek puana göre sırala ve ilk topN'i döndür
        return initialCandidates.stream()
            .sorted(Comparator.comparingDouble((TextSegment seg) -> 
                scoredList.get(initialCandidates.indexOf(seg))).reversed())
            .limit(topN)
            .toList();
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
      Gecikme Uyarısı (Latency Budget): Re-ranking aşaması sisteme ek bir 50-150ms gecikme ekler. Eğer uygulamanız SLA olarak \<300ms yanıt süresi hedefliyorsa, re-ranker'a 100 doküman yerine sadece en iyi 15-20 dokümanı gönderin.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Latency budget hazard: Cross-encoder re-ranking adds 50-150ms of network and inference latency. If your production SLA targets sub-300ms total response time, cap your candidate pool to top 15-20 segments before reranking.]
    ]
  )
]

#takeaways_box((
    ("İki aşamalı getirme (Two-Stage Retrieval), hız ile doğruluğu mükemmel dengeler.", "Two-stage retrieval delivers the optimal compromise between low latency and high accuracy."),
    ("Bi-Encoder ilk elemede hızlı arama yapar; Cross-Encoder en iyi adayları kesin sıralar.", "Bi-encoders prune millions of candidates; cross-encoders refine the top candidates."),
    ("Cohere Rerank veya yerel BGE-Reranker, RAG halüsinasyonlarını doğrudan azaltır.", "Re-ranking significantly reduces hallucination risk by boosting true relevant context to the top."),
))
