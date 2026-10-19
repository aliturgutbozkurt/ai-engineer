#import "/template.typ": *

#show: doc => setup_book(title: "Ders 34: Çok Adımlı Tool Zinciri & Dinamik Veritabanı Sorgulama (SQL Agent)", doc)

#lesson_header(
  34,
  "Çok Adımlı Tool Zinciri & Dinamik Veritabanı Sorgulama (SQL Agent)",
  "Multi-Step Tool Chaining & Dynamic Database Agents (Text-to-SQL)",
  "Function Calling, Tool Use ve API Entegrasyonu",
  "Function Calling, Tool Integration & Agent Tooling Protocols"
)

#diagram_box[
```text
   [ KULLANICI ] ──▶ "En çok satış yapan ilk 3 müşteriyi ve toplam harcamalarını bul."
         │
         ▼ (ADIM 1: Şemayı Öğren)
   [ TOOL 1: listTables() ] ──▶ Model veritabanında 'customers' ve 'orders' olduğunu görür.
         │
         ▼ (ADIM 2: Tablo Yapısını Al)
   [ TOOL 2: getTableSchema("orders") ] ──▶ Model sütunları inceler: (customer_id, total_amount).
         │
         ▼ (ADIM 3: SQL Üret ve Çalıştır)
   [ TOOL 3: executeReadOnlySql("SELECT customer_id, SUM(total_amount)...") ]
         │
         ▼ (ADIM 4: Nihai Analiz)
   [ MODEL CEVABI ] ──▶ "En çok harcama yapan müşteri 45.000 TL ile Ahmet Bey'dir." 
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir kütüphanede araştırma yapan bir öğrenci tek bir hareketle ödevini bitiremez. Önce kütüphane kataloğuna bakar (Adım 1: Hangi kitaplar var?). Sonra doğru kitabın içindekiler tablosunu açar (Adım 2: Hangi sayfada?). Sonra o sayfayı okur ve not alır (Adım 3: Veriyi çek). En son ödevini teslim eder (Adım 4). Çok adımlı bir SQL Ajanı da böyledir: Kullanıcının sorusunu görür, önce veritabanındaki tabloları inceler, doğru SQL sorgusunu yazar, çalıştırır ve cevabı size şık bir tablo olarak sunar!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[A student conducting archival research cannot complete a thesis in a single motion. They consult the library directory (Step 1: Which books exist?), open the table of contents of the selected book (Step 2: Inspect schemas), read the specific pages (Step 3: Execute query), and synthesize the conclusion (Step 4). A Multi-Step SQL Agent operates identically: it autonomously inspects table schemas, crafts a precise SQL query, executes it against the database, and summarizes the dataset in natural prose!]
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
      Text-to-SQL Ajanı Mimarisi ve Güvenlik Duvarı: 1) Çok Adımlı Döngü: Model tek seferde SQL tahmin etmek yerine ReAct döngüsüyle önce şemayı doğrular, sonra sorguyu test eder. 2) SQL Injection ve Güvenlik: Ajan ASLA veritabanına doğrudan yazma (UPDATE/DELETE/DROP) yetkisine sahip olmamalıdır! Veritabanı bağlantısı `READ ONLY` bir kullanıcıyla açılmalı, işlem süresi (Query Timeout) 3 saniye ile sınırlandırılmalıdır. 3) Row Limit: Sorguların sonuna zorunlu olarak `LIMIT 100` eklenmelidir; aksi halde model 10 milyon satırı belleğe çekip JVM'i kilitleyebilir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Text-to-SQL Agent Architecture & Guardrails: 1) Multi-Step ReAct Loop: Prevents blind queries by separating schema introspection from execution. 2) Security Gasket: The agent must connect via an unprivileged, read-only database user (`GRANT SELECT ONLY`). Mutation statements (DROP, UPDATE, ALTER) must be rejected by an AST parser before hitting the wire. 3) Query Circuit Breaker: Enforce mandatory `LIMIT 100` clauses and strict execution timeouts (e.g. 3,000ms) to prevent full-table scan resource exhaustion.]
    ]
  )
]

#java25_box[
```java
// Java 25: Güvenli Salt Okunur (Read-Only) SQL Ajan Tool'u
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import java.util.List;
import java.util.Map;

public class SafeSqlAgentTools {
    @Tool(description = "Veritabanındaki mevcut tabloların listesini döner.")
    public List<String> listTables() {
        return List.of("customers", "orders", "products");
    }

    @Tool(description = "Belirtilen tablonun sütun isimlerini ve veri tiplerini döner.")
    public String getTableSchema(@ToolParam(description = "Tablo adı") String tableName) {
        if ("orders".equalsIgnoreCase(tableName)) {
            return "orders(id INT, customer_id INT, amount DECIMAL, order_date DATE)";
        }
        return "Tablo bulunamadı.";
    }

    @Tool(description = "YALNIZCA SELECT içeren salt-okunur SQL sorgularını çalıştırır.")
    public List<Map<String, Object>> executeQuery(@ToolParam(description = "Çalıştırılacak SQL SELECT sorgusu") String sql) {
        String cleanSql = sql.trim().toUpperCase();
        if (!cleanSql.startsWith("SELECT")) {
            throw new SecurityException("Güvenlik İhlali: Sadece SELECT sorguları çalıştırılabilir!");
        }
        if (cleanSql.contains("DROP") || cleanSql.contains("DELETE") || cleanSql.contains("UPDATE")) {
            throw new SecurityException("Güvenlik İhlali: Zararlı SQL komutu tespit edildi!");
        }
        
        // Simüle edilmiş güvenli sonuç
        return List.of(Map.of("customer_id", 101, "total_spent", 45000.0));
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
      Ölümcül Güvenlik Felaketi: SQL Ajanına `admin` veya `postgres` kullanıcısı ile bağlantı vermek ve DROP/DELETE filtreleri koymamak, sistemin hacklenmesine ve tüm veritabanının silinmesine yol açabilir! MAANG mülakatlarında ilk sorulan şey 'Bu ajanın veritabanı izinleri nasıl sınırlandı?' olur.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Catastrophic security failure: Connecting an AI agent to a production database using an admin/superuser connection string. A single prompt injection can drop tables or exfiltrate private PII. Always use dedicated read-only credentials with strict execution timeouts.]
    ]
  )
]

#takeaways_box((
    ("Çok adımlı tool zinciri, karmaşık problemleri adım adım çözmeyi sağlar.", "Multi-step tool chaining enables models to resolve complex tasks via iterative discovery."),
    ("SQL Ajanları sadece SELECT yetkisine sahip olmalı ve sorgular LIMIT ile sınırlandırılmalıdır.", "SQL agents must operate under strict read-only permissions with enforced LIMIT clauses."),
    ("Kötü niyetli komutlar (DROP, DELETE) hem kod hem de DB izinleri düzeyinde engellenmelidir.", "Malicious queries must be blocked at both application parser and database privilege layers."),
))
