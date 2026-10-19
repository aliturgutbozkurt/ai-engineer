#import "/template.typ": *

#show: doc => setup_book(title: "Ders 27: Sorgu Dönüşümü: Query Expansion, Multi-Query & HyDE (Hypothetical Document Embeddings)", doc)

#lesson_header(
  27,
  "Sorgu Dönüşümü: Query Expansion, Multi-Query & HyDE (Hypothetical Document Embeddings)",
  "Query Transformation: Query Expansion, Multi-Query & HyDE (Hypothetical Embeddings)",
  "İleri Düzey RAG (Advanced RAG) & Bilgi Getirme Optimizasyonu",
  "Advanced RAG & Information Retrieval Optimization"
)

#diagram_box[
```text
   [ KULLANICI SORUSU ] ──▶ "Şirkette remote çalışırken yemek parası nasıl ödenir?"
                                      │
               ┌──────────────────────┴──────────────────────┐
               ▼                                             ▼
       [ MULTI-QUERY EXPANSION ]                     [ HyDE (Hypothetical Embeddings) ]
       LLM 3 farklı arama sorgusu üretir:            LLM varsayımsal sahte bir yanıt yazar:
       1. "Uzaktan çalışma yemek kartı"              "Şirket remote çalışanlara her ay Ticket
       2. "Evden çalışma Sodexo hak edişi"            kartına 4000 TL bakiye yükler..."
       3. "Remote yemek desteği bordro"                      │
               │                                             ▼
               │ (3 sorgu paralel aranır)             Bu sahte cevabın vektörü aranır!
               │                                      (Soru-Cevap boşluğu kapanır!)
               └──────────────────────┬──────────────────────┘
                                      ▼
                        [ ÇOK DAHA YÜKSEK RECALL ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir doktorun odasına girip sadece 'Karnım ağrıyor' derseniz, doktor koca tıp kitabında nereye bakacağını şaşırabilir. Akıllı bir doktor soruyu kafasında genişletir: 'Apandisit mi, mide spazmı mı, zehirlenme mi?' (Multi-Query). Ya da daha da iyisi, doktor kafasında hayali bir hasta raporu canlandırır: 'Hasta dün deniz mahsulü yemişse gıda zehirlenmesidir' (HyDE) ve o hayali cevaba uyan tıbbi makaleleri arar! HyDE tam olarak budur: Sorunun değil, 'olması muhtemel hayali cevabın' vektörünü aratarak arama isabetini tavan yaptırır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[When a patient walks into a clinic and says 'My stomach hurts', searching a medical textbook for those exact 3 words is useless. An experienced physician expands the query into distinct clinical hypotheses: 'Appendicitis, acute gastritis, foodborne pathogen' (Multi-Query). Even better, the physician hallucinates a hypothetical clinical outcome: 'Patient consumed raw shellfish, exhibiting acute bacterial gastroenteritis' (HyDE) and searches the database using that hypothetical text! Hypothetical Document Embeddings (HyDE) bridges the semantic gap between questions and answers!]
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
      Sorgu Dönüşüm Stratejileri: 1) Multi-Query: LLM kullanıcının tek bir sorgusundan 3-5 farklı eşanlamlı sorgu üretir. Tüm sorgular paralel (Java 25 Virtual Threads ile) vektör deposunda taranır ve sonuçlar birleştirilir. 2) HyDE (Gao et al., 2022): 'Soru ile Cevap' vektör uzayında aynı yerde durmaz (Asimetrik Arama Problemi). HyDE önce LLM'e 'Bu sorunun cevabı sence nasıl görünürdü?' diye sahte bir paragraf yazdırır. Bu sahte paragrafın vektörü, gerçek dokümanların vektörüne sorunun kendisinden %40 daha yakındır! 3) Query Decomposition: Karmaşık soruları alt sorulara bölme.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Advanced Query Transformation Mechanics: 1) Multi-Query Generation: LLMs synthesize 3-5 paraphrased permutations to overcome lexical brittleness. Concurrent retrieval via Java 25 Virtual Threads ensures zero wall-clock penalty. 2) HyDE (Hypothetical Document Embeddings): Addresses the Asymmetric Retrieval Problem: questions and answers inhabit distinct topological clusters in vector space. HyDE prompts an LLM to generate an idealized hypothetical answer. Even if factually inaccurate, its vector manifold aligns closely with true candidate answers, boosting zero-shot recall. 3) Query Decomposition: Deconstructs multi-hop prompts into sub-queries.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: HyDE (Hypothetical Document Embedding) Servisi
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import java.util.List;

public class HydeRetrievalService {
    private final ChatClient chatClient;
    private final VectorStore vectorStore;

    public HydeRetrievalService(ChatClient.Builder builder, VectorStore vectorStore) {
        this.chatClient = builder.build();
        this.vectorStore = vectorStore;
    }

    public List<Document> searchWithHyde(String userQuestion) {
        // 1. LLM'e varsayımsal (hypothetical) bir cevap yazdır
        String hypotheticalAnswer = chatClient.prompt()
            .system("Verilen soru için teknik ve kurumsal bir dokümanda yer alabilecek olası cevabı yaz.")
            .user(userQuestion)
            .call()
            .content();

        // 2. Soruyu değil, varsayımsal cevabın embedding'ini arat!
        return vectorStore.similaritySearch(
            SearchRequest.builder()
                .query(hypotheticalAnswer)
                .topK(3)
                .similarityThreshold(0.70)
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
      Gecikme & Maliyet Dengesi: HyDE ekstra bir LLM çağrısı gerektirir (yaklaşık +400ms ve ek token maliyeti). Her basit soru için HyDE çalıştırmak israftır. Yalnızca kaba vektör aramasının skorunun \<0.60 kaldığı durumlarda Fallback olarak tetiklenmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Cost & latency trade-off: HyDE incurs an upfront LLM completion call (+400ms and inference tokens). Never execute HyDE unconditionally on trivial queries; trigger it conditionally only when initial ANN retrieval confidence scores fall below threshold.]
    ]
  )
]

#takeaways_box((
    ("Soru ile cevap vektör uzayında farklı yönlere bakabilir (Asimetrik arama).", "Questions and answers naturally occupy distinct vector clusters (Asymmetric Retrieval)."),
    ("HyDE, hayali bir cevap üreterek vektör aramasını cevabın diline yaklaştırır.", "HyDE bridges the question-answer divide by searching with hypothetical answer embeddings."),
    ("Multi-Query, farklı arama kelimelerini paralel tarayarak doküman kaçırma riskini bitirir.", "Multi-Query eliminates lexical brittleness by retrieving across diverse paraphrased queries."),
))
