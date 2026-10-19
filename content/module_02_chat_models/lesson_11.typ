#import "/template.typ": *

#show: doc => setup_book(title: "Ders 11: Gerçek Zamanlı Streaming (SSE, Flux, Reactor & WebSockets ile Token Akışı)", doc)

#lesson_header(
  11,
  "Gerçek Zamanlı Streaming (SSE, Flux, Reactor & WebSockets ile Token Akışı)",
  "Real-Time Streaming: Server-Sent Events (SSE), Project Reactor Flux & WebSocket Delivery",
  "Spring AI & LangChain4j Temel Yapı Taşları ve Chat Modelleri",
  "Core Foundations: Spring AI, LangChain4j & Modern Chat Models"
)

#diagram_box[
```text
   [ KULLANICI ] ──▶ "Bana mikroservis mimarisini anlat."
         │
         │ (HTTP POST - Streaming=true)
         ▼
   ┌────────────────────────────────────────────────────────┐
   │                SPRING AI / REACTIVE FLUX               │
   │                                                        │
   │  chatClient.prompt().user("...").stream().content()    │
   │      ──▶ Flux<String> (Kelimeler geldikçe akar)        │
   └────────────────────────┬───────────────────────────────┘
                            │
                            │ (Server-Sent Events: data: "Mikro")
                            │ (Server-Sent Events: data: "servisler")
                            │ (Server-Sent Events: data: "bağımsız")
                            ▼
   [ TARAYICI / UI ] ──▶ Ekrana kelime kelime daktilo gibi yazılır! (TTFT < 300ms)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir restorana gittiğinizde aşçının tüm 5 çeşidin pişmesini 45 dakika bekleyip hepsini birden soğuk getirmesini mi istersiniz, yoksa çorbanız hazır olunca hemen masanıza gelmesini mi? Streaming çorbadır! Bir LLM'in 500 kelimelik bir makaleyi tamamlaması 10 saniye sürebilir. Eğer 10 saniye boyunca kullanıcıya boş bir dönen yükleme tekerleği gösterirseniz kullanıcı sıkılıp sayfayı kapatır. Streaming ile ilk kelime 250 milisaniyede ekrana düşer; kullanıcı okumaya başlarken model arkadan kelimeleri akıtmaya devam eder!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[When ordering a 5-course dinner, you don't want the kitchen to hold back appetizers for 45 minutes until the dessert is baked. You want hot soup served immediately! Standard LLM inference takes 5-15 seconds to synthesize long paragraphs. Forcing users to stare at a frozen spinner ruins user retention. With Server-Sent Events (SSE) streaming, the Time-to-First-Token (TTFT) drops to ~250ms. The user begins reading immediately while subsequent tokens stream in real time!]
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
      Reaktif Streaming Mekanizması: 1) Server-Sent Events (SSE - `text/event-stream`): Tek yönlü, HTTP tabanlı hafif bir protokoldür. WebSockets'a göre firewall ve load balancer'lardan çok daha rahat geçer. 2) Spring WebFlux & Project Reactor (`Flux\<String>`): Gelen her token bir reaktif sinyaldir (`onNext`). Bellekte tamponlanmadan doğrudan istemciye fırlatılır. 3) TTFT vs Toplam Süre: Toplam yanıt süresi aynı kalsa bile TTFT'nin 300ms'ye inmesi kullanıcının algıladığı gecikmeyi (Perceived Latency) sıfıra indirir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Reactive Streaming Internals: 1) Protocol Choice: Server-Sent Events (`text/event-stream`) is preferred over WebSockets for text delivery due to native HTTP/2 multiplexing, automatic reconnects, and standard proxy compatibility. 2) Non-Blocking Backpressure: Spring AI's `.stream()` exposes a Reactive `Flux\<String>`. Tokens emitted over the chunked HTTP connection flow downstream without blocking carrier threads. 3) Perceived Latency Metrics: While total completion time remains constant, dropping TTFT below human reading speed (\<300ms) creates an instantaneous user experience.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: Controller Katmanında Reactive SSE Streaming
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

@RestController
public class StreamingChatController {
    private final ChatClient chatClient;

    public StreamingChatController(ChatClient.Builder builder) {
        this.chatClient = builder.build();
    }

    // Server-Sent Events (SSE) ile token bazlı gerçek zamanlı yayın
    @GetMapping(value = "/api/chat/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> streamChat(@RequestParam String prompt) {
        return chatClient.prompt()
            .user(prompt)
            .stream()
            .content(); // Her token geldikçe istemciye akar!
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
      Kritik Darboğaz: HTTP/1.1 kullanan eski proxy veya API Gateway'ler yanıtı istemciye göndermeden önce tamponlayabilir (Buffering). Streaming'in çalışması için Nginx/Envoy yapılandırmasında `proxy_buffering off;` yapılmalı veya HTTP/2 aktif edilmelidir!
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Infrastructure bottleneck: Reverse proxies (Nginx, Envoy, AWS ALB) often buffer responses by default, breaking real-time token delivery. You must explicitly set `proxy_buffering off;` and enable chunked transfer encoding.]
    ]
  )
]

#takeaways_box((
    ("Streaming, kullanıcı deneyimini (UX) ve algılanan hızı (TTFT) kurtaran en kritik tekniktir.", "Streaming is the single most vital pattern to optimize perceived latency and TTFT."),
    ("Server-Sent Events (SSE), metin akışı için WebSockets'tan çok daha hafif ve basittir.", "SSE provides a lighter, HTTP-native alternative to WebSockets for unidirectional token streams."),
    ("Ters proxy ve gateway'lerde response buffering kesinlikle kapatılmalıdır.", "Response buffering must be disabled on ingress proxies to prevent token batching."),
))
