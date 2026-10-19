#import "/template.typ": *

#show: doc => setup_book(title: "Ders 23: Spring AI ile Uçtan Uca RAG Pipeline (Reader -> Transformer -> VectorStore)", doc)

#lesson_header(
  23,
  "Spring AI ile Uçtan Uca RAG Pipeline (Reader -> Transformer -> VectorStore)",
  "End-to-End Spring AI RAG Pipeline: Ingestion, Transformation & Retrieval",
  "Üretim Seviyesinde RAG: Temeller, Chunking & ETL",
  "Production RAG Core: Fundamentals, Chunking & Ingestion Pipelines"
)

#diagram_box[
```text
   ┌────────────────────────────────────────────────────────────────────────┐
   │                   SPRING AI END-TO-END RAG ARCHITECTURE                │
   └────────────────────────────────────────────────────────────────────────┘
     [ DOKÜMAN KAYNAĞI ] ──▶ PDF, Markdown, JSON Dosyaları
                                      │
                                      ▼
     [ ETL INGESTION ]   ──▶ PagePdfDocumentReader
                             ──▶ TokenTextSplitter(500, 50)
                             ──▶ KeywordMetadataEnricher
                             ──▶ pgvectorStore.write()
                                      │
     ═════════════════════════════════╪══════════════════════════════════════
                                      │ (Kullanıcı Sorgu Anı)
                                      ▼
     [ QUERY PIPELINE ]  ──▶ chatClient.prompt()
                             ──▶ QuestionAnswerAdvisor(vectorStore)
                             ──▶ OpenAiChatModel (GPT-4o)
                             ──▶ Doğrulanmış, Güvenilir Yanıt!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir fabrikanın üretim bandını hayal edin: Bandın başında içeri ham demir girer (PDF dokümanları), pres makineleri demiri parçalara böler (TokenTextSplitter), üzerine kalite damgası basılır (Metadata), ardından depodaki doğru raflara yerleştirilir (VectorStore). Müşteri bir parça sipariş ettiğinde ise sistem depodan en uygun parçayı şipşak çeker ve montajlayıp müşteriye teslim eder (ChatClient + Advisor)! Spring AI işte bu koca fabrikayı sadece birkaç Spring Bean'i ile sıfırdan kurmanızı sağlar!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Picture a high-efficiency manufacturing plant: raw steel enters the conveyor (PDFs), laser cutters slice it into uniform blocks (TokenTextSplitter), robotic arms stamp serial numbers and metadata, and automated cranes shelve them into vertical storage racks (VectorStore). When a custom order arrives, the system grabs matching parts and assemblies the finished product instantly (ChatClient + QuestionAnswerAdvisor). Spring AI encapsulates this entire factory in a few elegant Spring Beans!]
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
      Spring AI RAG Pipeline Mimarisi: 1) Ayrık Yaşam Döngüsü: Ingestion (Yükleme) pipeline'ı ile Query (Sorgulama) pipeline'ı birbirinden bağımsız çalışmalıdır. Ingestion arka plan batch job veya event-driven (Kafka/S3 Event) olarak çalışır. 2) `QuestionAnswerAdvisor`: Gelen sorguyu alır, embedding üretir, VectorStore'da benzerlik araması yapar, gelen dokümanları sistem prompt şablonundaki `{question_answer_context}` alanına yerleştirir. 3) Context Window Koruması: Advisor `order` sıralamasıyla Token sayım ve güvenlik filtrelerinin arkasına yerleştirilebilir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Decoupled RAG Pipeline Architecture: 1) Temporal Decoupling: Ingestion (ETL) and Query servicing must never share execution lifecycles. Ingestion runs asynchronously via message queues (Kafka, S3 ObjectCreated events), while queries execute on low-latency HTTP paths. 2) `QuestionAnswerAdvisor` Mechanics: Intercepts user prompts, orchestrates similarity search against the vector store, formats retrieved segments into a markdown context block, and injects it into `{question_answer_context}`. 3) Advisor Ordering: Advisors must be prioritized to execute authorization before vector queries.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: Üretim Seviyesinde Tam RAG Servis Mimarisi
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.QuestionAnswerAdvisor;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;

@Service
public class EnterpriseKnowledgeRagService {
    private final ChatClient chatClient;

    public EnterpriseKnowledgeRagService(ChatClient.Builder builder, VectorStore vectorStore) {
        var qaAdvisor = new QuestionAnswerAdvisor(
            vectorStore,
            SearchRequest.builder().topK(4).similarityThreshold(0.72).build(),
            "Aşağıdaki şirket bağlamını kullanarak soruyu yanıtla. Bilgi yoksa 'Bilmiyorum' de:\n{question_answer_context}"
        );

        this.chatClient = builder
            .defaultSystem("Sen kurumsal bilgi yönetim asistanısın.")
            .defaultAdvisors(qaAdvisor)
            .build();
    }

    public String queryKnowledge(String userQuestion) {
        return chatClient.prompt()
            .user(userQuestion)
            .call()
            .content();
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
      Mimari Darboğaz: Kullanıcı her soru sorduğunda dokümanı tekrar tekrar parse edip diske yazmaya çalışmayın! Ingestion pipeline'ı sadece doküman değiştiğinde veya yeni dosya yüklendiğinde bir kez çalışmalı; sorgu anında sadece hazır vektörler okunmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Architectural antipattern: Re-indexing documents on the fly during interactive query handling. Ingestion must remain strictly decoupled, executing asynchronously on document update triggers.]
    ]
  )
]

#takeaways_box((
    ("Ingestion (Yükleme) ve Query (Sorgulama) pipeline'ları mutlaka zamansal olarak ayrışmalıdır.", "Ingestion and query servicing must be decoupled into independent operational paths."),
    ("QuestionAnswerAdvisor, RAG arama ve bağlam enjeksiyonunu otomatikleştirir.", "QuestionAnswerAdvisor abstracts retrieval, threshold filtering, and context hydration."),
    ("Özel QA şablonu ile 'bilgi yoksa uydurma' kuralı Advisor seviyesinde garanti edilir.", "Custom QA templates enforce negative hallucination boundaries at the advisor layer."),
))
