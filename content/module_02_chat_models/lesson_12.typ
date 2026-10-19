#import "/template.typ": *

#show: doc => setup_book(title: "Ders 12: Çoklu Modalite (Multimodal AI: GPT-4o ile Resim, Ses & Belge Analizi)", doc)

#lesson_header(
  12,
  "Çoklu Modalite (Multimodal AI: GPT-4o ile Resim, Ses & Belge Analizi)",
  "Multimodal AI Engineering: Processing Vision, Audio & Documents with GPT-4o",
  "Spring AI & LangChain4j Temel Yapı Taşları ve Chat Modelleri",
  "Core Foundations: Spring AI, LangChain4j & Modern Chat Models"
)

#diagram_box[
```text
   [ KULLANICI GİRDİSİ ] ──▶ Metin: "Bu mimari diyagramdaki SPOF nerede?"
                                 + Resim: [ AWS_Architecture_Diagram.png ]
                                      │
                                      ▼ (MIME Type: image/png & Base64 / URL)
   ┌────────────────────────────────────────────────────────────────────────┐
   │                  SPRING AI MULTIMODAL PROMPT CLIENT                    │
   │                                                                        │
   │  var media = new Media(MimeTypeUtils.IMAGE_PNG, imageResource);        │
   │  var userMessage = new UserMessage("Analiz et", List.of(media));       │
   └──────────────────────────────────┬─────────────────────────────────────┘
                                      │
                                      ▼
                        [ OPENAI GPT-4o VISION ENGINE ]
                                      │
                                      ▼
   [ YANIT ] ──▶ "Diyagramda tek bir RDS veritabanı var, Multi-AZ olmadığı için SPOF!" 
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Eskiden bir doktora telefon edip 'Kolumda kırmızı bir leke var' diye anlatmaya çalışırdınız; doktor da kafasında canlandırmaya çalışırdı (Sadece Metin). Artık doktora kolunuzun fotoğrafını WhatsApp'tan atıyorsunuz; doktor lekeyi gözleriyle görüp anında teşhis koyuyor! Multimodal AI tam olarak budur: Modele sadece yazı yazmazsınız; ekran görüntüsü, mimari şema, PDF faturası veya ses kaydı yüklersiniz. Model görsele bakar, pikselleri analiz eder ve soruya gözüyle görmüş gibi yanıt verir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[In the past, you had to call a mechanic and verbally describe strange engine noises over the phone (Text-only). Today, you take a crisp photo of the dashboard and upload it directly. Multimodal models like GPT-4o bridge the sensory divide: they consume text, images, and audio waveforms natively within the same attention layers. You can feed an architectural whiteboard screenshot into the model and ask it to audit Single Points of Failure directly from visual pixels!]
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
      Çok Modlu (Vision) Mimarisi ve Token Maliyeti: 1) Patch Extraction: GPT-4o resmi piksellerine göre küçük kare parçalara (512x512 piksellik Patches) böler. Her patch yaklaşık 170 token harcar. 2) High Res vs Low Res Modu: `low` modunda tüm resim tek bir 85 tokenlık küçük kareye indirgenir (hızlı ve ucuz). `high` modunda detaylı pikseller işlenir (detaylı mimari şemalar ve OCR için zorunlu). 3) Medya Formatı: Base64 kodlaması payload boyutunu %33 artırır; üretimde resimler Amazon S3 veya Cloudflare R2'ye yüklenip modele doğrudan imzalı URL (Pre-signed URL) verilmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Multimodal Vision Mechanics: 1) Patch Embeddings: Vision transformers tile input images into 512x512 sub-patches, with each patch mapped to ~170 token embeddings. 2) Resolution Modes: 'Low' resolution processes the canvas as a single 85-token thumbnail (ideal for general object classification). 'High' resolution tiles detailed regions up to thousands of tokens (essential for code OCR and dense architectural schematics). 3) Transport Hygiene: Base64 encoding inflates network bandwidth by 33%; enterprise architectures upload assets to object storage (S3) and transmit ephemeral pre-signed HTTPS URLs.]
    ]
  )
]

#java25_box[
```java
// Java 25 & Spring AI: GPT-4o Vision ile Mimari Şema Analizi
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.model.Media;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.util.MimeTypeUtils;

public class ArchitectureVisionAuditor {
    private final ChatClient chatClient;

    public ArchitectureVisionAuditor(ChatClient.Builder builder) {
        this.chatClient = builder.build();
    }

    public String auditDiagram(byte[] imageBytes, String question) {
        var mediaResource = new ByteArrayResource(imageBytes);
        var media = new Media(MimeTypeUtils.IMAGE_PNG, mediaResource);

        return chatClient.prompt()
            .user(u -> u.text(question).media(media))
            .call()
            .content();
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
      Maliyet Tuzağı: 4K çözünürlükte devasa bir resmi 'high' modunda gönderirseniz tek bir resim 3000-4000 token tüketebilir! İstemciden gelen resimleri modele göndermeden önce sunucuda 1080p'ye küçültmek (Downscaling) maliyeti %70 azaltır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Cost vulnerability: Submitting raw 4K screenshots in 'high' detail mode consumes up to 4,000 tokens per call. Always resize and downsample images client-side or at your API gateway to max 1080p before dispatching to OpenAI.]
    ]
  )
]

#takeaways_box((
    ("GPT-4o, metin ve görsel veriyi aynı bağlam penceresinde yerel olarak işler.", "GPT-4o natively fuses text and visual modalities in a unified context window."),
    ("Büyük resimler token tüketimini hızla artırır; downscaling ve 'low' çözünürlük değerlendirilmelidir.", "High-res images inflate token counts; pre-processing and downscaling are critical cost levers."),
    ("Üretimde Base64 yerine daima S3/CDN pre-signed URL bağlantıları tercih edilmelidir.", "Favor pre-signed S3/CDN URLs over heavy Base64 strings in production payloads."),
))
