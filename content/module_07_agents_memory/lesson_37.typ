#import "/template.typ": *

#show: doc => setup_book(title: "Ders 37: LLM vs AI Agent: ReAct (Reasoning + Acting) Döngüsünün Anatomisi", doc)

#lesson_header(
  37,
  "LLM vs AI Agent: ReAct (Reasoning + Acting) Döngüsünün Anatomisi",
  "LLM vs AI Agent: The Autonomous ReAct (Reasoning + Acting) Loop",
  "AI Ajanları (AI Agents), Otonom Akışlar ve Bellek Mimarisi",
  "AI Agents, Autonomous Loops & Conversational Memory Systems"
)

#diagram_box[
```text
   [ KULLANICI HEDEFİ ] ──▶ "Bana en ucuz İstanbul-Berlin uçuşunu bul ve al."
                                      │
               ┌──────────────────────┴──────────────────────┐
               ▼                                             ▼
       [ STANDART LLM ]                             [ AI AGENT (ReAct) ]
       Tek seferde tahmin eder:                     Döngüye girer:
       "Genelde Pegasus ucuzdur."                   ┌─────────────────────────────┐
       (Eylemsiz, güncel veri yok!)                 │ 1. THOUGHT (Akıl Yürütme)   │
                                                    │ 2. ACTION (FlightSearch API)│
                                                    │ 3. OBSERVATION (Sonuçlar)   │
                                                    │ 4. REFLECTION (Değerlendir) │
                                                    └──────────────┬──────────────┘
                                                                   │ (Hedefe ulaşana dek dön!)
                                                                   ▼
                                                    [ BİLET BULUNDU VE ALINDI! ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Normal bir LLM, kütüphanede oturan çok bilmiş bir profesör gibidir: Ona ne sorarsanız konuşur, anlatır ama yerinden kalkıp bir bardak su bile getiremez (Sadece Konuşur). Bir AI Agent ise sırtına çanta takıp sokağa fırlayan bir özel dedektiftir! Bir hedef verirsiniz; dedektif önce düşünür (Thought: 'Nereden başlamalıyım?'), sonra harekete geçer (Action: 'Havaalanına git'), sonra gördüklerini inceler (Observation: 'Uçak kalkmış') ve hedefine ulaşana kadar bu döngüyü tekrarlar!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[A standard LLM is a brilliant scholar seated in an armchair: ask anything, and they will lecture eloquently, but they physically cannot leave the room to brew a cup of coffee (Output is purely tokens). An AI Agent is a field operative! Given a high-level goal, it autonomously drives a ReAct loop: it reasons about its current state (Thought), interacts with the environment (Action: invoking tools), ingests the output (Observation), and iterates until the objective is satisfied!]
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
      ReAct (Yao et al., Princeton/Google) Çerçevesinin Mühendisliği: 1) Thought: Model içsel bir akıl yürütme adımı atar ('Kullanıcının bütçesini kontrol etmeliyim'). 2) Action: Hangi tool'un hangi parametrelerle çağrılacağına karar verir (`checkBudget(userId)`). 3) Observation: Aracın ürettiği ham sonuç prompt'a eklenir. 4) Loop Termination: Model hedefin tamamlandığını anladığında nihai yanıtı döner veya durma kriterine (Max Iterations, ör. 10 adım) takılır. 5) Sonsuz Döngü Koruması: Ajanlar aynı hatayı tekrar tekrar yaparak sonsuz döngüye girebilir; bu yüzden sıkı bir `maxIterations` koruması zorunludur.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[ReAct Framework & Runtime Controls: 1) Cognitive Loop: Interweaves reasoning traces with task-specific actions. The thought token stream allows the model to track progress, handle exceptions, and dynamically adjust action plans. 2) Termination Condition: The cycle terminates when the model produces an answer token stream instead of a tool invocation. 3) Infinite Loop Mitigation: Autonomous agents frequently enter pathological loops (repeatedly calling failed tools). Systems must enforce a strict `max_steps` threshold (typically 5 to 10), throwing an escalation event if exceeded.]
    ]
  )
]

#java25_box[
```java
// Java 25: ReAct Ajan Döngüsü ve Adım Kontrolcüsü (Loop Governor)
public class ReActAgentGovernor {
    private final int maxSteps;

    public record AgentStep(int stepIndex, String thought, String action, String observation) {}

    public ReActAgentGovernor(int maxSteps) {
        this.maxSteps = maxSteps;
    }

    public boolean canContinue(int currentStep) {
        if (currentStep >= maxSteps) {
            IO.println("⚠️ AJAN GÜVENLİK SINIRI: Maksimum adım sayısına (" + maxSteps + ") ulaşıldı! Döngü kırıldı.");
            return false;
        }
        return true;
    }
}

void main() {
    var governor = new ReActAgentGovernor(5);
    for (int step = 1; step <= 6; step++) {
        if (!governor.canContinue(step)) break;
        IO.println("Adım #" + step + " yürütülüyor (Thought -> Action -> Observation)");
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
      Maliyet Uyarısı (Agent Infinite Burn): Sonsuz döngü koruması olmayan bir ajan, bir API hata verdiğinde sürekli aynı isteği atarak dakikalar içinde yüzlerce dolarlık token yakabilir! Her ajanın mutlak bir `maxSteps = 8` limiti ve toplam bütçe tavanı olmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Cost hazard: An unconstrained ReAct agent caught in an exception retry loop can execute 50 recursive calls in minutes, burning significant token budget. Always inject hard bounds: `max_iterations \<= 8` and execution timeout gates.]
    ]
  )
]

#takeaways_box((
    ("LLM sadece metin üretir; AI Agent ise hedefe ulaşmak için araçları otonom kullanır.", "An LLM generates text; an AI Agent autonomously reasons, acts, and iterates toward a goal."),
    ("ReAct döngüsü: Thought (Düşün) -> Action (Eyleme Geç) -> Observation (Gözlemle) adımlarından oluşur.", "The ReAct loop operates via interleaved Thought, Action, and Observation cycles."),
    ("Üretim ortamındaki tüm ajanlar mutlaka maksimum adım ve bütçe sınırıyla korunmalıdır.", "All production agents must enforce strict maximum step limits and circuit breakers."),
))
