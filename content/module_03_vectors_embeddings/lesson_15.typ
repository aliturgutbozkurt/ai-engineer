#import "/template.typ": *

#show: doc => setup_book(title: "Ders 15: Vektör İndeksleme Algoritmaları: HNSW (Hierarchical Navigable Small World) & IVF", doc)

#lesson_header(
  15,
  "Vektör İndeksleme Algoritmaları: HNSW (Hierarchical Navigable Small World) & IVF",
  "Approximate Nearest Neighbors (ANN): Inside HNSW & IVF Indexing Algorithms",
  "Vektörler, Embedding'ler ve Vektör Veritabanları",
  "Vectors, Embeddings & Vector Database Architecture"
)

#diagram_box[
```text
   [ KATMAN 2 (Seyrek Ekspres Hat) ]  Node A ────────────────────────▶ Node Z
                                             │                                │
                                             ▼                                ▼
   [ KATMAN 1 (Bölgesel Ağ) ]         Node A ──────▶ Node M ─────────▶ Node Z
                                             │              │                 │
                                             ▼              ▼                 ▼
   [ KATMAN 0 (Tüm Vektörler) ]       Node A ─▶ B ─▶ C ─▶ D ─▶ M ─▶ P ─▶ R ─▶ Z
   
   Arama Süreci:
   1. En üst katmandan başla (büyük adımlar at).
   2. Hedefe yaklaştıkça alt katmanlara in (Hızlı O(log N) yakınsama!).
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      1 milyon kişilik bir şehirde Ali'nin evini aradığınızı düşünün. Tek tek 1 milyon evin kapısını çalarsanız (Kaba Kuvvet / Brute-Force O(N)) aylar sürer! Bunun yerine önce uçağa binip şehre kuş bakışı bakarsınız (Katman 2), sonra doğru semte inip arabayla ana caddeye girersiniz (Katman 1), en son sokaktaki kapı numarasına bakarsınız (Katman 0)! HNSW (Hierarchical Navigable Small World) algoritması tam olarak bu otoban sistemidir: Milyonlarca vektör arasında aradığınız en yakın 5 dokümanı 2 milisaniyede bulur!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Locating a specific house among 1,000,000 homes by knocking on every door sequentially takes months (Brute-Force Flat Search O(N)). Instead, you take an interstate highway across regions (Layer 2), exit onto an arterial boulevard into the right neighborhood (Layer 1), and walk the final residential street to the exact address (Layer 0). Hierarchical Navigable Small World (HNSW) organizes vector space into this multi-layer highway graph, executing Approximate Nearest Neighbor (ANN) searches across millions of embeddings in sub-5ms (O(log N))!]
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
      Vektör İndeks Algoritmalarının Karşılaştırması: 1) Flat Index (Kaba Kuvvet): %100 kesin sonuç verir (Recall 1.0) ancak her aramada tüm vektörlerle tek tek iç çarpım yapar (O(N)). 100k vektörden sonra çöker. 2) IVF (Inverted File Index): Vektörleri k-means ile Voronoi hücrelerine kümeler; sorgu sadece en yakın 3-5 kümede aranır. Hızlıdır ancak güncellemesi (insert) zordur. 3) HNSW (Skip-List Tabanlı Graf): Günümüzün altın standardıdır. Hem yüksek Recall (%98+) sunar hem de arama süresi O(log N)'dir. Tek dezavantajı: Graf bağlantılarını tuttuğu için RAM tüketimi %20-%30 daha fazladır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Vector Index Engineering & Trade-offs: 1) Flat Index (Exact Brute-Force): Guarantees 100% recall via exhaustive comparison, but scales at O(N · D). Unusable past 50,000 vectors at production SLAs. 2) IVF (Inverted File Index): Partitions vector space into Voronoi centroids using K-means clustering. Prunes search to top n clusters; sensitive to centroid drift under continuous updates. 3) HNSW (Hierarchical Navigable Small World): Multi-layer skip-graph architecture. Achieves >98% recall with O(log N) search latency. Primary trade-off: higher RAM consumption to retain graph edge pointers.]
    ]
  )
]

#java25_box[
```java
// Java 25: pgvector için HNSW İndeks DDL SQL Tanımı
public class VectorIndexConfiguration {
    public static final String CREATE_HNSW_INDEX_SQL = """
        -- 1536 Boyutlu OpenAI Vektörleri için HNSW İndeksi Oluşturma
        CREATE INDEX IF NOT EXISTS document_embedding_hnsw_idx 
        ON document_store 
        USING hnsw (embedding vector_cosine_ops)
        WITH (
            m = 16,               -- Düğüm başına maksimum komşu kenar sayısı (Default: 16)
            ef_construction = 64  -- İndeks inşa edilirken taranacak aday listesi boyutu
        );
        """;

    public static final String QUERY_HNSW_SQL = """
        -- HNSW Arama Sırasında ef_search ayarı (Hız vs Recall dengesi)
        SET hnsw.ef_search = 40;
        
        SELECT id, content, 1 - (embedding <=> :queryVector) AS similarity
        FROM document_store
        ORDER BY embedding <=> :queryVector
        LIMIT 5;
        """;
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
      Üretim Uyarısı: HNSW indeksini 1 milyon kayıt yüklendikten sonra sıfırdan oluşturmak devasa CPU tüketir ve saatlerce sürebilir. Veri büyümeden önce indeksi baştan tanımlayın veya veriyi parça parça (Batch) yükleyin.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Operational hazard: Constructing an HNSW index on a pre-populated table with millions of vectors can saturate CPU and lock database memory for hours. Provision adequate build memory (`maintenance_work_mem`) and index incrementally.]
    ]
  )
]

#takeaways_box((
    ("Brute-Force arama üretimde ölçeklenmez; ANN (Yaklaşık En Yakın Komşu) zorunludur.", "Exhaustive brute-force search is unviable at scale; ANN graph indexing is mandatory."),
    ("HNSW, endüstride hız ve doğruluk (Recall) dengesi en iyi olan algoritmadır.", "HNSW provides the industry's premier trade-off between recall accuracy and low query latency."),
    ("m ve ef parametreleri RAM kullanımı ile arama kalitesi arasındaki takası belirler.", "Tuning `m` and `ef` balances memory overhead against search precision."),
))
