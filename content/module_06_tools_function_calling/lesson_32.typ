#import "/template.typ": *

#show: doc => setup_book(title: "Ders 32: Spring AI @Tool ve FunctionCallback Tabanlı Fonksiyon Kaydı", doc)

#lesson_header(
  32,
  "Spring AI @Tool ve FunctionCallback Tabanlı Fonksiyon Kaydı",
  "Spring AI Tool Calling: Declarative @Tool Annotations & FunctionCallback",
  "Function Calling, Tool Use ve API Entegrasyonu",
  "Function Calling, Tool Integration & Agent Tooling Protocols"
)

#diagram_box[
```text
   ┌────────────────────────────────────────────────────────────────────────┐
   │                    SPRING AI TOOL REGISTRATION ENGINE                  │
   └────────────────────────────────────────────────────────────────────────┘
          @Component Sınıfı
          ┌──────────────────────────────────────────────────────────────┐
          │ @Tool(description = "Verilen sipariş numarasının kargo       │
          │                      durumunu sorgular.")                    │
          │ public OrderStatus trackOrder(String orderId) { ... }        │
          └──────────────────────────────┬───────────────────────────────┘
                                         │
                                         ▼ (Otomatik Reflection & JSON Schema)
   ┌────────────────────────────────────────────────────────────────────────┐
   │ chatClient.prompt()                                                    │
   │     .user("10492 nolu siparişim nerede?")                              │
   │     .tools(new OrderTrackingTools()) ──▶ OpenAI'a Şemayı Otomatik Sun│
   │     .call()                          ──▶ Otomatik Çağır ve Yanıt Ver! │
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
      Evinize gelen bir tamirciye tek tek 'Tornavidanın adı şudur, pense şöyle çalışır' diye anlatmazsınız; alet çantasını önüne koyarsınız, o ihtiyacı olanı çantadan çekip kullanır. Spring AI'ın `\@Tool` mekanizması tam olarak budur! Siz sadece normal bir Java metodu yazıp üstüne `\@Tool(description = "Kargo takip et")` yazarsınız. Spring AI bu metodu otomatik inceler, açıklamasını OpenAI'ın anlayacağı dile çevirir ve model bu aracı istediği an otomatik çalıştırır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[When a certified technician arrives at your home, you don't explain how a wrench operates; you lay out the toolbox, and they grab the exact socket needed. Spring AI's `\@Tool` system turns ordinary Java methods into discoverable AI instruments! Simply annotate a method with `\@Tool(description = "Tracks package delivery by tracking ID")`. Spring AI uses reflection to synthesize the OpenAPI JSON schema and executes the method automatically when the LLM requests it!]
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
      Spring AI Tool Mekanizması: 1) `\@Tool`: Metodun açıklamasını (`description`) taşır. LLM'in bu aracı ne zaman seçeceğini belirleyen EN KRİTİK unsur bu açıklamadır! 2) `\@ToolParam`: Parametre açıklamalarını ve `required` durumunu belirler. 3) Otomatik Döngü (Auto-Resolution): Spring AI `ChatClient` varsayılan olarak tool çağrısını algılar, Java metodunu çalıştırır ve sonucu modele gönderip nihai metni kullanıcıya teslim eder; tüm döngüyü tek adımda çözer.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Spring AI Tool Calling Mechanics: 1) `\@Tool` Annotation: Exposes method metadata to the LLM. The docstring `description` is the primary decision signal used by the model's router. 2) `\@ToolParam`: Specifies parameter-level constraints, descriptions, and optionality. 3) Recursive Auto-Execution: Spring AI's execution pipeline intercepts the `tool_calls` finish reason, invokes the registered Java method via reflection, injects the result back into the prompt history, and re-invokes OpenAI seamlessly until text completion.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: @Tool ile Kargo Takip Servisi
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Service;

@Service
public class OrderTrackingTools {
    public record OrderStatus(String orderId, String status, String carrier, String estimatedDelivery) {}

    @Tool(description = "Verilen sipariş numarasına göre kargo teslimat durumunu sorgular.")
    public OrderStatus getDeliveryStatus(
        @ToolParam(description = "8 haneli sipariş ID'si, örn: ORD-9481") String orderId
    ) {
        // Gerçek veritabanı veya kargo API çağrısı simülasyonu
        return new OrderStatus(orderId, "YOLDA", "Yurtiçi Kargo", "Yarın 14:00");
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
      Kritik Açıklama Tuzağı: `\@Tool` açıklamasını 'Sipariş fonksiyonu' gibi kısa ve belirsiz yazarsanız model bu aracı ne zaman çağıracağını anlayamaz ve kullanıcı sipariş sorduğunda aracı çağırmayıp halüsinasyon görür! Açıklama son derece detaylı ve örnekli yazılmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[The Ambiguous Tool Description Trap: If a tool's description is vague (e.g. 'Order helper'), the LLM's attention mechanism fails to trigger it, causing the model to hallucinate answers instead. Descriptions must explicitly state purpose, constraints, and valid invocation scenarios.]
    ]
  )
]

#takeaways_box((
    ("\@Tool açıklaması, modelin doğru aracı seçmesini sağlayan en önemli rehberdir.", "The `\@Tool` description string is the primary routing signal for the model."),
    ("Spring AI, Java metotlarını otomatik JSON Schema ve ToolManifest formatına çevirir.", "Spring AI reflects Java method signatures into compliant OpenAPI tool schemas."),
    ("Auto-Resolution özelliği sayesinde fonksiyon çalıştırma döngüsü tek satırda tamamlanır.", "Spring AI automates the execution-synthesis loop without manual plumbing."),
))
