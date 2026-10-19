#import "/template.typ": *

#show: doc => setup_book(title: "Ders 8: LangChain4j Mimarisi: OpenAiChatModel, AiServices ve Deklaratif Tasarım", doc)

#lesson_header(
  8,
  "LangChain4j Mimarisi: OpenAiChatModel, AiServices ve Deklaratif Tasarım",
  "LangChain4j Architecture: OpenAiChatModel, AiServices & Declarative Design",
  "Spring AI & LangChain4j Temel Yapı Taşları ve Chat Modelleri",
  "Core Foundations: Spring AI, LangChain4j & Modern Chat Models"
)

#diagram_box[
```text
   ┌────────────────────────────────────────────────────────────────────────┐
   │                    LANGCHAIN4J DECLARATIVE AI SERVICE                  │
   └────────────────────────────────────────────────────────────────────────┘
          @AiService Interface Tanımı
          ┌──────────────────────────────────────────────────────────────┐
          │ public interface FraudDetector {                             │
          │     @SystemMessage("Sen banka dolandırıcılık uzmanısın.")     │
          │     FraudEvaluation analyze(@UserMessage String txDetails);  │
          │ }                                                            │
          └──────────────────────────────┬───────────────────────────────┘
                                         │
                                         ▼ (Dynamic Java Proxy)
   ┌────────────────────────────────────────────────────────────────────────┐
   │ 1. Metod çağrılır -> 2. Şema & Prompt üretilir -> 3. OpenAI çağrılır  │
   │ 4. JSON yanıtı parse edilir -> 5. FraudEvaluation Record'u döner!       │
   └────────────────────────────────────────────────────────────────────────┘
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Spring Data JPA kullandıysanız bilirsiniz: Sadece bir `interface` yazarsınız (`UserRepository`), arkada SQL kodlarını Spring halleder. LangChain4j'in `AiServices` yapısı da tam olarak böyledir! Siz sadece bir Java arayüzü yazıp üstüne `\@SystemMessage` eklersiniz; LangChain4j sizin yerinize OpenAI'a bağlanır, doğru formatta prompt'u atar, gelen cevabı çözer ve elinize hazır bir Java nesnesi olarak teslim eder. Tek satır HTTP kodu yazmazsınız!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[If you've ever used Spring Data JPA or Retrofit, you know the magic: define an interface, and the framework auto-synthesizes the implementation. LangChain4j's `AiServices` brings this exact declarative paradigm to LLMs! You define a Java interface annotated with `\@SystemMessage` and `\@UserMessage`. LangChain4j builds a dynamic proxy that serializes prompts, calls OpenAI, enforces structured JSON output schemas, and deserializes responses into your domain records automatically!]
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
      LangChain4j Deklaratif Mekanizması: 1) Dynamic Proxy: `AiServices.builder(MyService.class)` çağrısı yapıldığında Java Dynamic Proxy ile metod çağrıları dinlenir. 2) `\@V` ve `\@UserMessage`: Metod argümanlarını prompt şablonuna bağlar. 3) Output Parsing: Metod dönüş tipi `String` dışında bir POJO/Record ise, LangChain4j OpenAI'a JSON şemasını gönderir (`response_format: json_object` veya `json_schema`). 4) TokenUsage: İstenirse `Result\<T>` sarmalayıcısı ile harcanan girdi/çıktı token sayıları doğrudan elde edilir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Mechanics of LangChain4j AiServices: 1) Reflection & Proxying: The `AiServices.builder()` dynamically generates runtime proxies implementing target interfaces. 2) Prompt Interpolation: Arguments annotated with `\@V` populate template placeholders seamlessly. 3) Structured Output Protocol: If the return type is a typed Record, LangChain4j automatically injects JSON Schema instructions into the payload or leverages OpenAI's native Structured Outputs API. 4) Token Telemetry: Wrapping return types in `Result\<T>` exposes exact input/output token counts and finish reasons.]
    ]
  )
]

#java25_box[
```java
// Java 25 & LangChain4j: Deklaratif AiService Tanımı ve Çalıştırılması
import dev.langchain4j.service.AiServices;
import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.UserMessage;
import dev.langchain4j.model.openai.OpenAiChatModel;

public class FraudDetectionModule {
    public record FraudEvaluation(boolean isSuspicious, int riskScore, String reason) {}

    public interface FraudService {
        @SystemMessage("Sen kıdemli bir ödeme güvenliği denetçisisin. Şüpheli işlemleri tespit et.")
        FraudEvaluation evaluateTransaction(@UserMessage String transactionDetails);
    }

    public static FraudService create(String apiKey) {
        var model = OpenAiChatModel.builder()
            .apiKey(apiKey)
            .modelName("gpt-4o-mini")
            .temperature(0.0)
            .build();

        return AiServices.create(FraudService.class, model);
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
      Dikkat: `AiServices` arayüzlerinde dönüş tipini karmaşık iç içe koleksiyonlar yaparsanız (ör. `Map\<String, List\<Object>>`), model JSON şemasını şaşırabilir. Daima açık ve net alanlara sahip güçlü tipli Java `record` sınıfları tercih edin.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Schema gotcha: Avoid loosely-typed return structures like `Map\<String, Object>` in AiServices interfaces. LLMs generate significantly more reliable JSON when bound to explicit, strongly-typed Java `record` declarations.]
    ]
  )
]

#takeaways_box((
    ("AiServices, karmaşık LLM kodlarını tek bir temiz Java arayüzüne dönüştürür.", "AiServices abstracts LLM plumbing behind clean, declarative Java interfaces."),
    ("Dinamik proxy yapısı, prompt oluşturma ve JSON ayrıştırmayı otomatikleştirir.", "Dynamic runtime proxies automate prompt hydration and JSON deserialization."),
    ("LangChain4j, framework bağımsız mimariler ve mikroservisler için idealdir.", "LangChain4j is lightweight and framework-agnostic, suitable for any JVM project."),
))
