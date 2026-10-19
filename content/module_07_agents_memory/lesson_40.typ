#import "/template.typ": *

#show: doc => setup_book(title: "Ders 40: Çoklu Ajan Sistemleri (Multi-Agent Workflows: Supervisor, Worker & Debate)", doc)

#lesson_header(
  40,
  "Çoklu Ajan Sistemleri (Multi-Agent Workflows: Supervisor, Worker & Debate)",
  "Multi-Agent System Architectures: Supervisor-Worker Networks & Adversarial Debate",
  "AI Ajanları (AI Agents), Otonom Akışlar ve Bellek Mimarisi",
  "AI Agents, Autonomous Loops & Conversational Memory Systems"
)

#diagram_box[
```text
   [ KULLANICI İSTEĞİ ] ──▶ "Yeni bir mikroservis tasarla ve güvenlik testini yap."
                                      │
                                      ▼
                        ┌───────────────────────────┐
                        │   SUPERVISOR AGENT        │
                        │   (Yönetici & Yönlendirici│
                        └─────────────┬─────────────┘
                                      │
                     ┌────────────────┴────────────────┐
                     ▼                                 ▼
             [ CODER AGENT ]                   [ SECURITY AGENT ]
             Java 25 kodunu yazar             Koddaki açıkları arar
                     │                                 │
                     └────────────────┬────────────────┘
                                      │ (Adversarial Debate / Tartışma)
                                      ▼
             [ SUPERVISOR ]: "Güvenlik açığı kapatıldı, kod üretime hazır!" 
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir şirkette tek bir kişinin hem muhasebeye, hem yazılıma, hem de hukuka bakmasını beklerseniz o şirket batar. Her işin ayrı bir uzmanı vardır: Bir yazılımcı kod yazar, bir siber güvenlikçi kodu inceler ve eksikleri söyler, bir yönetici de ikisini koordine eder. Çoklu Ajan (Multi-Agent) mimarisi tam olarak bu ofistir! Tek bir generale tüm işi yüklemek yerine; her biri tek bir konuda uzmanlaşmış küçük yapay zeka ajanları (Coder, Reviewer, Tester) birbiriyle konuşur ve tartışarak mükemmel iş üretir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[In a successful software company, you don't hire one person to simultaneously write backend code, audit cryptographic security, and file tax compliance. You establish specialized roles: an Engineer authors code, a Security Auditor attacks it, and an Engineering Manager coordinates the deliverables. Multi-Agent Systems instantiate this exact organizational hierarchy: specialized agents collaborate, challenge each other via debate loops, and deliver hardened results!]
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
      Çoklu Ajan Topolojileri: 1) Supervisor Pattern: Merkezi bir yönetici ajan gelen görevi analiz eder, hangi alt ajanın (Worker) çalışacağına karar verir ve sonuçları birleştirir. 2) Adversarial Debate (Çift Model Tartışması): İki ajan birbirinin tezini çürütmeye çalışır (ör. Biri 'Bu mimari güvenli' derken diğeri 'XSS açığı var' der). Bu yöntem mülakatlarda halüsinasyonu %90 düşüren en popüler tekniktir. 3) State Sharing: Ajanlar arası durum (State) paylaşımı genelde Redis veya merkezi bir Event-Driven mesaj kuyruğu üzerinden yönetilir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Multi-Agent Topologies & Orchestration: 1) Supervisor Pattern: A centralized coordinator acts as a triage router, delegating sub-goals to specialized sub-agents and consolidating outputs. 2) Adversarial Debate Protocol: Two models critique each other's intermediate outputs in turn-based dialogue. Research proves that debate significantly reduces factual hallucination and exposes edge-case architectural vulnerabilities. 3) Shared Blackboard State: Inter-agent state is synchronized via thread-safe shared blackboards backed by Redis, PostgreSQL, or transactional memory.]
    ]
  )
]

#java25_box[
```java
// Java 25: Çoklu Ajan (Multi-Agent) Koordinatör Modeli
public class MultiAgentOrchestrator {
    public record AgentResponse(String role, String output) {}

    public static String runReviewPipeline(String designPrompt) {
        // 1. Coder Ajanı Tasarımı Yapar
        var coder = new AgentResponse("CODER_AGENT", "Tasarım: PostgreSQL + Redis önbelleği kullanıldı.");
        IO.println("[" + coder.role() + "]: " + coder.output());

        // 2. Güvenlik Ajanı Denetler (Reviewer)
        var security = new AgentResponse("SECURITY_AGENT", "İnceleme: Redis şifrelemesi ve SSL zorunlu tutulmalıdır!");
        IO.println("[" + security.role() + "]: " + security.output());

        // 3. Supervisor Birleştirir
        return "Nihai Onaylı Tasarım: PostgreSQL + SSL Korumalı Redis Önbelleği.";
    }
}

void main() {
    IO.println("=== Çoklu Ajan Koordinasyon Simülasyonu ===");
    String finalResult = MultiAgentOrchestrator.runReviewPipeline("E-ticaret sepet mimarisi");
    IO.println("Supervisor Kararı: " + finalResult);
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
      Maliyet Uyarısı (Token Multiplication): 3 ajanın birbiriyle 5 tur tartıştığı bir sistemde her bir mesaj tüm geçmişle birlikte katlanarak çoğalır. Tek bir kullanıcı sorgusu 50.000 token harcayabilir! Çoklu ajan sistemleri sadece yüksek değerli, kritik kararlar (finans, güvenlik denetimi) için kurulmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Token explosion warning: A 3-agent debate loop running 5 turns generates 15 compound LLM invocations with ballooning context windows. Single queries can consume 50,000+ tokens. Reserve multi-agent workflows strictly for high-stakes domains (legal audits, critical infrastructure).]
    ]
  )
]

#takeaways_box((
    ("Çoklu ajan sistemleri, karmaşık görevleri uzmanlaşmış alt rollere paylaştırır.", "Multi-agent systems partition broad objectives into specialized, domain-focused sub-roles."),
    ("Supervisor mimarisi, ajanlar arasındaki koordinasyonu ve görev dağıtımını yönetir.", "The Supervisor pattern provides deterministic routing and state consolidation across workers."),
    ("Karşıt tartışma (Adversarial Debate), halüsinasyonları ve güvenlik açıklarını yakalamada rakipsizdir.", "Adversarial debate between models radically suppresses hallucinations and catches flaws."),
))
