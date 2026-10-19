#import "/template.typ": *

#show: doc => setup_book(title: "Ders 13: Embedding Nedir? Metinlerin Çok Boyutlu Matematiksel Haritası", doc)

#lesson_header(
  13,
  "Embedding Nedir? Metinlerin Çok Boyutlu Matematiksel Haritası",
  "Demystifying Embeddings: Mapping Semantic Meaning into Dense Vector Space",
  "Vektörler, Embedding'ler ve Vektör Veritabanları",
  "Vectors, Embeddings & Vector Database Architecture"
)

#diagram_box[
```text
   [ METİNLER ]                       [ EMBEDDING ENGINE ]           [ 1536-BOYUTLU VEKTÖR ]
   "Kedi süt içiyor"    ──▶ [ text-embedding-3-small ] ──▶ [ 0.124, -0.892, 0.451, ... ]
   "Köpek mama yiyor"   ──▶ [ text-embedding-3-small ] ──▶ [ 0.119, -0.875, 0.440, ... ]  (Çok Yakın!)
   "Kuantum fiziği"     ──▶ [ text-embedding-3-small ] ──▶ [ -0.741, 0.312, -0.912, ... ] (Çok Uzak!)
   
                     SEMANTİK ÇOK BOYUTLU UZAY (2D İZDÜŞÜMÜ)
                     ▲
     Evcil Hayvanlar │      • "Kedi süt içiyor"
                     │    • "Köpek mama yiyor"
                     │
                     │                           • "Kuantum fiziği" (Bilim)
                     └────────────────────────────────────────▶ Anlam Ekseni
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir kütüphanedeki kitapları sadece adına göre sıralarsanız, 'Kedi Bakımı' ile 'Köpek Eğitimi' kitapları farklı raflara düşer. Ama kitapları konusuna göre 3 boyutlu bir haritada yerleştirirseniz: Birinci eksen 'Hayvan Sevgisi', ikinci eksen 'Yemek', üçüncü eksen 'Bilim' olsun. Kedi ve köpek kitapları haritada yan yana dururken, 'Kuantum Fiziği' odanın öbür ucuna uçar! İşte Embedding tam olarak budur: Bilgisayarın kelimelerin anlamını anlayabilmesi için her cümleye 1536 adet koordinat sayısı (Vektör) vermesidir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Alphabetical library sorting places 'Cat Nutrition' and 'Dog Training' far apart under C and D. Now imagine placing books in a 3D coordinate room where Axis-X is 'Pet Care', Axis-Y is 'Dietary', and Axis-Z is 'Astrophysics'. Pet books cluster closely together, while 'Quantum Mechanics' sits on the opposite wall! That is an Embedding: a neural transformation converting unstructured human prose into a dense array of floating-point coordinates (1,536 dimensions) where semantic proximity equals geometric proximity!]
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
      Embedding Modellerinin Teknik Detayları: 1) Boyutluluk (Dimensionality): OpenAI `text-embedding-3-small` 1536 boyutlu, `text-embedding-3-large` ise 3072 boyutlu vektörler üretir. Boyut arttıkça anlam hassasiyeti artar ancak depolama ve RAM maliyeti katlanır. 2) Matryoshka Embeddings: OpenAI'ın v3 modelleri, Rus matruşka bebekleri gibi ilk 512 boyutu alıp geri kalanını kırpmanıza (Truncation) izin verir; doğruluk %98 korunurken veritabanı boyutu %66 küçülür! 3) Normalizasyon: OpenAI vektörleri birim uzunluktadır (||v|| = 1); bu sayede pahalı Cosine Similarity yerine süper hızlı Dot Product (İç Çarpım) kullanılabilir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Embedding Mathematics and Economics: 1) Dense Vector Topology: `text-embedding-3-small` outputs 1,536-dimensional float32 arrays (6KB per vector). `text-embedding-3-large` scales to 3,072 dimensions for subtle multi-domain nuances. 2) Matryoshka Representation Learning (MRL): Modern v3 embeddings allow truncation to lower dimensions (e.g. 512 or 256) while retaining >95% retrieval accuracy, slashing RAM and storage footprint by 66%. 3) Unit Normalization: Vectors are pre-normalized to unit magnitude (L2 norm = 1.0). Consequently, Cosine Distance simplifies mathematically to a raw Dot Product (u · v), reducing CPU vector search cycles.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: Metinleri Vektör Embedding'e Dönüştürme
import org.springframework.ai.embedding.EmbeddingModel;
import java.util.List;

public class EmbeddingGeneratorService {
    private final EmbeddingModel embeddingModel;

    public EmbeddingGeneratorService(EmbeddingModel embeddingModel) {
        this.embeddingModel = embeddingModel;
    }

    public float[] generateVector(String text) {
        // OpenAI text-embedding-3-small çağrısı yapar ve 1536 float döner
        return embeddingModel.embed(text);
    }

    public List<float[]> batchEmbed(List<String> documents) {
        return embeddingModel.embed(documents);
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
      Ölümcül Hata: Dokümanları `text-embedding-3-small` (1536 boyut) ile indeksleyip, arama yaparken sorguyu `text-embedding-3-large` (3072 boyut) veya Cohere ile vektörleştiremezsiniz! İndeksleme ve sorgulama modelleri BİREBİR AYNI model ve boyut olmak zorundadır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Catastrophic error: Searching an index embedded with `text-embedding-3-small` using queries embedded via `text-embedding-3-large` or HuggingFace. Vector dimensions and semantic manifolds must match 100% identically across ingestion and query pipelines.]
    ]
  )
]

#takeaways_box((
    ("Embedding, metinlerin anlamsal özünü çok boyutlu koordinat sayılarına dönüştürür.", "Embeddings compress semantic human intent into dense high-dimensional vectors."),
    ("Benzer anlama gelen cümleler vektör uzayında geometrik olarak birbirine çok yakındır.", "Semantically related sentences cluster tightly in vector space."),
    ("Matryoshka boyutsallık kırpma, doğruluktan ödün vermeden RAM maliyetini %66 düşürür.", "Matryoshka representation learning allows truncation to slash vector memory spend by 66%."),
))
