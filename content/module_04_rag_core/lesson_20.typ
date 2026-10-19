#import "/template.typ": *

#show: doc => setup_book(title: "Ders 20: Metin Parçalama (Chunking) Stratejileri: Fixed Size, Sliding Window & Semantic", doc)

#lesson_header(
  20,
  "Metin Parçalama (Chunking) Stratejileri: Fixed Size, Sliding Window & Semantic",
  "Chunking Strategies: Fixed-Size, Sliding Window, Recursive & Semantic Splitting",
  "Üretim Seviyesinde RAG: Temeller, Chunking & ETL",
  "Production RAG Core: Fundamentals, Chunking & Ingestion Pipelines"
)

#diagram_box[
```text
   [ ORİJİNAL DOKÜMAN (1000 Kelime) ]
   
   1. FIXED-SIZE CHUNKING (Kaba / Kesici)
   [ Parça 1 (500 Karakter) ] [ Parça 2 (500 Karakter) ] ──▶ Cümle ortadan ikiye bölündü! (HATA)
   
   2. SLIDING WINDOW WITH OVERLAP (Örtüşmeli Pencere)
   ┌──────────────────────────┐
   │ Parça 1 (0 - 500)        │
   └─────────────┬────────────┘
                 │ (100 Karakter Örtüşme / Overlap)
                 ┌────────────┴─────────────┐
                 │ Parça 2 (400 - 900)      │ ──▶ Anlam kaybı önlendi!
                 └──────────────────────────┘
   
   3. SEMANTIC CHUNKING (Anlamsal Bölme)
   [ Paragraf / Bölüm Sonu ] ──▶ Embedding mesafesi zıpladığında yeni parçaya geç!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Koca bir karpuzu tek lokmada yiyemezsiniz; dilimlemeniz gerekir. Ama karpuzu gözünüz kapalı bıçakla rastgele keserseniz (Fixed Size), çekirdekler dağılır ve meyve ziyan olur. Akıllı bir şef karpuzu doğal dilim çizgilerinden keser (Semantic Chunking). Metin parçalama da böyledir: Bir kitabı 500'er harflik kör bloklara bölerseniz cümlenin yarısı birinci parçada, yarısı ikinci parçada kalır ve anlam yok olur! Parçaların ucunu hafifçe birbirinin üstüne bindirirseniz (Overlap), anlam bütünlüğü korunur!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[You can't swallow a whole watermelon; you must slice it. Blindly hacking it with a machete every 4 inches cuts across seeds and crushes the fruit (Fixed-Size Chunking). An expert chef cuts along the natural rind segments (Semantic Chunking). If you chop text blindly by character counts, sentences fracture mid-thought. By introducing a 10-20% Sliding Window Overlap, the trailing context of Chunk A bridges smoothly into Chunk B, preserving pronoun and causal coherence!]
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
      Chunking Stratejileri ve Trade-Off Analizi: 1) Fixed-Size with Overlap: En yaygın başlangıçtır (ör. 512 token chunk size, 50 token overlap). Hızlıdır ancak anlamsal sınırları (başlıklar, paragraflar) gözetmez. 2) Recursive Character Splitting: Önce çift satır başlarına (`\n\n`), sonra tek satırlara (`\n`), sonra noktalara (`.`) bakar; cümleyi asla ortadan bölmez. 3) Semantic Chunking: Cümleleri tek tek embed eder. Ardışık iki cümle arasındaki Cosine mesafesi belirli bir eşiği (ör. 0.3) aştığında yeni bir konuya geçildiğini anlar ve oradan keser. Hesaplama maliyeti yüksektir ancak arama kalitesi zirvedir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Chunking Engineering & Trade-Offs: 1) Fixed-Size with Overlap: Slices text into uniform token counts (e.g. 500 tokens with 50-token stride). Computationally cheap (\$O(N)\$), but ignores natural semantic paragraph boundaries. 2) Recursive Hierarchical Splitting: The industry standard. Cascades through separators (`\n\n` -> `\n` -> `. ` -> ` `), preserving paragraph and sentence integrity. 3) Semantic Splitting: Computes pairwise embedding distances across adjacent sentences; splits when cosine distance spikes past a percentile threshold, signaling a topic transition.]
    ]
  )
]

#java25_box[
```java
// Java 25 & LangChain4j: Recursive ve Örtüşmeli (Overlap) Metin Parçalama
import dev.langchain4j.data.document.Document;
import dev.langchain4j.data.document.splitter.DocumentSplitters;
import dev.langchain4j.data.segment.TextSegment;
import java.util.List;

public class ChunkingPipeline {
    public static List<TextSegment> splitDocumentRecursively(String rawContent) {
        var document = Document.from(rawContent);

        // Maksimum 300 token parça boyutu, 40 token örtüşme (overlap)
        var splitter = DocumentSplitters.recursive(
            300,  // maxSegmentSizeInTokens
            40    // maxOverlapSizeInTokens
        );

        return splitter.split(document);
    }
}

void main() {
    String policy = """
        Bölüm 1: Uzaktan Çalışma Politikası.
        Çalışanlar haftada 3 gün evden çalışabilir.
        Evden çalışma günlerinde mesai saatlerine tam riayet esastır.
        
        Bölüm 2: Donanım Desteği.
        Şirket her çalışana ergonomik sandalye ve monitör bütçesi sağlar.
        """;

    List<TextSegment> chunks = ChunkingPipeline.splitDocumentRecursively(policy);
    IO.println("Oluşturulan Toplam Parça Sayısı: " + chunks.size());
    for (int i = 0; i < chunks.size(); i++) {
        IO.println("--- Chunk #" + (i + 1) + " ---");
        IO.println(chunks.get(i).text().trim());
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
      Parça Boyutu İkilemi (Chunk Size Dilemma): Chunk çok küçük olursa (ör. 50 token), arama çok isabetli olur ama model soruyu yanıtlamak için gereken çevre bağlamı bulamaz. Chunk çok büyük olursa (ör. 2000 token), alakasız konular araya girer ve embedding kalitesi sulanır (Semantic Dilution). İdeal aralık çoğu metin için 300-600 tokendir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[The Chunk Size Dilemma: Chunks that are too small (50 tokens) achieve high retrieval precision but lack sufficient contextual breadth to answer complex questions. Chunks that are too large (2,000 tokens) suffer from semantic dilution, washing out specific facts in dense vector averages.]
    ]
  )
]

#takeaways_box((
    ("Overlap (Örtüşme), cümlelerin ortadan bölünmesini ve anlam kaybını önler.", "Overlap maintains narrative continuity across adjacent text segments."),
    ("Recursive Character Splitting, pratik üretim sistemlerinin vazgeçilmez standardıdır.", "Recursive splitting respects paragraphs and sentence boundaries before character limits."),
    ("İdeal parça boyutu 300-600 token civarındadır; amaca göre ayarlanmalıdır.", "Optimal production chunk sizes typically range between 300 and 600 tokens."),
))
