#import "/template.typ": *

#show: doc => setup_book(title: "Ders 14: Vektör Benzerlik Metrikleri: Cosine Similarity, Dot Product & Euclidean Distance", doc)

#lesson_header(
  14,
  "Vektör Benzerlik Metrikleri: Cosine Similarity, Dot Product & Euclidean Distance",
  "Vector Distance Metrics: Cosine Similarity, Dot Product & Euclidean (L2) Distance",
  "Vektörler, Embedding'ler ve Vektör Veritabanları",
  "Vectors, Embeddings & Vector Database Architecture"
)

#diagram_box[
```text
   [ COSINE SIMILARITY ]                    [ EUCLIDEAN (L2) DISTANCE ]
   Açıya bakar (Uzunluk önemsiz!)           Fiziksel düz çizgi mesafesine bakar
   
          Vektör A (Uzun metin)                     Vektör A
          ▲                                         ▲
          │   / Vektör B (Kısa metin)               │ \
          │  /                                      │  \  (Düz mesafe d)
          │ /  Açı θ küçüktür!                      │   \
          └───────▶                                 └────▶ Vektör B
   Cos(θ) = 1.0 (Aynı Anlam)                d = 0.0 (Birebir Aynı Nokta)
   Cos(θ) = 0.0 (Alakasız)                  d > 10.0 (Çok Uzak)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      İki ok düşünün: Biri 10 metre uzunluğunda devasa bir mızrak (uzun bir paragraf), diğeri 10 santimlik minik bir iğne (kısa bir başlık). İkisi de tam olarak aynı yöne (kuzeye) bakıyorsa, konuları BİREBİR AYNIDIR! Cosine Similarity boya veya uzunluğa bakmaz; sadece iki okun arasındaki açıya bakar! Açı sıfırsa benzerlik 1'dir. Euclidean Distance ise iki okun uçları arasındaki cetvel mesafesini ölçer. Arama motorlarında metin uzunlukları farklı olabildiği için her zaman Cosine Similarity tercih edilir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Imagine two arrows pointing due North: one is a 10-foot wooden javelin (a comprehensive 500-word article), the other is a 2-inch dart (a 5-word headline). Because they point in the exact same direction, their semantic topic is identical! Cosine Similarity measures strictly the angle between vectors, completely ignoring document length magnitude. Euclidean (L2) distance measures absolute spatial distance with a ruler. For textual retrieval where document chunk sizes vary, Cosine Distance is the industry standard!]
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
      Matematiksel Formüller ve Donanım Optimizasyonu: 1) Cosine Similarity: Cos(θ) = (u · v) / (||u|| · ||v||). Sonuç -1 ile +1 arasındadır. 2) Dot Product: u · v = Σ(u_i · v_i). Eğer vektörler birim normalizasyona sahipse (||u|| = ||v|| = 1), Cosine Similarity ile Dot Product BİREBİR AYNI sonucu verir! Dot product karekök ve bölme işlemi gerektirmediği için CPU SIMD / AVX-512 ve GPU'larda 5 kat daha hızlı hesaplanır. 3) Euclidean (L2): d = √(Σ (u_i - v_i)²). Boyut büyüklüğüne duyarlıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Vector metric mechanics and hardware acceleration: 1) Cosine Similarity: Evaluates orientation (Cos(θ) = (u · v) / (||u|| · ||v||)), bounding values between -1.0 and 1.0. 2) Dot Product Optimization: If embedding vectors are normalized to unit length (L2 = 1.0), Cosine Similarity is algebraically identical to the raw Dot Product (u · v). Eliminating the magnitude denominator allows modern CPUs to leverage AVX-512 SIMD vector instructions, accelerating distance calculations by 500%. 3) Euclidean (L2): Measures point-to-point Pythagorean distance; sensitive to text magnitude.]
    ]
  )
]

#java25_box[
```java
// Java 25: İki Vektör Arasındaki Cosine Similarity ve Dot Product Hesaplama
public class VectorDistanceCalculator {
    public static double cosineSimilarity(float[] vectorA, float[] vectorB) {
        if (vectorA.length != vectorB.length) {
            throw new IllegalArgumentException("Vektör boyutları eşit olmalıdır!");
        }

        double dotProduct = 0.0;
        double normA = 0.0;
        double normB = 0.0;

        for (int i = 0; i < vectorA.length; i++) {
            dotProduct += vectorA[i] * vectorB[i];
            normA += vectorA[i] * vectorA[i];
            normB += vectorB[i] * vectorB[i];
        }

        if (normA == 0.0 || normB == 0.0) return 0.0;
        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }
}

void main() {
    float[] query = {0.8f, 0.6f, 0.0f};
    float[] docA  = {0.8f, 0.6f, 0.0f}; // Birebir aynı yön
    float[] docB  = {-0.6f, 0.8f, 0.0f}; // Dik açı (Alakasız)

    IO.println("Sorgu - DocA Benzerliği: " + VectorDistanceCalculator.cosineSimilarity(query, docA)); // 1.0
    IO.println("Sorgu - DocB Benzerliği: " + VectorDistanceCalculator.cosineSimilarity(query, docB)); // 0.0
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
      Vektör Veritabanı Tuzağı: pgvector veya Pinecone'da indeks oluştururken metriği yanlış seçmek (örneğin normalize edilmiş OpenAI vektörleri için Cosine yerine L2 Distance seçmek) hem arama kalitesini düşürür hem de sorguları yavaşlatır. OpenAI için daima `vector_cosine_ops` veya `vector_ip_ops` (Inner Product) seçilmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Database index pitfall: Selecting L2 distance in pgvector when indexing normalized OpenAI vectors degrades search throughput. Always specify the inner product index (`vector_ip_ops`) for maximum SIMD efficiency.]
    ]
  )
]

#takeaways_box((
    ("Cosine Similarity metin uzunluğundan bağımsız olarak anlamsal açıyı ölçer.", "Cosine Similarity measures semantic directionality independent of document length."),
    ("Normalize edilmiş vektörlerde Dot Product, Cosine ile aynıdır ama çok daha hızlıdır.", "For normalized vectors, Dot Product equals Cosine Similarity with dramatically lower CPU cost."),
    ("Vektör veritabanı indeksi kurulurken embedding modelinin beklediği metrik seçilmelidir.", "Vector database index operators must explicitly match your embedding model's properties."),
))
