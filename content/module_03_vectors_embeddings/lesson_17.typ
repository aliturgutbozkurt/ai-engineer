#import "/template.typ": *

#show: doc => setup_book(title: "Ders 17: Spring AI VectorStore: PostgreSQL pgvector Entegrasyonu ve Benzerlik Araması", doc)

#lesson_header(
  17,
  "Spring AI VectorStore: PostgreSQL pgvector Entegrasyonu ve Benzerlik Araması",
  "Spring AI VectorStore: PostgreSQL pgvector Integration & Similarity Search",
  "Vektörler, Embedding'ler ve Vektör Veritabanları",
  "Vectors, Embeddings & Vector Database Architecture"
)

#diagram_box[
```text
   [ METİN DOKÜMANI ] ──▶ Document("Spring AI ile RAG harika çalışır", metadata)
                                      │
                                      ▼
                       ┌─────────────────────────────┐
                       │    SPRING AI VectorStore    │
                       │  • embed(document.text)     │
                       │  • INSERT INTO vector_store │
                       └──────────────┬──────────────┘
                                      │
                                      ▼ (SQL: INSERT INTO vector_store ...)
               ┌──────────────────────────────────────────────┐
               │         POSTGRESQL WITH PGVECTOR             │
               │  id  |  content  |  metadata  |  embedding   │
               │ 101  | "Spring.."| {cat: "ai"}| [0.12, -0.4] │
               └──────────────────────┬───────────────────────┘
                                      │
               [ ARAMA SORGU ] ◀──────┘ (SELECT ... ORDER BY embedding <=> query LIMIT 3)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Elinizde binlerce kartvizit olduğunu düşünün. Normalde bir kartviziti bulmak için adına bakarsınız. Spring AI'ın `VectorStore`'u ise kartvizitlerin arkasına görünmez bir manyetik çip yapıştırır. Siz 'Bana yapay zekadan anlayan bir avukat bul' dediğinizde, elinize bir mıknatıs alır ve kutunun üstünde gezdirirsiniz; aradığınız konsepte en yakın 3 kartvizit 'ŞLAAAP' diye mıknatısa yapışır! Spring AI tüm bu mıknatıs (vektör) işlerini sizin yerinize tek satır kodla yönetir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Imagine a shoebox filled with 5,000 business cards. Spring AI's `VectorStore` attaches a semantic magnet to every card. When you query: 'Find me an attorney who specializes in international cloud compliance', you don't grep for exact keywords. You wave a query magnet over the box, and the 3 cards with the closest semantic magnetic polarity instantly snap onto your hand! Spring AI orchestrates the embedding, SQL insertion, and similarity queries behind a single unified interface!]
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
      Spring AI pgvector Entegrasyon Mekanizması: 1) Tablo Yapısı: `vector_store` tablosunda `id (UUID)`, `content (TEXT)`, `metadata (JSONB)` ve `embedding (vector(1536))` sütunları yer alır. 2) SearchRequest: `SearchRequest.query("...").withTopK(5).withSimilarityThreshold(0.75)` zinciri ile benzerlik eşiği ve sonuç sayısı ayarlanır. 3) Metadata Filtering: `withFilterExpression("category == 'finance' && year >= 2024")` ifadesi, SQL WHERE koşuluna dönüştürülerek vektör aramasından önce veya sonra (Pre/Post-filtering) işletilir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Spring AI pgvector Architecture: 1) Schema Definition: Operates against standard tables hosting `id (UUID)`, `content (text)`, `metadata (jsonb)`, and `embedding (vector(1536))`. 2) SearchRequest Builder: Fluent abstraction configuring `query()`, `topK()`, and `similarityThreshold()` (filtering out vectors with cosine similarity below a cutoff). 3) Native SQL Dialect Generation: Translates filter expressions into parameterized SQL WHERE clauses (`metadata->>'category' = 'finance'`), avoiding costly post-query in-memory filtering.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: pgvector VectorStore ile Benzerlik Araması
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.ai.vectorstore.SearchRequest;
import java.util.List;
import java.util.Map;

public class KnowledgeBaseService {
    private final VectorStore vectorStore;

    public KnowledgeBaseService(VectorStore vectorStore) {
        this.vectorStore = vectorStore;
    }

    public void ingestDocument(String docId, String text, String department) {
        var document = new Document(docId, text, Map.of("department", department));
        vectorStore.add(List.of(document)); // Otomatik embed edilir ve pgvector'e yazılır!
    }

    public List<Document> searchRelevantKnowledge(String query, String department) {
        return vectorStore.similaritySearch(
            SearchRequest.builder()
                .query(query)
                .topK(3)
                .similarityThreshold(0.70)
                .filterExpression("department == '" + department + "'")
                .build()
        );
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
      Performans Darboğazı: `similarityThreshold` belirtmezseniz, aradığınız konuyla uzaktan yakından ALAKASI OLMAYAN dokümanlar bile ilk 3 sırada gelerek modelin bağlamını kirletir ve halüsinasyona yol açar! Daima makul bir eşik (ör. 0.70+) belirleyin.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Retrieval pitfall: Querying without a `similarityThreshold` forces the vector store to return the top \$K\$ nearest neighbors even if their similarity score is abysmal (e.g. 0.20), poisoning the prompt context with irrelevant garbage.]
    ]
  )
]

#takeaways_box((
    ("Spring AI VectorStore, doküman yükleme ve vektör aramasını tekilleştiren bir SPI'dır.", "Spring AI VectorStore unifies document ingestion, embedding, and ANN retrieval behind a clean SPI."),
    ("Metadata filtreleme, alakasız dokümanları SQL seviyesinde eleyerek arama doğruluğunu artırır.", "Metadata filtering at the database layer drastically improves search relevance and speed."),
    ("Benzerlik eşiği (Similarity Threshold) halüsinasyonu önlemede ilk savunma hattıdır.", "A well-calibrated similarity threshold is your first line of defense against hallucinations."),
))
