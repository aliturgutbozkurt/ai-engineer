#import "/template.typ": *

#show: doc => setup_book(title: "Ders 7: Spring AI Mimarisi: ChatModel, ChatClient ve Fluent Zincir Yapısı", doc)

#lesson_header(
  7,
  "Spring AI Mimarisi: ChatModel, ChatClient ve Fluent Zincir Yapısı",
  "Spring AI Architecture: ChatModel, ChatClient & The Fluent Pipeline",
  "Spring AI & LangChain4j Temel Yapı Taşları ve Chat Modelleri",
  "Core Foundations: Spring AI, LangChain4j & Modern Chat Models"
)

#diagram_box[
```text
   [ KULLANICI İSTEĞİ ]
            │
            ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │                    SPRING AI ChatClient FLUENT BUILDER                 │
   │                                                                        │
   │  chatClient.prompt()                                                   │
   │      .system("Sen kurumsal bir e-ticaret danışmanısın.")               │
   │      .user("Siparişim nerede?")                                        │
   │      .advisors(new MessageChatMemoryAdvisor(memory)) ──▶ [ BELLEK ]    │
   │      .call()                                                           │
   │      .entity(OrderStatusResponse.class);             ──▶ [ RECORD DTO ]│
   └───────────────────────────────────┬────────────────────────────────────┘
                                       │
                                       ▼ (OpenAiChatModel)
                            [ OPENAI API (GPT-4o) ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir kahve dükkanına gittiğinizde kahvenizi adım adım özelleştirirsiniz: 'Sütlü olsun -> Vanilya şurubu eklensin -> Buzlu olsun -> Karton bardakta verilsin.' Spring AI'ın `ChatClient` yapısı da tam bir kahve siparişi gibidir! 'Sistem rolü şu olsun' dersiniz, 'Kullanıcı sorusu bu olsun' dersiniz, 'Geçmiş konuşmaları hatırla' dersiniz ve en son 'Bana sonucu doğrudan Java sınıfı olarak ver' dersiniz! Kodunuz ne karmaşık HTTP istekleriyle boğulur ne de JSON ayrıştırmakla uğraşır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[When ordering a custom coffee, you chain instructions fluently: 'Start with an espresso -> Add oat milk -> Inject vanilla syrup -> Pour over ice.' Spring AI's `ChatClient` provides the exact same fluent chaining syntax for LLM pipelines: define system context, bind dynamic variables, hook up conversation memory advisors, and parse the response directly into a strongly-typed Java record in a single fluid expression!]
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
      Spring AI Mimari Bileşenleri: 1) `ChatModel`: Düşük seviyeli arayüzdür. `Prompt` nesnesi alır, `ChatResponse` döner. 2) `ChatClient`: Spring AI 1.0 ile gelen yüksek seviyeli fluent abstraction'dır. `ChatClient.builder(chatModel)` üzerinden inşa edilir. 3) Advisors (Danışmanlar): Request ve Response akışına araya girerek (AOP benzeri) Token sayımı, ChatMemory (konuşma geçmişi), RAG Question-Answer zenginleştirmesi ve Loglama yapar. 4) Entity Extraction: Yanıtı Jackson ObjectMapper üzerinden doğrudan Java Record'a deserialize eder.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Spring AI Architectural Primitives: 1) `ChatModel`: Low-level SPI accepting a `Prompt` and returning a `ChatResponse`. 2) `ChatClient`: The primary application-level fluent builder introduced in Spring AI 1.0+. 3) Advisors API: Interceptor chain pattern injecting conversational memory (`MessageChatMemoryAdvisor`), vector store RAG lookups (`QuestionAnswerAdvisor`), and latency telemetry around LLM invocations. 4) Strongly-Typed Mapping: Seamlessly handles reflection-based JSON schema injection and deserialization into immutable Java records.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: ChatClient Fluent Kullanım Örneği
import org.springframework.ai.chat.client.ChatClient;

public class SupportAssistantService {
    private final ChatClient chatClient;

    public record SupportTicket(String summary, String priority, String department) {}

    public SupportAssistantService(ChatClient.Builder chatClientBuilder) {
        this.chatClient = chatClientBuilder
            .defaultSystem("Sen kurumsal IT destek sistemisin. Gelen sorunları sınıflandır.")
            .build();
    }

    public SupportTicket classifyTicket(String userMessage) {
        return chatClient.prompt()
            .user(userMessage)
            .call()
            .entity(SupportTicket.class); // Otomatik JSON şeması üretir ve Record'a eşler!
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
      Hata Uyarısı: Her istek için yeni bir `ChatClient` nesnesi oluşturmayın! `ChatClient` thread-safe'tir ve Singleton Spring Bean olarak yönetilmelidir. Aksi halde connection pool ve bellek şişmesi yaşanır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Lifecycle trap: Never instantiate a new `ChatClient` per HTTP request. `ChatClient` is immutable and thread-safe; declare it once as a Spring `\@Bean` or `\@Service` dependency.]
    ]
  )
]

#takeaways_box((
    ("ChatClient, Spring AI'ın en modern ve okunabilir etkileşim arayüzüdür.", "ChatClient represents Spring AI's primary fluent, high-level interaction interface."),
    ("Advisors zinciri, sohbet geçmişi ve RAG gibi yan etkileri temiz bir şekilde izole eder.", "Advisors provide a clean interceptor mechanism for memory, telemetry, and RAG augmentation."),
    (".entity(Class) çağrısı deterministik veri dönüşümü sağlar.", ".entity(Class) enforces structured type safety without manual JSON parsing."),
))
