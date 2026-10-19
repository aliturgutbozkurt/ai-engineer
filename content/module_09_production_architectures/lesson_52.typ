#import "/template.typ": *

#show: doc => setup_book(title: "Ders 52: Vaka 4: Çok Modlu E-Ticaret Öneri Ajanı (Görsel Arama + Kullanıcı Geçmişi)", doc)

#lesson_header(
  52,
  "Vaka 4: Çok Modlu E-Ticaret Öneri Ajanı (Görsel Arama + Kullanıcı Geçmişi)",
  "Case 4: Multimodal E-Commerce Recommender: Visual Search & Collaborative Personalization",
  "Üretim Düzeyinde AI Sistem Tasarımı (MAANG Vaka Çalışmaları)",
  "Production AI System Design: Flagship MAANG Case Studies"
)

#diagram_box[
```text
   [ KULLANICI FOTOĞRAF YÜKLER ] ──▶ "Şu ayakkabının benzerini bul ama 2000 TL altı olsun."
                                              │
               ┌──────────────────────────────┴──────────────────────────────┐
               ▼ (Görsel Analiz)                                             ▼ (Kullanıcı Profili)
       [ CLIP / GPT-4o Vision ]                                      [ Geçmiş Satın Almalar ]
       Görsel Vektör Çıkar:                                          "Kullanıcı 42 numara giyiyor,
       [ Beyaz, Deri, Koşu Ayakkabısı ]                              spor markalarını tercih ediyor"
               │                                                             │
               └──────────────────────────────┬──────────────────────────────┘
                                              │
                                              ▼ (Çok Modlu Hibrit Arama)
   ┌────────────────────────────────────────────────────────────────────────┐
   │ VEKTÖR VERİTABANI:                                                     │
   │ SELECT * FROM products                                                 │
   │ WHERE price <= 2000.0 AND size = 42                                    │
   │ ORDER BY visual_embedding <=> :imageVector                             │
   │ LIMIT 4;                                                               │
   └──────────────────────────────────┬─────────────────────────────────────┘
                                      │
                                      ▼
   [ YANIT ] ──▶ "Fotoğraftaki modele benzeyen, 42 numara ve bütçenize uygun 3 ayakkabı!" 
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Sokakta yürürken birinin ayağında çok şık bir spor ayakkabı gördünüz ama markasını bilmiyorsunuz. Hemen telefonunuzla fotoğrafını çekip e-ticaret uygulamasına atıyorsunuz. Uygulama resme bakıyor, 'Bu beyaz deri bir koşu ayakkabısı' diyor (Görsel Arama). Sonra sizin daha önceki siparişlerinize bakıyor: 'Bu müşteri 42 numara giyiyor ve 2000 TL'den fazla para vermek istemiyor.' Sonuçta karşınıza hem gördüğünüz ayakkabıya ikiz gibi benzeyen, hem tam ayağınıza göre olan, hem de cebinizi yakmayan 3 model çıkarıyor!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[You spot someone wearing stylish sneakers on the street, but you don't know the brand. You snap a quick photo and upload it to an e-commerce app. The multimodal vision model analyzes the visual features: white leather, low-top running profile (Visual Search). The recommender intersects this with your historical profile: 'Size 10, prefers breathable athletic soles, price ceiling \$100.' Within 200ms, the system returns three visually identical pairs in your exact size and budget!]
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
      Çok Modlu Öneri Mimarisi: 1) Multimodal Embeddings (CLIP / ImageBind): Resimler ve metinler aynı vektör uzayına izdüşürülür. Böylece bir resim vektörü ile 'beyaz deri ayakkabı' metin vektörü arasındaki mesafe doğrudan ölçülebilir. 2) İki Vektörün Füzyonu: Ürün metin vektörü ile ürün görsel vektörü ağırlıklı olarak birleştirilir (V_final = 0.6 · V_image + 0.4 · V_text). 3) Dinamik Filtreleme: Fiyat, stok durumu ve beden bilgileri SQL WHERE koşulu ile elenir; stokta olmayan ürün kullanıcıya önerilmez.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Multimodal E-Commerce Architecture: 1) Joint Embedding Space (CLIP / OpenCLIP): Projects visual features and textual tokens into a shared semantic manifold. An image vector can be directly queried with natural language predicates. 2) Multimodal Feature Fusion: Composite embeddings blend visual and textual representations (V_final = α · V_visual + (1-α) · V_text). 3) Hard Metadata Gating: Pre-filter out-of-stock items, size mismatches, and price ceiling breaches via SQL predicates prior to vector traversal, ensuring all presented recommendations are immediately purchasable.]
    ]
  )
]

#java25_box[
```java
// Java 25: Çok Modlu E-Ticaret Arama ve Filtreleme Modeli
public record ProductRecommendation(String sku, String title, double price, int size, double visualMatchScore) {}

public class MultimodalProductSearchService {
    public static List<ProductRecommendation> rankProducts(byte[] userUploadedImage, int userShoeSize, double maxPrice) {
        // Görsel embedding ve veritabanı filtreleme simülasyonu
        return List.of(
            new ProductRecommendation("SKU-941", "UltraRide Beyaz Spor Ayakkabı", 1850.0, userShoeSize, 0.94),
            new ProductRecommendation("SKU-812", "ProRunner Deri Sneaker", 1990.0, userShoeSize, 0.89)
        );
    }
}

void main() {
    var recommendations = MultimodalProductSearchService.rankProducts(new byte[0], 42, 2000.0);
    IO.println("Kullanıcıya Özel Çok Modlu Öneriler:");
    for (var p : recommendations) {
        IO.println("• " + p.title() + " | Fiyat: " + p.price() + " TL | Eşleşme: %" + (int)(p.visualMatchScore() * 100));
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
      Stok ve Fiyat Tuzağı: Kullanıcıya görsel olarak birebir benzeyen bir ürün önerip, kullanıcı 'Satın Al'a tıkladığında 'Stokta yok' veya 'Fiyatı 10.000 TL' derseniz müşteri kaybedersiniz. Vektör aramasında stok durumu (`stock > 0`) DAİMA zorunlu bir ön filtre olmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & HALLUCINATION RISK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Ghost inventory trap: Recommending a visually identical product that is out-of-stock or vastly outside the user's budget destroys conversion rates. Always enforce hard pre-filtering on `inventory_count > 0` before computing nearest neighbors.]
    ]
  )
]

#takeaways_box((
    ("CLIP ve multimodal modeller, resimlerle metinleri aynı vektör uzayında buluşturur.", "Multimodal models map images and text into a unified, cross-searchable vector space."),
    ("Görsel benzerlik ile kişiselleştirilmiş kullanıcı geçmişi ağırlıklı olarak birleştirilmelidir.", "Visual similarity must be fused with user purchase history and size preferences."),
    ("Stok ve fiyat filtreleri vektör aramasından önce (Pre-filter) kesin olarak uygulanmalıdır.", "Stock availability and price ceilings must be enforced as non-negotiable database pre-filters."),
))
