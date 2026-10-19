#import "/template.typ": *

#show: doc => setup_book(title: "Ders 6: Java 25, Spring AI & LangChain4j İlk Kurulum: OpenAI ile 'Hello AI World'", doc)

#lesson_header(
  6,
  "Java 25, Spring AI & LangChain4j İlk Kurulum: OpenAI ile 'Hello AI World'",
  "Java 25, Spring AI & LangChain4j Setup: 'Hello AI World' with OpenAI",
  "AI Engineer Rolü, LLM Anatomisi & MAANG Mülakat Çerçevesi",
  "The AI Engineer Role, LLM Anatomy & The MAANG Interview Framework"
)

#diagram_box[
```text
   ┌────────────────────────────────────────────────────────────────────────┐
   │                  MODERN JAVA 25 AI ARCHITECTURE STACK                  │
   └────────────────────────────────────────────────────────────────────────┘
          ┌─────────────────────────────────────────────────────────┐
          │                    JAVA 25 RUNTIME                      │
          │ • Project Loom (Virtual Threads: Million Concurrency)   │
          │ • Compact Main `void main()` & Modern Records           │
          └────────────────────────────┬────────────────────────────┘
                                       │
                ┌──────────────────────┴──────────────────────┐
                ▼                                             ▼
       [ SPRING AI 1.0+ ]                            [ LANGCHAIN4J 1.0+ ]
     • ChatClient Fluent API                       • AiServices Declarative
     • VectorStore & ETL Pipelines                 • In-Memory / pgvector Store
     • @Tool Function Calling                      • Moderation & Guardrails
                │                                             │
                └──────────────────────┬──────────────────────┘
                                       ▼
                       [ OPENAI API GATEWAY (GPT-4o) ]
                       • HTTPS REST / SSE Streaming Endpoints
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Java eskiden 'ağır, hantal ve yapay zeka sadece Python'da yapılır' diye bilinirdi. Artık o devir bitti! Java 25 ile gelen sanal iş parçacıkları (Virtual Threads) sayesinde tek bir sunucuda aynı anda 100.000 yapay zeka sohbetini sıfır bekleme maliyetiyle yönetebilirsiniz. Spring AI ve LangChain4j kütüphaneleri, karmaşık HTTP isteklerini tek satırlık zarif bir metoda indirger. Artık Python karmaşasıyla uğraşmadan, kurumsal güvenliği ve performansı en yüksek Java uygulamalarını doğrudan OpenAI modellerine bağlayabiliyoruz!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[The outdated dogma that 'AI can only be built with Python' is completely obsolete. With Java 25's Project Loom (Virtual Threads), a single JVM can effortlessly sustain 100,000 concurrent streaming AI dialogues with near-zero memory footprint. Spring AI and LangChain4j wrap low-level HTTP/SSE plumbing into elegant fluent interfaces. Enterprise software engineers can now build mission-critical, strongly-typed AI applications directly backed by OpenAI foundation models!]
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
      Spring AI ve LangChain4j Karşılaştırması: 1) Spring AI: Spring Boot ekosistemiyle derin entegrasyon sunar. `ChatClient.builder()` ile fluent bir zincir kurar, Spring Cloud, Micrometer ve Security ile yerel çalışır. 2) LangChain4j: Framework bağımsızdır (Quarkus, Helidon veya düz Java ile de çalışır). `\@AiService` deklaratif arayüzleri ve zengin RAG bileşenleriyle öne çıkar. 3) Java 25 Virtual Threads Entegrasyonu: Her iki kütüphane de I/O-bound olan LLM çağrılarında işletim sistemi thread'lerini bloke etmez; milyonlarca istek eşzamanlı işletilebilir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Spring AI vs LangChain4j Architectural Synergy: 1) Spring AI: Seamlessly merges with Spring Boot conventions. The `ChatClient` fluent builder handles Advisors, dynamic prompts, and observability via Micrometer out of the box. 2) LangChain4j: Standalone and framework-agnostic. Famous for high-level `\@AiService` proxy annotations and modular RAG tooling. 3) Concurrency Profile: Because LLM calls are overwhelmingly I/O-bound (waiting 500ms-3000ms for network packets), Java 25 Virtual Threads make JVM-based AI gateways exponentially more scalable than standard Python asyncio workers.]
    ]
  )
]

#java25_box[
```java
// Java 25: LangChain4j ile OpenAI GPT-4o İlk Bağlantı
import dev.langchain4j.model.openai.OpenAiChatModel;

void main() {
    String apiKey = System.getenv().getOrDefault("OPENAI_API_KEY", "demo-key");
    
    // OpenAI Chat Modelini Başlatma
    OpenAiChatModel model = OpenAiChatModel.builder()
        .apiKey(apiKey)
        .modelName("gpt-4o-mini")
        .temperature(0.3)
        .build();

    IO.println("=== Spring AI & LangChain4j Ready! ===");
    IO.println("Model Başlatıldı: gpt-4o-mini");
    IO.println("Java 25 Sanal İş Parçacıkları (Loom) ile Yüksek Eşzamanlılık Aktif!");
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
      Güvenlik İkazı: API anahtarlarınızı (OPENAI_API_KEY) ASLA kodun içine hardcoded olarak yazmayın veya Git reposuna pushlamayın! MAANG mülakatlarında ilk bakılan şey ortam değişkenleri (Environment Variables) ve Secret Manager entegrasyonudur.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Security hygiene: Never commit plaintext API keys into source control. Always fetch credentials via environment variables (`System.getenv()`) or cloud secrets vaults (AWS Secrets Manager, HashiCorp Vault).]
    ]
  )
]

#takeaways_box((
    ("Java 25 Virtual Threads, I/O-bound LLM çağrıları için dünyanın en ölçeklenebilir altyapısını sunar.", "Java 25 Virtual Threads provide the ideal non-blocking runtime for network-heavy LLM calls."),
    ("Spring AI kurumsal Spring Boot projeleri için, LangChain4j ise deklaratif AI servisleri için idealdir.", "Spring AI excels in Spring Boot enterprise shops; LangChain4j shines with declarative abstractions."),
    ("API anahtarları her zaman gizli tutulmalı ve ortam değişkenlerinden okunmalıdır.", "API credentials must always be externalized and managed securely."),
))
