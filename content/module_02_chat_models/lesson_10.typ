#import "/template.typ": *

#show: doc => setup_book(title: "Ders 10: Yapılandırılmış Çıktılar (Structured Outputs, JSON Schema & Record Eşleme)", doc)

#lesson_header(
  10,
  "Yapılandırılmış Çıktılar (Structured Outputs, JSON Schema & Record Eşleme)",
  "Structured Outputs: Enforcing Deterministic JSON Schema & Record Deserialization",
  "Spring AI & LangChain4j Temel Yapı Taşları ve Chat Modelleri",
  "Core Foundations: Spring AI, LangChain4j & Modern Chat Models"
)

#diagram_box[
```text
   [ PROMPT ] ──▶ "İstanbul'un hava durumu ve gezi tavsiyesi nedir?"
                       │
                       ▼ (OpenAI Structured Outputs / JSON Schema)
   ┌────────────────────────────────────────────────────────────────────────┐
   │ {                                                                      │
   │   "type": "object",                                                    │
   │   "properties": {                                                      │
   │     "cityName": { "type": "string" },                                  │
   │     "temperatureCelsius": { "type": "number" },                        │
   │     "recommendations": { "type": "array", "items": { "type": "string"}}│
   │   },                                                                   │
   │   "required": ["cityName", "temperatureCelsius", "recommendations"],   │
   │   "additionalProperties": false                                        │
   │ }                                                                      │
   └───────────────────────────────────┬────────────────────────────────────┘
                                       │
                                       ▼ (Garantili 100% Geçerli JSON)
   [ JAVA 25 RECORD ] ──▶ CityReport[cityName="İstanbul", temp=22.5, ...]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir arkadaşınızdan bir adres istediğinizde bazen 'Kadıköy'de falan bir yerdeydi işte' diye yarım yamalak anlatabilir (Serbest Metin). Ama bir kargo şirketine adres verirken İl, İlçe, Mahalle, Sokak ve Posta Kodu kutularını tek tek doldurmak ZORUNDASINIZDIR (Yapılandırılmış Form)! OpenAI'ın Structured Outputs özelliği modele 'Bana kafana göre hikaye anlatma; sadece ve sadece şu kutuları eksiksiz doldur!' demektir. Böylece arka plandaki Java uygulamanız JSON bozuk geldiği için ASLA patlamaz!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[If you ask a friend for an address, they might casually text: 'It's somewhere around downtown near that cafe' (Unstructured Free Text). But when filing customs forms, you must fill out strict, mandatory boxes: City, Zip Code, Tax ID (Structured Schema). OpenAI's Structured Outputs enforces mathematical grammars on token generation: the model physically CANNOT generate a token that violates the JSON Schema! Your Java deserializer is 100% guaranteed to parse the payload without runtime syntax errors!]
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
      Structured Outputs Teknik Derinliği: 1) Neden Eski Yöntemler (Prompt ile 'JSON üret' demek) Yetersizdi?: Eski promptlarda model araya 'İşte istediğiniz JSON: { ... }' gibi metinler ekler veya alan adlarını yanlış yazardı. 2) Constrained Decoding (Grammar Enforced): OpenAI token üretirken izin verilen token maskesini JSON şemasına göre dinamik sınırlar; geçersiz hiçbir karakter üretilemez. 3) Spring AI ve LangChain4j Desteği: Java `record` sınıfındaki alanlar, tipler ve açıklamalar reflection ile taranarak JSON Schema Draft 7 formatına dönüştürülür ve API isteğine eklenir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Constrained Decoding Mechanics: 1) The Failure of Naive Prompting: Instructing a model to 'Respond in pure JSON' suffers from non-zero failure rates (spurious markdown backticks, missing closing braces, invalid types). 2) Context-Free Grammars (CFG): OpenAI compiles the supplied JSON schema into a finite state machine (FSM) during decoding. At each step, invalid tokens receive zero probability, achieving mathematical 100% adherence. 3) Schema Synthesis: Spring AI and LangChain4j inspect Java 25 record components, extracting property names and types to build compliant schemas with `additionalProperties: false`.]
    ]
  )
]

#java25_box[
```java
// Java 25 & LangChain4j: Structured Outputs ile Kesin Tip Garantili Çıktı
import dev.langchain4j.service.AiServices;
import dev.langchain4j.service.UserMessage;
import dev.langchain4j.model.openai.OpenAiChatModel;
import java.util.List;

public class ArchitectureAuditor {
    public record SecurityVulnerability(String cveId, String component, int severityLevel, String remediation) {}
    public record AuditReport(String targetService, int overallScore, List<SecurityVulnerability> findings) {}

    public interface AuditorService {
        @UserMessage("Şu mimari tasarımı denetle ve güvenlik açıklarını listele: {design}")
        AuditReport audit(String design);
    }

    void main() {
        var model = OpenAiChatModel.builder()
            .apiKey(System.getenv("OPENAI_API_KEY"))
            .modelName("gpt-4o-2024-08-06") // Structured Output destekli model
            .responseFormat("json_schema")
            .build();

        AuditorService service = AiServices.create(AuditorService.class, model);
        IO.println("Auditor Service başarıyla kuruldu. Çıktı formatı: AuditReport Record");
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
      Önemli Kural: Structured Outputs kullanırken JSON şemasında `additionalProperties: false` bulunmalı ve tüm alanlar `required` listesinde yer almalıdır. Aksi takdirde OpenAI API 400 Bad Request döner.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[API requirement: OpenAI Structured Outputs mandate that all object definitions declare `additionalProperties: false` and explicitly list all keys in the `required` array.]
    ]
  )
]

#takeaways_box((
    ("Structured Outputs, modelin JSON şemasına %100 uymasını matematiksel olarak garanti eder.", "Structured Outputs mathematically guarantee 100% compliance with your JSON schema."),
    ("Java 25 Record sınıfları, deterministik LLM çıktı modelleri için en ideal tiptir.", "Java 25 Records serve as the gold-standard representation for structured LLM contracts."),
    ("Arka plan servislerine veri iletirken serbest metin yerine daima JSON Schema kullanılmalıdır.", "Always decouple LLMs from downstream microservices using strict schema contracts."),
))
