#import "/template.typ": *

#show: doc => setup_book(title: "Ders 51: Vaka 3: Milyon Dokümanlı Kurumsal Arama Motoru (Glean / Perplexity Klonu)", doc)

#lesson_header(
  51,
  "Vaka 3: Milyon Dokümanlı Kurumsal Arama Motoru (Glean / Perplexity Klonu)",
  "Case 3: Enterprise Search Engine: Glean & Perplexity Architecture at Scale",
  "Üretim Düzeyinde AI Sistem Tasarımı (MAANG Vaka Çalışmaları)",
  "Production AI System Design: Flagship MAANG Case Studies"
)

#diagram_box[
```text
   [ KULLANICI SORUSU ] ──▶ "2026 Q1 bütçe planlaması kimin sorumluluğunda?"
                                      │
                                      ▼
                        ┌───────────────────────────┐
                        │   QUERY RE-WRITER & HyDE  │ ──▶ Sorguyu zenginleştir
                        └─────────────┬─────────────┘
                                      │
                     ┌────────────────┴────────────────┐
                     ▼                                 ▼
             [ HİBRİT VEKTÖR + BM25 ]          [ GİZLİLİK & İZİN FİLTRESİ ]
             pgvector / Milvus                 Google Drive, Jira, Slack, Notion
             10 Milyon Doküman Parçası         ACL Kontrolü (User.canRead(doc))
                     │                                 │
                     └────────────────┬────────────────┘
                                      │
                                      ▼ (Cross-Encoder Re-ranker: Top 5 Parça)
                        ┌───────────────────────────┐
                        │   SYNTHESIS & CITATIONS   │
                        │   Her cümlenin sonuna     │
                        │   [1], [2] kaynak linki   │
                        └─────────────┬─────────────┘
                                      │
                                      ▼
   [ YANIT ] ──▶ "Bütçe planlaması Merve Kaya'dadır [1]. Kaynak: [2026_Q1_Budget.pdf]" 
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Şirketinizde 10.000 çalışan olduğunu ve herkesin Google Drive'a, Slack'e, Jira'ya ve Notion'a her gün yüzlerce dosya attığını düşünün. 'Bizim şirketin yeni ofis adresi neydi?' diye aradığınızda 50 farklı eski adres çıkar. Glean ve Perplexity gibi kurumsal arama motorları şirketin tüm hafızasını tarar: En güncel dosyayı bulur, kimin yetkisi olduğunu kontrol eder (Ahmet'in gizli maaş dosyasını Mehmet'e göstermez) ve cevabı tam bir makale gibi yazıp her cümlenin yanına 'Bu bilgi şu linkten alındı [1]' diye tıklanabilir mavi kaynak linkleri koyar!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[In a 10,000-person tech enterprise, company knowledge is scattered across millions of Google Docs, Jira epics, Slack channels, and Notion pages. Searching for 'What is our corporate remote travel budget?' yields 50 obsolete spreadsheets. An enterprise search engine (like Glean or Perplexity) indexes this multi-system knowledge graph: it enforces user-level Access Control Lists (ACLs), synthesizes a coherent direct answer, and attaches verified, clickable footnote citations (`[1]`, `[2]`) to every assertion!]
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
      Kurumsal Perplexity Mimarisi: 1) ACL (Access Control Lists) Senkronizasyonu: En kritik zorluktur. Dokümanlar vektör veritabanına yazılırken Google Drive/Slack izin grupları (`allowed_users`, `allowed_roles`) metadata olarak işlenir. Arama anında kullanıcının yetkisi olmayan hiçbir doküman sorgu havuzuna giremez. 2) Çift Aşamalı Getirme + Cross-Encoder: 10 milyon dokümandan hibrit arama ile 100 aday çekilir; Cohere Rerank ile en iyi 5 parçaya indirgenir. 3) Kaynak Doğrulama (Citation Attributor): Model her iddiayı bir doküman ID'si ile eşleştirmek zorundadır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Enterprise Cognitive Search System Design: 1) Dynamic ACL Ingestion: Document ingestion pipelines must ingest upstream permission graphs (Google Workspace, Confluence, Slack ACLs). When a user searches, the vector store pre-filters documents against the user's verified security groups. 2) Two-Stage Pipeline with Dense/Sparse Fusion: Scans 10M+ documents via Elastic/BM25 and HNSW, merging candidates via RRF and pruning to top-5 through cross-encoders. 3) Footnote Citation Engine: Output synthesis requires inline citations (`[1]`). A post-processing AST validator checks that every referenced citation index genuinely contains the cited fact.]
    ]
  )
]

#java25_box[
```java
// Java 25: Doğrulanmış Kaynak Gösterimi (Citation Attribution) Modeli
import java.util.List;

public class EnterpriseSearchResult {
    public record Citation(int index, String documentTitle, String sourceUrl, String snippet) {}
    public record SynthesizedAnswer(String answerText, List<Citation> citations) {}

    public static SynthesizedAnswer generateMockResponse() {
        var citation1 = new Citation(1, "2026 Q1 Bütçe Planı", "https://drive.company.com/doc/101", "Planlama sorumlusu: Merve Kaya.");
        var citation2 = new Citation(2, "Şirket Organizasyon Şeması", "https://notion.company.com/org", "Merve Kaya Finans Direktörüdür.");

        String text = "2026 yılı Q1 bütçe planlaması Finans Direktörü Merve Kaya'nın sorumluluğundadır [1]. Merve Hanım doğrudan CFO'ya raporlar [2].";
        return new SynthesizedAnswer(text, List.of(citation1, citation2));
    }
}

void main() {
    var searchResult = EnterpriseSearchResult.generateMockResponse();
    IO.println("Kurumsal Arama Yanıtı:");
    IO.println(searchResult.answerText());
    IO.println("
Doğrulanmış Kaynaklar:");
    for (var c : searchResult.citations()) {
        IO.println("[" + c.index() + "] " + c.documentTitle() + " -> " + c.sourceUrl());
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
      Güvenlik İhlali (Permission Leakage): Ajan Ahmet'in sorusunu yanıtlarken yetkisiz olduğu bir belgeden veri çeker ve cevabı ekrana yazarsa, belgeye link vermese bile gizli bilgi sızmış olur! İzin kontrolü model aşamasında DEĞİL; veritabanı vektör sorgusu aşamasında (WHERE allowed_users CONTAINS) yapılmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Permission exfiltration disaster: If permission filtering occurs after retrieval, an unauthorized document summary can leak confidential salary figures in the final synthesis. Access Control Lists must be evaluated as strict pre-filters directly at the database index layer.]
    ]
  )
]

#takeaways_box((
    ("Kurumsal aramada erişim izinleri (ACL) modelde değil, veritabanı aramasında filtrelenmelidir.", "Access control lists (ACLs) must be enforced at the database layer, not within prompt text."),
    ("Kaynak gösterimi (Citations), kurumsal güven ve doğrulanabilirlik için zorunludur.", "Verified footnote citations are mandatory for enterprise trust and regulatory compliance."),
    ("Hibrit arama + Re-ranking, milyonlarca dokümandan en güncel cevabı çekmenin tek yoludur.", "Hybrid search coupled with cross-encoder re-ranking is essential to cut through corporate noise."),
))
