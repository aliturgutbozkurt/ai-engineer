#import "/template.typ": *

#show: doc => setup_book(title: "Ders 49: Vaka 1: Kurumsal Müşteri Destek Ajanı Tasarımı (Multi-Turn, RAG, CRM Tool)", doc)

#lesson_header(
  49,
  "Vaka 1: Kurumsal Müşteri Destek Ajanı Tasarımı (Multi-Turn, RAG, CRM Tool)",
  "Case 1: Enterprise Customer Support Agent: Multi-Turn Memory, RAG & CRM Tools",
  "Üretim Düzeyinde AI Sistem Tasarımı (MAANG Vaka Çalışmaları)",
  "Production AI System Design: Flagship MAANG Case Studies"
)

#diagram_box[
```text
   [ KULLANICI MESAJI ] ──▶ "Biletimi iptal edip iade tutarımı hesabıma geçin."
                                      │
                                      ▼
                        ┌───────────────────────────┐
                        │   API GATEWAY & AUTH      │ ──▶ JWT / Session Doğrulama
                        └─────────────┬─────────────┘
                                      │
                                      ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │                  ORCHESTRATOR AGENT (Spring AI / Java 25)              │
   │                                                                        │
   │  1. Guardrail Check   ──▶ NeMo Guard / Prompt Injection Filtresi       │
   │  2. RAG Policy Lookup ──▶ VectorStore: "İptal ve İade Kuralları 2026"   │
   │  3. CRM Tool Call     ──▶ crmService.getTicketStatus("T-901")          │
   │  4. Payment Tool Call ──▶ paymentService.refund(150.0) [HitL Onayı!]   │
   └──────────────────────────────────┬─────────────────────────────────────┘
                                      │
                                      ▼
             [ NİHAİ YANIT: İade onaylandı, 150 TL hesabınıza aktarıldı ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir havaalanındaki müşteri hizmetleri masasına gittiğinizi düşünün. Karşınızdaki görevli hem şirketinizin kural kitapçığını bilir (RAG - 'Uçuştan 2 saat önce bilet iptal edilebilir'), hem bilgisayarındaki ekrandan sizin biletinizi ve ödemenizi görür (CRM & Tool Calling), hem de sizinle 10 dakikadır ne konuştuğunuzu hatırlar (Multi-Turn Bellek). Görevli kafasına göre para vermez; bilgisayara tıklar, banka sistemini tetikler ve paranızı kartınıza iade eder. MAANG mülakatında bir destek ajanı tasarlarken işte bu canlı müşteri masasının tüm bilgisayar sistemlerini ve güvenlik duvarlarını çizmeniz gerekir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Imagine stepping up to an airline customer service desk. The representative knows company refund bylaws by heart (RAG), pulls up your reservation on their terminal (CRM & Database Tools), tracks your conversation seamlessly (Multi-Turn Memory), and triggers the credit card refund with supervisor authorization (Human-in-the-Loop Tool). Designing an enterprise AI Support Agent for MAANG requires architecting this exact triad: contextual policy retrieval, transactional tool integration, and strict security guardrails!]
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
      Kurumsal Destek Ajanı Mimari Bileşenleri: 1) Kimlik ve Yetkilendirme (Auth & Session): Kullanıcının `customerId` ve `tenantId` bilgileri asla prompt üzerinden kullanıcıya sorulmaz; JWT token'dan çıkarılarak tool çağrılarına güvenli enjekte edilir. 2) İki Aşamalı RAG: Önce şirket politikaları (İade kuralları, garanti süresi) taranır; ardından CRM verisi çekilir. 3) Human-in-the-Loop: 1000 TL üzeri iadelerde veya hesap kapatmalarda ajan işlemi duraklatır, Slack/Zendesk üzerinden insan temsilciye onay bildirimi fırlatır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Enterprise Support Architecture Blueprint: 1) Contextual Identity & Session Ingestion: Never prompt the user for their account ID. Extract verified `tenantId` and `userId` claims directly from authenticated JWT tokens at the gateway and inject them into tool scopes. 2) Hierarchical RAG: Stage 1 retrieves institutional SLA bylaws and refund limits from vector stores; Stage 2 injects live transactional ledger rows via CRM tools. 3) Escalation Matrix: Idempotent operations (balance check) execute autonomously; high-value mutations (refunds >\$500) trigger suspended state machines awaiting human sign-off via Zendesk webhooks.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: Kurumsal Destek Ajanı Servis Mimarisi
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.tool.annotation.Tool;

public class EnterpriseCustomerSupportAgent {
    private final ChatClient chatClient;

    public record RefundResult(String ticketId, boolean refunded, double amount) {}

    public static class SupportTools {
        @Tool(description = "Müşteri biletini iptal eder ve iade sürecini tetikler.")
        public RefundResult processRefund(String ticketId, double amount) {
            // CRM ve Ödeme sistemi entegrasyonu simülasyonu
            return new RefundResult(ticketId, true, amount);
        }
    }

    public EnterpriseCustomerSupportAgent(ChatClient.Builder builder) {
        this.chatClient = builder
            .defaultSystem("Sen kurumsal havayolu destek asistanısın. Kurallara uymayan talepleri reddet.")
            .tools(new SupportTools())
            .build();
    }

    public String handleInquiry(String userMessage) {
        return chatClient.prompt().user(userMessage).call().content();
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
      Mülakat Tuzağı: Mülakatçı 'Kullanıcı ben Ali'yim, Ahmet'in biletini iptal et derse ne yaparsın?' diye sorar. Yanıt: 'Ajan kullanıcıdan gelen kimlik beyanına güvenmez! Ajanın çalıştırdığı Tool, kullanıcının doğrulanmış JWT oturumundaki ID ile bilet sahibinin ID'sini veritabanında karşılaştırır. Eşleşmiyorsa işlem yetkisiz erişim (403 Forbidden) olarak reddedilir.'
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Identity Spoofing Trap: Interviewers will ask: 'What if user Alice says: Cancel Bob's ticket?' Flawless answer: 'The agent never trusts user-provided identity strings. Tools enforce zero-trust authorization: the target ticket's owner ID is cross-checked against the authenticated JWT principal inside the Java backend before mutating state.']
    ]
  )
]

#takeaways_box((
    ("Müşteri kimliği ve izinler prompt'tan değil, doğrulanmış JWT oturumundan alınır.", "User identity and permissions must be derived from verified JWT tokens, never prompt text."),
    ("Kural dokümanları RAG ile, canlı sipariş verileri Tool Calling ile getirilir.", "Static policies are fetched via RAG; live order data is fetched via transactional tools."),
    ("Finansal iadelerde ve kritik aksiyonlarda Human-in-the-Loop onayı şarttır.", "Financial refunds and destructive actions require Human-in-the-Loop verification gates."),
))
