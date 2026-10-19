#import "/template.typ": *

#show: doc => setup_book(title: "Ders 54: Vaka 6: Gerçek Zamanlı Sesli AI Asistanı (OpenAI Realtime API, WebRTC & Ses)", doc)

#lesson_header(
  54,
  "Vaka 6: Gerçek Zamanlı Sesli AI Asistanı (OpenAI Realtime API, WebRTC & Ses)",
  "Case 6: Real-Time Voice AI: OpenAI Realtime API, WebRTC & Speech-to-Speech",
  "Üretim Düzeyinde AI Sistem Tasarımı (MAANG Vaka Çalışmaları)",
  "Production AI System Design: Flagship MAANG Case Studies"
)

#diagram_box[
```text
   [ KULLANICI MİKROFONU ] ──▶ Ham Ses Dalgaları (PCM Audio)
                                      │
                                      ▼ (WebRTC Peer Connection / Ultra Düşük Gecikme)
   ┌────────────────────────────────────────────────────────────────────────┐
   │                    OPENAI REALTIME API (GPT-4o Voice)                  │
   │                                                                        │
   │  • Eski Yöntem: Ses -> Whisper (STT) -> GPT-4 -> TTS -> Ses (1500ms)   │
   │  • YENİ YÖNTEM: Uçtan Uca Ses (Speech-to-Speech Native) (300ms!)        │
   │  • Kesintiye Uğrama (Barge-In): Kullanıcı konuşunca model susar!       │
   └──────────────────────────────────┬─────────────────────────────────────┘
                                      │
                                      ▼ (PCM Audio Stream)
   [ KULLANICI KULAKLIĞI ] ──▶ Doğal nefes alan, tonlamalı canlı ses!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Eski sesli asistanları (Siri veya eski çağrı merkezleri) düşünün: Siz konuşurdunuz, sistem 3 saniye sessiz kalır, önce söylediklerinizi yazıya döker (STT), sonra cevabı düşünür, sonra o cevabı bir robota okuturdu (TTS). Konuşma robotik ve kopuk olurdu. OpenAI Realtime API ise canlı bir insanla telefonda konuşmak gibidir! Arada hiçbir yazıya çevirme beklemesi yoktur; ses dalgaları doğrudan modelin beynine girer ve 300 milisaniyede doğal bir insan sesiyle anında cevap döner. Siz araya girip 'Dur bir dakika' dediğiniz anda model anında susar ve sizi dinler (Barge-In)!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Legacy voice assistants suffered from the clumsy 3-hop cascade: Speech-to-Text (Whisper) -> LLM Text Synthesis (GPT-4) -> Text-to-Speech (Polly). This introduced a 2,000ms pause, stripping away human emotional cadence. OpenAI's native Realtime API communicates via WebRTC Speech-to-Speech: raw audio enters the neural network and synthesized speech returns in under 300ms! Crucially, it supports native interruption (Barge-In): the instant the user speaks, the assistant immediately ceases transmission and listens!]
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
      Realtime Ses Mimarisi Mühendisliği: 1) WebRTC Protokolü: WebSocket'e kıyasla UDP tabanlı WebRTC MediaStream gecikmeyi 200-300ms seviyesine çeker (Gerçek zamanlı insan konuşma eşiği). 2) Speech-to-Speech (Uçtan Uca Ses): Model sadece metin değil, kullanıcının ses tonunu, heyecanını, nefes alışını ve fısıltısını anlar; aynı tonlamayla cevap verir. 3) Server VAD (Voice Activity Detection): Model kullanıcının ne zaman susup ne zaman konuşmaya başladığını otomatik algılar; kullanıcı araya girdiğinde (Barge-In) model ses üretimini anında keser (Audio buffer truncate). 4) Realtime Function Calling: Konuşma sırasında arka plandaki Java API'lerini ses gecikmesi yaşamadan tetikleyebilir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Speech-to-Speech Realtime Architecture: 1) WebRTC PeerConnections: Bypasses TCP head-of-line blocking by streaming raw 24kHz PCM audio frames over UDP channels, hitting sub-300ms end-to-end latency. 2) Native Auditory Attention: The model attends directly to acoustic spectrogram features, comprehending prosody, emotional inflection, sarcasm, and background interruptions. 3) Server-Side Voice Activity Detection (VAD): Distinguishes ambient noise from genuine speech. Triggers instant audio output truncation when a user interrupts (Barge-In). 4) In-Band Function Calling: Emits structured tool calls concurrently without terminating the WebRTC audio transport.]
    ]
  )
]

#java25_box[
```java
// Java 25: OpenAI Realtime WebRTC Oturum Başlatıcı Modeli
public record RealtimeSessionConfig(
    String model,
    String voice, // alloy, echo, shimmer
    double temperature,
    String turnDetectionMode // server_vad
) {
    public static RealtimeSessionConfig createDefault() {
        return new RealtimeSessionConfig("gpt-4o-realtime-preview", "alloy", 0.7, "server_vad");
    }
}

void main() {
    var config = RealtimeSessionConfig.createDefault();
    IO.println("=== OpenAI Realtime API WebRTC Yapılandırması ===");
    IO.println("Model: " + config.model());
    IO.println("Ses Karakteri: " + config.voice());
    IO.println("Konuşma Algılama (VAD): " + config.turnDetectionMode());
    IO.println("Gecikme Hedefi: <300ms (İnsan seviyesi akıcı konuşma)");
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
      Maliyet Uyarısı: OpenAI Realtime ses API'si metin API'sinden yaklaşık 10 kat daha pahalıdır (Dakikası yaklaşık 0.06 - 0.20 \$). Boşta açık kalan WebRTC oturumları faturayı şişirir. Kullanıcı 30 saniye konuşmadığında oturum otomatik olarak kapatılmalıdır (Idle Disconnect).
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Cost vulnerability: Realtime Speech-to-Speech streaming costs ~10x more than standard text tokens (~\$0.10-\$0.25 per minute). Abandoned WebRTC connections running on silent microphones burn budget continuously. Implement an aggressive 30-second idle disconnect timeout.]
    ]
  )
]

#takeaways_box((
    ("WebRTC ve Speech-to-Speech, sesli yapay zekayı 300ms gecikmeyle gerçek zamanlı yapar.", "WebRTC and Speech-to-Speech deliver human-grade conversational voice in sub-300ms."),
    ("Server VAD ve Barge-In, kullanıcının asistanın sözünü kesebilmesini (Doğal sohbet) sağlar.", "Server-side VAD and Barge-In enable natural human interruption dynamics."),
    ("Realtime API'de boşta kalan bağlantılar için mutlaka Idle Timeout mekanizması kurulmalıdır.", "Idle timeout policies are mandatory to avoid runaway billing on open audio streams."),
))
