#import "/template.typ": *

#show: doc => setup_book(title: "Ders 36: Model Context Protocol (MCP) ve Dış Servis Bağdaştırıcıları", doc)

#lesson_header(
  36,
  "Model Context Protocol (MCP) ve Dış Servis Bağdaştırıcıları",
  "Model Context Protocol (MCP): The Universal Standard for LLM Tool & Context Connectivity",
  "Function Calling, Tool Use ve API Entegrasyonu",
  "Function Calling, Tool Integration & Agent Tooling Protocols"
)

#diagram_box[
```text
   ┌────────────────────────────────────────────────────────────────────────┐
   │                   MODEL CONTEXT PROTOCOL (MCP) ARCHITECTURE            │
   └────────────────────────────────────────────────────────────────────────┘
          [ MCP HOST (LLM Client: Spring AI / Claude Desktop) ]
                                    │
                                    │ (JSON-RPC 2.0 over Stdio / SSE)
                                    ▼
       ┌────────────────────────────────────────────────────────┐
       │                   MCP SERVER FLEET                     │
       │                                                        │
       │  ┌──────────────────┐ ┌──────────────────┐ ┌────────┐  │
       │  │ PostgreSQL Server│ │ GitHub MCP Server│ │Slack MCP│ │
       │  └──────────────────┘ └──────────────────┘ └────────┘  │
       └────────────────────────────────────────────────────────┘
                                    │
                                    ▼
       [ DIŞ SERVİSLER: Canlı DB, Repolar, Mesajlaşma Kanalları ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Eski telefonları hatırlayın: Her markanın (Nokia, Samsung, Sony) kendine özel farklı şarj kablosu vardı ve ev kablo çöplüğüne dönerdi. Sonra tüm dünya anlaştı ve tek bir standart çıkardı: USB-C! Artık her şey USB-C ile bağlanıyor. Anthropic tarafından açık kaynak olarak başlatılan Model Context Protocol (MCP) de yapay zekanın USB-C'sidir! Her veritabanı veya servis için sıfırdan özel kod yazmak yerine, herkes standart bir MCP sunucusu yazar. Spring AI veya başka bir LLM tek bir protokolle Postgres'e, GitHub'a veya Slack'e tak-çalıştır bağlanır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Remember the 2000s when every mobile phone brand (Nokia, Motorola, Sony) required a proprietary charging cable? It was an incompatible mess until the world converged on USB-C. Model Context Protocol (MCP), open-sourced by Anthropic, is the universal USB-C standard for foundation models! Instead of writing custom integration glue code for Postgres, GitHub, and Jira across every LLM application, services expose standard MCP endpoints. Any compliant client (Spring AI, LangChain4j) connects via plug-and-play!]
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
      MCP Standart Mimarisi: 1) JSON-RPC 2.0 Protokolü: İletişim standart JSON-RPC üzerinden `stdio` (yerel süreçler) veya `SSE` (Server-Sent Events - uzak sunucular) ile yapılır. 2) Üç Temel İlke (Primitives): a) Prompts (Kullanıcıya sunulan hazır şablonlar), b) Resources (Salt-okunur veri kaynakları, dosyalar, loglar), c) Tools (Çalıştırılabilir fonksiyonlar). 3) Güvenlik: MCP sunucusu izole bir süreç (Sandbox) olarak çalışır; yetkilendirme host istemci tarafından kontrol edilir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Model Context Protocol (MCP) Internals: 1) Transport Layer: Standardized over JSON-RPC 2.0 via Standard Input/Output (`stdio`) for local binaries or Server-Sent Events (`SSE`) for distributed network microservices. 2) Core Primitives: a) Prompts: Pre-engineered user-facing workflows. b) Resources: Structured read-only context (files, database snapshots, logs). c) Tools: Executable functions with explicit parameter schemas. 3) Enterprise Decoupling: Tool maintenance shifts to service owners: the Database team maintains the Postgres MCP server; AI engineers simply point their clients to the MCP socket.]
    ]
  )
]

#java25_box[
```java
// Java 25: Model Context Protocol (MCP) İstemci İletişim Modeli
public record McpToolDefinition(String name, String description, String inputSchemaJson) {}
public record McpJsonRpcRequest(String jsonrpc, String method, Map<String, Object> params, int id) {}

void main() {
    IO.println("=== Model Context Protocol (MCP) Standardı ===");
    var postgresTool = new McpToolDefinition(
        "queryCustomerDb",
        "PostgreSQL MCP sunucusu üzerinden müşteri sorgular.",
        "{"type": "object", "properties": {"id": {"type": "integer"}}}"
    );
    
    IO.println("MCP Tool Adı: " + postgresTool.name());
    IO.println("Taşıma Protokolü: JSON-RPC 2.0 over Stdio / SSE");
    IO.println("Durum: Tak-Çalıştır Kurumsal Servis Bağlantısı Aktif!");
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
      Gelecek Trendi: MAANG mülakatlarında 'Şirket içindeki 50 farklı mikroservisi LLM'e nasıl bağlarsınız?' sorusuna 'Her biri için ayrı ayrı Java metodu yazıp koduma eklerim' derseniz ölçekleme puanınız düşer. 'Model Context Protocol (MCP) standardı kurarak servislerin kendi MCP sunucularını sunmasını sağlarım' demek Staff+ vizyonudur.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Architectural trend: Answering how you integrate 50 internal microservices by writing 50 custom hardcoded tool wrappers demonstrates junior thinking. Recommending a federated Model Context Protocol (MCP) gateway where domain teams manage their own MCP servers represents Staff+ systems leadership.]
    ]
  )
]

#takeaways_box((
    ("MCP, yapay zeka modelleri ile veri kaynakları arasındaki evrensel açık protokoldür.", "MCP serves as the universal open protocol connecting LLMs with external data systems."),
    ("Prompts, Resources ve Tools olmak üzere 3 temel standart yapı taşından oluşur.", "MCP formalizes connectivity into three primitives: Prompts, Resources, and Tools."),
    ("MCP sayesinde araçlar (Tools) uygulama kodundan bağımsız harici servisler olarak ölçeklenir.", "MCP decouples tool maintenance from application runtimes, enabling federated tool ecosystems."),
))
