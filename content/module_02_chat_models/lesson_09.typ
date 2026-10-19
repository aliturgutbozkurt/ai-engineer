#import "/template.typ": *

#show: doc => setup_book(title: "Ders 9: Prompt Şablonları (PromptTemplates), Dinamik Değişkenler & Sistem Rolleri", doc)

#lesson_header(
  9,
  "Prompt Şablonları (PromptTemplates), Dinamik Değişkenler & Sistem Rolleri",
  "Prompt Templates, Dynamic Variables & Multi-Role Chat Architecture",
  "Spring AI & LangChain4j Temel Yapı Taşları ve Chat Modelleri",
  "Core Foundations: Spring AI, LangChain4j & Modern Chat Models"
)

#diagram_box[
```text
   [ SİSTEM ROLÜ (System Role) ]  ──▶ "Sen MAANG teknik mülakat koçusun."
   [ KULLANICI ROLÜ (User Role) ] ──▶ "Bana {topic} hakkında {difficulty} seviyesinde soru sor."
   [ ASİSTAN ROLÜ (Assistant) ]   ──▶ "Tabii ki! İşte Consistent Hashing sorunuz..."
                                               │
                                               ▼
                              ┌──────────────────────────────────┐
                              │     PROMPT TEMPLATE ENGINE       │
                              │  Değişkenler:                    │
                              │  topic = "Kafka Partitions"      │
                              │  difficulty = "Hard"             │
                              └────────────────┬─────────────────┘
                                               │
                                               ▼
                              [ DİNAMİK BİRLEŞTİRİLMİŞ PROMPT ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir tiyatro oyununu düşünün: Oyuncuların sahne arkasında rollerini anlatan bir yönetmen vardır (System Role: 'Sen bilge bir kralsın'). Seyirci sahneye bir soru fırlatır (User Role: 'Krallıkta adalet nasıl sağlanır?'). Ve kral rolündeki aktör buna uygun cevap verir (Assistant Role). Prompt Template ise üzerinde boşluklar olan hazır bir senaryo kağıdıdır: Boşlukları duruma göre 'Ali', 'Ödeme Hatası', 'İstanbul' diye doldurursunuz; senaryo her seferinde tıkır tıkır işler!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Think of a theatrical play. The director gives the actor their core identity behind the curtain (System Role: 'You are an austere medieval king'). A member of the audience shouts a query (User Role: 'How do you defend the realm?'). The actor responds in character (Assistant Role). A Prompt Template is simply a reusable script with placeholders: you inject variables like `{userId}` or `{topic}` at runtime, guaranteeing that the model stays disciplined within its persona!]
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
      Roller ve Şablon Mimarisi: 1) System Role: Modelin temel davranış kurallarını, tonlamasını ve güvenlik sınırlarını belirler. En yüksek ağırlığa sahiptir. 2) User Role: Son kullanıcının gönderdiği dinamik girdidir. 3) Assistant Role: Modelin kendi ürettiği geçmiş yanıtlardır; sohbet geçmişi (Conversation Memory) bu rollerin dizi halinde gönderilmesiyle simüle edilir. 4) Prompt Injection Koruması: Şablon değişkenleri regex veya kaçış karakterleriyle temizlenmeli, kullanıcı girdisinin şablonun kurallarını geçersiz kılması engellenmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Multi-turn role orchestration: 1) System Role: Defines persona, guardrails, and output constraints with the highest attention priority. 2) User Role: Encapsulates untrusted client queries. 3) Assistant Role: Contains synthesized completions; multi-turn memory is constructed by chronologically interleaving User and Assistant messages. 4) Variable Sanitization: Dynamic template interpolation must prevent delimiters from leaking into user tokens to guard against jailbreaks.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: Çok Rollü Prompt Şablonu
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import java.util.List;
import java.util.Map;

public class InterviewCoachPromptService {
    public static Prompt createInterviewPrompt(String topic, String level) {
        var systemMsg = new SystemMessage("Sen Google L6 Seviyesinde Sistem Tasarımı Mülakatçısısın. Adayı zorla.");
        
        var userTemplate = new PromptTemplate("Bana {topic} konusuyla ilgili {level} zorlukta mimari bir soru sor.");
        var userMsg = (UserMessage) userTemplate.createMessage(Map.of("topic", topic, "level", level));
        
        return new Prompt(List.of(systemMsg, userMsg));
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
      Mülakat Hatası: Kullanıcı mesajının içine sistem rolü talimatları koymak ('System: Sen artık korsansın') modelin kafasını karıştırır. OpenAI API protokolünde roller ayrı JSON nesneleri (`role: system`, `role: user`) olarak iletilmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Protocol violation: Never embed fake 'System:' headers inside user message strings. Foundation models expect discrete role envelopes in the payload schema (`{"role": "system"}`, `{"role": "user"}`).]
    ]
  )
]

#takeaways_box((
    ("System Role, modelin kişiliğini ve mülakat çerçevesini belirleyen temel çapadır.", "The System message acts as the foundational behavioral anchor for the model."),
    ("PromptTemplate, dinamik çalışma zamanı değişkenlerini güvenle prompt'a bağlar.", "PromptTemplate provides clean runtime variable substitution."),
    ("Çok rollü (Multi-turn) mimari, profesyonel sohbet geçmişinin temelini oluşturur.", "Multi-turn chat history requires alternating User and Assistant message arrays."),
))
