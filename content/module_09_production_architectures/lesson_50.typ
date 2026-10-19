#import "/template.typ": *

#show: doc => setup_book(title: "Ders 50: Vaka 2: Kod Asistanı Mimarisi (GitHub Copilot Klonu: AST, Vector & Streaming)", doc)

#lesson_header(
  50,
  "Vaka 2: Kod Asistanı Mimarisi (GitHub Copilot Klonu: AST, Vector & Streaming)",
  "Case 2: Code Assistant Architecture: AST Parsing, Vector Code Indexing & Fill-In-The-Middle",
  "Üretim Düzeyinde AI Sistem Tasarımı (MAANG Vaka Çalışmaları)",
  "Production AI System Design: Flagship MAANG Case Studies"
)

#diagram_box[
```text
   [ GELİŞTİRİCİ IDE (Cursor / VS Code) ] ──▶ Kullanıcı 'implements UserSer...' yazdı!
                                      │
                                      ▼ (Tetiği Çek: İmleç Konumu / Cursor Position)
   ┌────────────────────────────────────────────────────────────────────────┐
   │                     IDE CLIENT CONTEXT COLLECTOR                       │
   │  1. Prefix (İmleçten önceki 50 satır kod)                              │
   │  2. Suffix (İmleçten sonraki 20 satır kod)                             │
   │  3. AST Parser (Ağaç Analizi: İlgili import'lar ve interface tanımı)   │
   │  4. Vektör Kod Deposu (Projedeki benzer metodları çek)                 │
   └──────────────────────────────────┬─────────────────────────────────────┘
                                      │
                                      ▼ (FIM: Fill-in-the-Middle Prompt Formatı)
   [ OPENAI KOD TAMAMLAMA ] ──▶ <PRE> Prefix <SUF> Suffix <MID> [ÖNERİLEN KOD!]
                                      │
                                      ▼ (Ultra Düşük Gecikme: TTFT < 100ms!)
   [ GRİ HAYALET YAZI (Ghost Text) ] ──▶ Ekrana anında düşer! Tab'a basınca tamamlar!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Akıllı bir çırak marangozun yanınızda durduğunu düşünün. Siz tahtayı ölçüp tam 'Bana çiv...' dediğiniz anda, çırak elinize çekici ve doğru boydaki çiviyi uzatır (Siz cümleyi bitirmeden ihtiyacınızı anlar!). GitHub Copilot tam olarak bu çıraktır: İmlecinizin nerede olduğuna bakar, yukarıda hangi sınıfları import ettiğinizi inceler (AST), projenin diğer dosyalarında nasıl kod yazdığınızı hatırlar ve siz daha klavyeye basarken ekrana açık gri renkte doğru kodu fısıldar!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Imagine a brilliant apprentice standing beside a master surgeon. Before the surgeon even finishes articulating the request, the apprentice slaps the exact scalpel size into the surgeon's palm. A real-time code assistant operates with this predictive foresight: it captures the cursor coordinates, parses the Abstract Syntax Tree (AST) of the active workspace, matches relevant library imports, and leverages Fill-in-the-Middle (FIM) prompt formatting to project ghost text within 100 milliseconds!]
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
      Kod Asistanı Sistem Tasarımı Gereksinimleri: 1) FIM (Fill-in-the-Middle): Standart LLM sadece sonrasını tahmin eder. Kod asistanı ise imlecin üstündeki kod (Prefix) ile altındaki kodu (Suffix) modele verir ve aradaki boşluğu (`\<MID>`) doldurmasını ister. 2) AST (Abstract Syntax Tree) Analizi: Düz metin aramak yerine Tree-Sitter kütüphanesiyle kod ağacı çıkarılır; çağrılan fonksiyonun interface tanımı ve import'ları bağlama eklenir. 3) Katı Gecikme SLA'sı: Geliştirici yazarken önerinin çıkması için TTFT \< 150ms olmak zorundadır! Bu yüzden küçük, kod için optimize edilmiş hızlı modeller (GPT-4o-mini / StarCoder) kullanılır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Code Assistant Engineering & Latency Budgets: 1) Fill-in-the-Middle (FIM): Specialized models ingest three partitioned segments: `\<PRE>` (pre-cursor text), `\<SUF>` (post-cursor text), and generate within `\<MID>`. This enables context-aware autocompletion inside existing method bodies. 2) Tree-Sitter AST Slicing: Rather than dumping whole files, a local daemon parses AST nodes to extract active class hierarchies, interface contracts, and imported method signatures. 3) Sub-150ms SLA: Programmers type at 5-10 characters/sec. If ghost text latency exceeds 150ms, the developer has already typed past the completion point, rendering it useless. Speculative decoding and aggressive client-side debouncing (50ms) are non-negotiable.]
    ]
  )
]

#java25_box[
```java
// Java 25: Kod Asistanı için Fill-In-The-Middle (FIM) Prompt Modeli
public record FimCodePrompt(String filePath, String prefix, String suffix) {
    public String toOpenAiFimFormat() {
        return String.format("""
            // Dosya: %s
            <PRE>
            %s
            <SUF>
            %s
            <MID>
            """, filePath, prefix, suffix);
    }
}

void main() {
    var prompt = new FimCodePrompt(
        "OrderService.java",
        "public class OrderService {
    public void cancelOrder(String id) {",
        "    }
}"
    );

    IO.println("Copilot FIM Prompt Yapısı:");
    IO.println(prompt.toOpenAiFimFormat());
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
      Telif Hakkı ve Güvenlik Riski: Model internetten ezberlediği lisanslı (GPL) veya zararlı bir kod parçasını geliştiricinin projesine doğrudan önerebilir. Kurumsal kod asistanlarında üretilen kodun açık kaynak kütüphanelerle birebir eşleşip eşleşmediğini kontrol eden bir 'License & Secret Scanner' filtresi bulunmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Copyright & Secret Leakage: Generative code models risk spitting out memorized GPL-licensed code or accidentally echoing hardcoded AWS API tokens found in training sets. Enterprise code assistants must integrate a real-time post-generation license and secret scanner before displaying ghost text.]
    ]
  )
]

#takeaways_box((
    ("Fill-in-the-Middle (FIM), kodun hem öncesini hem sonrasını görerek arayı doldurur.", "Fill-in-the-Middle (FIM) generates code aware of both prefix and suffix boundaries."),
    ("AST (Tree-Sitter) analizi, sadece imlecin etrafındaki ilgili tipleri ve metotları seçer.", "AST parsing isolates relevant imports, interfaces, and types to keep context razor-sharp."),
    ("Kod asistanlarında gecikme SLA'sı (TTFT \< 150ms) başarıyı belirleyen 1 numaralı faktördür.", "Sub-150ms TTFT latency is the defining engineering SLA for real-time code completion."),
))
