#import "/template.typ": *

#show: doc => setup_book(title: "Ders 60: Staff+ AI Engineer Liderlik Değerlendirme Rubriği ve Başarı İpuçları", doc)

#lesson_header(
  60,
  "Staff+ AI Engineer Liderlik Değerlendirme Rubriği ve Başarı İpuçları",
  "Staff+ AI Leadership: The Principal Engineer Evaluation Rubric & Closing Advice",
  "AI Güvenliği, Gözlemlenebilirlik & MAANG Mülakat Ustalığı",
  "AI Security, Observability & The MAANG Interview Mastery Rubric"
)

#diagram_box[
```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                 STAFF+ AI ENGINEER EVALUATION RUBRIC (MAANG L6+)            │
└─────────────────────────────────────────────────────────────────────────────┘
  [ JUNIOR / MID LEVEL ]                  [ STAFF+ PRINCIPAL LEVEL ]
  • "OpenAI API'sine prompt atarım."     • "Maliyet, TPM limitleri ve SLAs nedir?"
  • "Pinecone kurar geçerim."             • "pgvector vs Qdrant vs Milvus analizi."
  • "Model doğru cevap veriyor gibi."    • "RAGAS ile CI/CD'de otomatik sadakat testi."
  • "Tek bir LLM her şeyi çözer."        • "Model Routing, Cache ve Güvenlik Guardrails."
  • Reaktif & Kod Odaklı                  • Sistemik, Güvenilir & İş Değeri Odaklı
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir inşaatta çırak sadece tuğlayı üst üste koyar (Kod yazar). Usta başı duvarın düz olup olmadığını kontrol eder (Senior). Ama Baş Mimar (Staff+ Principal Engineer); binanın depreme dayanıklı olup olmayacağını, 50 yıl sonra çatlayıp çatlamayacağını, bütçenin yetip yetmeyeceğini ve belediyeden ruhsat alınıp alınamayacağını baştan planlar! Staff+ AI Engineer olmak; sadece kod yazmak değil; şirketin parasını, güvenliğini, itibarını ve sistemin geleceğini bir mimar gibi sırtlamaktır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[On a skyscraper project, an apprentice lays bricks (writes code). A senior foreman inspects wall plumbness. But the Principal Chief Architect (Staff+ Engineer) evaluates seismic structural dynamics, 50-year concrete fatigue, municipal compliance zoning, and financial solvency before a single shovel touches earth! A Staff+ AI Engineer doesn't just call APIs; they take end-to-end ownership of enterprise security, unit economics, regulatory compliance, and generational system resilience!]
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
      Staff+ AI Engineer Değerlendirme Boyutları: 1) Sistemik Düşünce (Systemic Thinking): Sadece mutlu yolu (Happy Path) değil; model çöktüğünde (Fallback), rate limit aşıldığında (Backoff), saldırı olduğunda (Jailbreak) ve veri sızdığında sistemin nasıl davranacağını baştan tasarlama. 2) İş Değeri ve ROI (Return on Investment): 'Bu yapay zeka özelliği şirkete kaç yüz bin dolar kazandıracak ve operasyonel maliyeti ne olacak?' sorusunu cevaplayabilme. 3) Mentörlük ve Standartlar: Şirket genelinde Spring AI / LangChain4j en iyi pratiklerini, prompt şablon standartlarını ve güvenlik testlerini (CI/CD) bir kurum kültürü haline getirme.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Staff+ Evaluation Dimensions (Google L6 / Meta E6): 1) Resiliency Under Adversity: Does the candidate proactively design for failure domains (API outages, silent model drift, token quota exhaustion, prompt injections)? 2) Unit Economics & Business Value: Can they articulate the return on investment (ROI)? Justifying why a \$0.002 query saves \$4.50 in human representative labor. 3) Technical Multiplying: Elevating peer teams by establishing golden Spring AI archetypes, centralized evaluation pipelines in CI/CD, and formal architectural review rubrics.]
    ]
  )
]

#java25_box[
```java
// Java 25: Staff+ AI Mühendisliği Tebrik ve Tamamlama Beyanı
public class StaffPlusAiEngineerManifesto {
    public record ArchitectMilestone(
        int totalLessonsCompleted,
        int totalModulesConquered,
        String competencyLevel,
        String certification
    ) {}

    public static ArchitectMilestone achieveStaffPlus() {
        return new ArchitectMilestone(
            60,
            10,
            "Staff+ Principal AI Engineer (MAANG L6+ Ready)",
            "Yüksek Ölçekli Dağıtık Yapay Zeka Mimarisi Ustalık Belgesi"
        );
    }
}

void main() {
    var milestone = StaffPlusAiEngineerManifesto.achieveStaffPlus();
    IO.println("🎓 TEBRİKLER! TÜM 60 DERS BAŞARIYLA TAMAMLANDI!");
    IO.println("Tamamlanan Müfredat: " + milestone.totalModulesConquered() + " Bölüm • " + milestone.totalLessonsCompleted() + " Ders");
    IO.println("Seviye: " + milestone.competencyLevel());
    IO.println("Teknolojiler: Java 25 (Loom) • Spring AI • LangChain4j • OpenAI • pgvector");
    IO.println("Artık MAANG mülakatlarında ve kurumsal mimaride liderlik etmeye hazırsınız!");
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
      Son Tavsiye: Mülakatta asla ezber cevaplar vermeyin. Mülakatçının sorduğu her sorunun altında bir iş problemi yatar. Sakin kalın, önce dinleyin, netleştirin ve bir mimar özgüveniyle sistemi adım adım inşa edin. Yolunuz açık olsun!
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Final closing counsel: Never recite dogmatic scripts in high-stakes interviews. Treat the interviewer as a senior peer collaborating on an unsolved production problem. Listen deeply, clarify scope, anchor decisions in data, and design with conviction.]
    ]
  )
]

#takeaways_box((
    ("Staff+ mühendislik; kod yazmanın ötesinde mimari dayanıklılık, güvenlik ve maliyet liderliğidir.", "Staff+ engineering transcends code: it commands architectural resilience, safety, and unit economics."),
    ("60 derslik bu yolculuk sizi temel kavramlardan kurumsal üretim sistemlerine ulaştırmıştır.", "This 60-lesson masterclass has taken you from token fundamentals to enterprise production scale."),
    ("Java 25, Spring AI ve LangChain4j ile geleceğin kurumsal yapay zeka dünyası sizin elinizdedir.", "Armed with Java 25, Spring AI, and LangChain4j, you are equipped to build the future of AI."),
))
