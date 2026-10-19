#import "/template.typ": *

#show: doc => setup_book(title: "Ders 41: LangChain4j ile Durumsal (Stateful) Ajan Tasarımı", doc)

#lesson_header(
  41,
  "LangChain4j ile Durumsal (Stateful) Ajan Tasarımı",
  "Building Stateful Agents with LangChain4j: State Persistence & Resumption",
  "AI Ajanları (AI Agents), Otonom Akışlar ve Bellek Mimarisi",
  "AI Agents, Autonomous Loops & Conversational Memory Systems"
)

#diagram_box[
```text
   [ KULLANICI ] ──▶ "Bana krediyi onayla." (Mesaj #1)
         │
         ▼
   ┌────────────────────────────────────────────────────────┐
   │            LANGCHAIN4J STATEFUL AGENT RUNTIME          │
   │                                                        │
   │  1. Durum Yükle (Redis / DB): user_id = 9481           │
   │  2. Mevcut Adım: "Kredi Skoru Doğrulandı, İmzalandı"   │
   │  3. Sonraki Adım: "Para Transferi Yap"                 │
   │  4. Durumu Güncelle ve Kaydet                          │
   └────────────────────────┬───────────────────────────────┘
                            │
                            ▼
   [ YANIT ] ──▶ "Krediniz onaylandı, transfer başlatıldı." (Mesaj #2)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Akıllı bir veznedarın önüne her gittiğinizde size 'Sen kimdin? Ne istiyordun?' diye sormadığını düşünün. Masasında sizin dosyanız açıktır; 'En son kimlik fotokopinizi almıştık, şimdi imzanızı atın' der (Stateful / Durumsal). LangChain4j'in durumsal ajanları böyledir: Kullanıcı tarayıcıyı kapatsa, aradan 3 gün geçse bile sistem kullanıcının nerede kaldığını hatırlar. Ajan hafızasını kaybetmez!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Imagine a bank teller who suffers complete amnesia every 30 seconds, forcing you to explain your loan application from scratch every time you speak. A stateful teller keeps your physical case file open on the desk: 'We already verified your tax returns yesterday; today we simply need your signature.' LangChain4j's stateful agents maintain persistent lifecycle states across sessions and machine restarts: an agent pauses, saves state to Redis, and resumes seamlessly days later!]
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
      Stateful Ajan Mühendisliği: 1) State Entity: Ajanın anlık değişkenlerini, tamamlanan adımlarını ve ara çıktılarını tutan Java Record modelidir. 2) Checkpointing: Her tool çağrısından sonra ajan durumu veritabanına (PostgreSQL / Redis) snapshot olarak yazılır. 3) Crash Recovery (Çökme Kurtarma): Sunucu o anda çökse veya pod yeniden başlasa bile, yeni pod son checkpoint'ten durumu yükler ve ajanı sıfırdan başlatmadan kaldığı adımdan devam ettirir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Stateful Agent Architecture & Checkpointing: 1) State Machine Semantics: Models agent execution as an explicit Finite State Machine (FSM) where state transitions are triggered by tool outputs or human approvals. 2) Durable Checkpointing: After every state change, an immutable state snapshot is persisted to an ACID store (PostgreSQL or Redis JSON). 3) Crash Fault-Tolerance: If a container restarts or encounters an Out-of-Memory (OOM) error mid-task, the new pod hydrates state from the latest checkpoint, resuming execution without duplicate side-effects.]
    ]
  )
]

#java25_box[
```java
// Java 25 & LangChain4j: Durumsal Ajan Durum (State) Modeli
import java.time.Instant;
import java.util.Map;

public class AgentStateSnapshot {
    public record AgentState(
        String conversationId,
        String currentStage, // INIT, COLLECTING_INFO, AWAITING_APPROVAL, COMPLETED
        Map<String, Object> contextVariables,
        Instant lastUpdated
    ) {}

    public static AgentState advanceStage(AgentState previous, String newStage) {
        return new AgentState(
            previous.conversationId(),
            newStage,
            previous.contextVariables(),
            Instant.now()
        );
    }
}

void main() {
    var state = new AgentStateSnapshot.AgentState("conv_101", "INIT", Map.of("userId", "usr_99"), Instant.now());
    IO.println("Ajan Başlangıç Durumu: " + state.currentStage());

    var updated = AgentStateSnapshot.advanceStage(state, "AWAITING_APPROVAL");
    IO.println("Ajan Yeni Durumu: " + updated.currentStage() + " | Güncellenme: " + updated.lastUpdated());
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
      Durum Şişmesi (State Bloat): Ajanın her mesajındaki tüm verileri sonsuza kadar `contextVariables` içinde saklamak Redis'i şişirir. Görev tamamlandığında (COMPLETED) geçici durum değişkenleri temizlenmeli (TTL ile temizlik), sadece nihai özet arşivlenmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[State bloat hazard: Accumulating megabytes of unpruned intermediate tool outputs inside state objects exhausts Redis memory. Implement explicit state lifecycle management: set Redis TTLs and prune transient execution payloads upon task completion.]
    ]
  )
]

#takeaways_box((
    ("Durumsal (Stateful) ajanlar, uzun süren iş akışlarında oturumlar arası hafıza sağlar.", "Stateful agents preserve workflow context across multi-session, long-running processes."),
    ("Checkpointing, sunucu çökmelerinde ajanın kaldığı yerden devam etmesini garanti eder.", "Checkpointing provides fault tolerance, enabling seamless resumption after server restarts."),
    ("Tamamlanan durumlar bellek şişmesini önlemek için temizlenmeli veya arşivlenmelidir.", "Completed agent states must be pruned or archived to maintain lean memory profiles."),
))
