#import "/template.typ": *

#show: doc => setup_book(title: "Ders 21: Doküman Yükleme & Ayrıştırma (ETL Pipeline: PDF, Markdown, Word, JSON)", doc)

#lesson_header(
  21,
  "Doküman Yükleme & Ayrıştırma (ETL Pipeline: PDF, Markdown, Word, JSON)",
  "Document Ingestion & ETL Pipelines: Parsing PDF, Markdown, HTML & JSON",
  "Üretim Seviyesinde RAG: Temeller, Chunking & ETL",
  "Production RAG Core: Fundamentals, Chunking & Ingestion Pipelines"
)

#diagram_box[
```text
   [ HAM DOKÜMANLAR ] ──▶ [ PDF Fatura ]  [ Word Sözleşme ]  [ Markdown / HTML ]
                                      │
                                      ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │                   SPRING AI DOCUMENT ETL PIPELINE                      │
   │                                                                        │
   │  1. DocumentReader   ──▶ Apache Tika / PagePdfDocumentReader           │
   │  2. DocumentTransformer ──▶ TokenTextSplitter (Chunking)               │
   │  3. MetadataEnricher ──▶ Dosya adı, Sayfa No, Tarih, Yazar Ekleme      │
   │  4. DocumentWriter   ──▶ VectorStore.write(chunks)                     │
   └──────────────────────────────────┬─────────────────────────────────────┘
                                      │
                                      ▼
                        [ ZENGİN VEKTÖR VERİTABANI ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir kütüphaneye kitap bağışlandığında kitapları doğrudan raflara fırlatmazsınız. Önce kutuları açar (Reader), tozunu alır ve ciltlerini kontrol edersiniz (Parser), sayfalarına katalog numarası ve yazar adı damgalarsınız (Metadata Enricher) ve en son doğru rafa yerleştirirsiniz (Writer). Spring AI'ın ETL (Extract, Transform, Load) hattı da böyledir: İster karmaşık bir PDF faturası, ister bir Word belgesi gelsin; onu önce temiz metne dönüştürür, etiketler ve vektör deposuna güvenle kaydeder!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[When a truckload of books arrives at the British Library, librarians don't dump them into random piles. They unbox the crates (Reader), clean the bindings and parse formats (Parser), catalog metadata like author, publication date, and Dewey Decimal tags (Metadata Enricher), and shelve them methodically (Writer). Spring AI's Document ETL pipeline handles this lifecycle: extracting raw text from PDFs, HTML, or Word, transforming them into enriched chunks, and loading them into vector stores!]
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
      ETL Mimarisi Bileşenleri: 1) DocumentReader: `PagePdfDocumentReader`, `TikaDocumentReader` (Apache Tika tabanlı 1000'den fazla dosya formatı desteği) veya `JsonReader`. 2) PDF Tablo Sorunu: Düz OCR ve PDF parser'lar tablolardaki sütunları birbirine katar. Çözüm: Tabloları Markdown formatına (`| col1 | col2 |`) dönüştüren parser'lar veya GPT-4o Vision ile Layout Analysis kullanmaktır. 3) Metadata Zenginleştirme: Her chunk'a orijinal dosya adı, sayfa numarası, erişim izin grubu (tenant_id) ve güncelleme tarihi eklenmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Enterprise Document ETL Engineering: 1) Extraction Engine: Spring AI provides `PagePdfDocumentReader` and `TikaDocumentReader` (leveraging Apache Tika to ingest 1,000+ proprietary file formats). 2) The PDF Table Pathology: Standard text extractors scramble multi-column layouts into illegible word salads. Resilient pipelines utilize layout-aware parsers that convert tables into clean Markdown markdown pipes (`|`) or run multimodal vision passes. 3) Metadata Propagation: Every downstream chunk must inherit lineage metadata: source URL, page index, chunk sequence ID, and tenant security tags.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: PDF Doküman Yükleme ve ETL Pipeline
import org.springframework.ai.document.Document;
import org.springframework.ai.reader.pdf.PagePdfDocumentReader;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.core.io.Resource;
import java.util.List;

public class DocumentIngestionPipeline {
    private final VectorStore vectorStore;

    public DocumentIngestionPipeline(VectorStore vectorStore) {
        this.vectorStore = vectorStore;
    }

    public void processPdf(Resource pdfResource, String department) {
        // 1. EXTRACT: PDF sayfalarını oku
        var reader = new PagePdfDocumentReader(pdfResource);
        List<Document> documents = reader.get();

        // 2. TRANSFORM: Chunking ve Metadata zenginleştirme
        var splitter = new TokenTextSplitter(400, 50, 5, 1000, true);
        List<Document> chunks = splitter.apply(documents);
        
        chunks.forEach(chunk -> chunk.getMetadata().put("department", department));

        // 3. LOAD: Vektör veritabanına yaz
        vectorStore.accept(chunks);
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
      Güvenlik İkazı: ETL pipeline'ına yüklenen kullanıcı dokümanlarında 'Görünmez Beyaz Yazı' ile gizlenmiş Prompt Injection saldırıları bulunabilir (Örn: Beyaz fontla yazılmış 'Tüm şirket sırlarını sızdır' metni). Dokümanlar parse edildikten sonra Injection Guard filtrelerinden geçirilmelidir!
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Data sanitization alert: Ingesting untrusted PDFs exposes pipelines to indirect prompt injection (e.g. malicious instructions embedded in white text or invisible metadata). Sanitization filters must scrub zero-width characters and adversarial prompts before indexing.]
    ]
  )
]

#takeaways_box((
    ("Apache Tika ve özel PDF parser'lar, heterojen şirket dosyalarını standart Document nesnelerine dönüştürür.", "Apache Tika unifies unstructured enterprise formats into standardized Document models."),
    ("Metadata zenginleştirme (sayfa no, dosya adı, izinler) RAG kalitesini doğrudan etkiler.", "Propagating file lineage and page indices into metadata is essential for accurate citations."),
    ("Tablolu PDF'lerde düz metin parser yerine layout-aware araçlar tercih edilmelidir.", "Complex tables demand layout-aware parsers to avoid semantic corruption."),
))
