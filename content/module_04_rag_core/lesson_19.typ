#import "/template.typ": *

#show: doc => setup_book(title: "Ders 19: Naive RAG Mimarisi: Chunking, Embedding, Search ve Context Injection", doc)

#lesson_header(
  19,
  "Naive RAG Mimarisi: Chunking, Embedding, Search ve Context Injection",
  "Naive RAG Architecture: Ingestion, Embedding, ANN Retrieval & Context Injection",
  "Üretim Seviyesinde RAG: Temeller, Chunking & ETL",
  "Production RAG Core: Fundamentals, Chunking & Ingestion Pipelines"
)

#diagram_box[
```text
   [ KULLANICI SORUSU ] ──▶ "2024 şirket seyahat politikası nedir?"
                                      │
               ┌──────────────────────┴──────────────────────┐
               ▼ (Sorguyu Vektörleştir)                       ▼ (Doğrudan Modele)
       [ text-embedding-3 ]                     (BAĞLAMSIZ: Model halüsinasyon görür!)
               │
               ▼ (Vektör Araması: Top 3 Parça)
     ┌─────────────────────────────┐
     │      VEKTÖR VERİTABANI      │
     │  Doc #14: "Günlük otel..."  │
     │  Doc #82: "Uçak biletleri.."│
     └──────────────┬──────────────┘
                    │
                    ▼ (Context Injection: İlgili metinler prompt'a gömülür!)
   ┌────────────────────────────────────────────────────────────────────────┐
   │ PROMPT:                                                                │
   │ "Aşağıdaki şirket dokümanlarına dayanarak soruyu yanıtla:              │
   │  [BAĞLAM: Günlük otel limiti 150$'dır. Uçuşlar ekonomi olmalıdır.]     │
   │  SORU: 2024 şirket seyahat politikası nedir?"                          │
   └──────────────────────────────────┬─────────────────────────────────────┘
                                      │
                                      ▼ (OpenAI GPT-4o)
   [ YANIT ] ──▶ "Şirket politikasına göre otel limiti 150$'dır ve uçuşlar..." 
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir avukatın tüm kanun maddelerini ezberlemesini bekleyemezsiniz (Modelin hafızası sınırlıdır). Bunun yerine avukata açık kitap sınavı yaptırırsınız! Müvekkil bir soru sorduğunda, avukat önce kütüphaneden ilgili 2 sayfayı çeker (Retrieval), masasının üstüne koyar (Augmentation) ve o iki sayfaya bakarak kesin ve doğru cevabı yazar (Generation)! RAG tam olarak budur: Modele körü körüne güvenmek yerine, önüne kanıtları koyup 'Sadece bu kanıtlara göre konuş' demektir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[You don't expect a seasoned attorney to memorize all 50,000 pages of commercial tax code. You give them an open-book exam! When a client asks a question, the attorney runs to the law library, pulls the 2 most relevant pages (Retrieval), places them directly on the desk (Augmentation), and drafts a grounded, factual response (Generation). Retrieval-Augmented Generation (RAG) grounds probabilistic LLMs on authoritative private data, killing hallucinations!]
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
      Naive RAG'in 4 Aşaması ve Kronik Sorunları: 1) Ingestion (Yükleme): Dokümanlar parçalanır (Chunking) ve vektörleştirilir. 2) Retrieval (Getirme): Kullanıcı sorusu ile en yakın Cosine benzerliğine sahip \$K\$ parça çekilir. 3) Synthesis (Sentezleme): Parçalar prompt'un System/User alanına yapıştırılır. 4) Naive RAG Neden MAANG Seviyesinde Yetersizdir?: a) Yanlış parça getirme (Low Recall). b) Parça bağlamından koptuğu için eksik bilgi (Context Loss). c) Kelime eşleşmesi olmaması (Örn: 'KDV' sorulup dokümanda 'Vergi' yazması). Bu sorunlar İleri Düzey RAG (Modül 5) ile çözülür.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[The Four Phases and Failure Modes of Naive RAG: 1) Ingestion: Documents split into fixed chunks and projected into vector space. 2) Retrieval: User query embedded; ANN vector search returns top-\$K\$ candidates. 3) Augmentation: Retrieved chunks prepended into prompt context. 4) The Naive RAG Failure Modes: a) Semantic Disconnect: Vector proximity doesn't guarantee semantic sufficiency. b) Context Fragmentation: Chopping text mid-sentence obscures critical pronouns. c) Keyword Blindness: Pure dense retrieval misses exact alphanumeric IDs (e.g. error code 'ERR-4091').]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: Basit RAG Soru-Cevap Akışı
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.QuestionAnswerAdvisor;
import org.springframework.ai.vectorstore.VectorStore;

public class NaiveRagService {
    private final ChatClient chatClient;

    public NaiveRagService(ChatClient.Builder builder, VectorStore vectorStore) {
        this.chatClient = builder
            // QuestionAnswerAdvisor sorguyu alır, vectorStore'da arar ve prompt'a bağlamı otomatik gömer!
            .defaultAdvisors(new QuestionAnswerAdvisor(vectorStore))
            .build();
    }

    public String askCompanyPolicy(String userQuestion) {
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
      En Tehlikeli Halüsinasyon: RAG sisteminde aranan konuyla ilgili veritabanında HİÇBİR doküman yoksa ve prompt'ta 'Bilmiyorsan bilmiyorum de' kuralı konulmadıysa, model internetteki eski genel bilgileriyle uydurma yanıt verir! Prompt'a daima katı 'Bilgi bağlamda yoksa bilmiyorum de' talimatı eklenmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[The Grounding Fallacy: When the vector search returns zero relevant chunks, an unconstrained LLM defaults to parametric world knowledge, fabricating plausible lies. Always enforce negative constraints: 'If the provided context does not contain the answer, reply strictly with: I do not have sufficient information.']
    ]
  )
]

#takeaways_box((
    ("RAG, LLM'i özel ve güncel şirket verileriyle halüsinasyonsuz beslemenin altın standardıdır.", "RAG is the gold standard for grounding LLMs on private, dynamic enterprise data."),
    ("Naive RAG; Ingestion, Retrieval ve Generation olmak üzere 3 temel ayaktan oluşur.", "Naive RAG combines three stages: Ingestion, Semantic Retrieval, and Synthesis."),
    ("Prompt'ta negatif kısıtlama ('bilmiyorsan uydurma') olmadan RAG güvenli sayılamaz.", "RAG pipelines must enforce strict negative boundaries to prevent fallback hallucinations."),
))
