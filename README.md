# 🤖 MAANG AI Engineer ELI5 Masterclass
### Aptala Anlatır Gibi: MAANG Mülakatlarına Hazırlanan Mühendisler İçin AI Sistem Mimarisi & Mühendisliği

[![Java 25](https://img.shields.io/badge/Java-25%20LTS-orange.svg?logo=openjdk&logoColor=white)](https://openjdk.org/)
[![Spring AI](https://img.shields.io/badge/Spring%20AI-1.0.0-green.svg?logo=spring&logoColor=white)](https://spring.io/projects/spring-ai)
[![LangChain4j](https://img.shields.io/badge/LangChain4j-0.35.0-blue.svg)](https://github.com/langchain4j/langchain4j)
[![OpenAI GPT-4o](https://img.shields.io/badge/OpenAI-GPT--4o%20%7C%20Embeddings-black.svg?logo=openai&logoColor=white)](https://platform.openai.com/)
[![Typst](https://img.shields.io/badge/Typst-0.15+-239dad.svg)](https://typst.app/)
[![Bilingual](https://img.shields.io/badge/Languages-Türkçe%20%7C%20English-emerald.svg)](#)

---

## 📖 Proje Hakkında / About The Masterclass

Bu proje; **Meta, Amazon, Apple, Netflix, Google (MAANG / FAANG)** ve küresel teknoloji devlerinin **Senior & Staff AI Engineer / AI Systems Architect** mülakatlarına hazırlanan yazılım mühendisleri için hazırlanmış kapsamlı, çift dilli (Türkçe & İngilizce), mimari şemalı ve **Java 25 / Spring AI / LangChain4j / OpenAI** kodlu eğitim setidir.

Dünyanın en karmaşık yapay zeka mühendisliği kavramları (Attention mekanizması, HNSW graf indeksleme, pgvector, Hibrit Dense+BM25 arama ve RRF, Cross-Encoder Re-ranking, ReAct döngüleri, Çoklu-Ajan denetçileri, Prompt Caching, Semantic Cache ve Prompt Injection savunmaları); **bir aptala anlatır gibi (Explain Like I'm 5)** en yalın analojiler, mimari ASCII akış şemaları ve modern kurumsal kodlarla açıklanmıştır.

---

## 📚 10 Bölüm ve 60 Derslik Müfredat / 60-Lesson Curriculum

### 🧠 Bölüm 1: AI Engineer Rolü, LLM Anatomisi & MAANG Mülakat Çerçevesi
- **Ders 01:** AI Engineer vs ML Engineer vs Data Scientist & MAANG Mülakat Beklentileri
- **Ders 02:** LLM'ler Nasıl Düşünür? Next-Token Prediction, BPE Tokenization & Attention
- **Ders 03:** Hiperparametreler: Temperature, Top-P, Top-K, Presence & Frequency Penalty
- **Ders 04:** Prompt Mühendisliği: Zero-Shot, Few-Shot, Chain-of-Thought (CoT) & ReAct
- **Ders 05:** Token Ekonomisi: Token Sayımı, Maliyet Hesaplama, Rate Limits (TPM/RPM)
- **Ders 06:** İlk OpenAI Entegrasyonu: Java 25, Spring AI & LangChain4j Kurulumu

### 💬 Bölüm 2: Chat Modelleri, İstem Yönetimi & Yapılandırılmış Çıktılar
- **Ders 07:** Spring AI `ChatClient` Fluent API & Dinamik Model Konfigürasyonu
- **Ders 08:** LangChain4j `AiServices` Deklaratif Arayüzü & OpenAI Entegrasyonu
- **Ders 09:** PromptTemplates, Sistem Mesajları & Çoklu Rol (System/User/Assistant) Mimarisi
- **Ders 10:** Yapılandırılmış Çıktılar (Structured Outputs): JSON Schema & Java Records Garantisi
- **Ders 11:** Reaktif Akış (Streaming): Server-Sent Events (SSE), Flux & Düşük TTFT
- **Ders 12:** Çok Modlu (Multimodal) Modeller: GPT-4o Vision ile Görsel & Belge Analizi

### 📐 Bölüm 3: Vektörler, Embedding'ler ve Vektör Veritabanları
- **Ders 13:** Embedding Nedir? Metinlerin Çok Boyutlu Matematiksel Haritası
- **Ders 14:** Vektör Benzerlik Metrikleri: Cosine Similarity vs Dot Product vs Euclidean
- **Ders 15:** Vektör İndeksleme Mimarileri: Flat Index vs IVF vs HNSW (Graf Tabanlı Arama)
- **Ders 16:** Vektör Veritabanı Seçim Matrisi: pgvector vs Pinecone vs Qdrant vs Milvus
- **Ders 17:** Spring AI ile `VectorStore` (pgvector) Entegrasyonu ve Metadata Filtreleme
- **Ders 18:** LangChain4j `EmbeddingStore` ile Bellek-içi ve Dağıtık Vektör Arama

### 🔍 Bölüm 4: Retrieval-Augmented Generation (RAG) Temelleri
- **Ders 19:** RAG Nedir? Halüsinasyonu Önleyen Bilgi Besleme Mimarisi
- **Ders 20:** Metin Parçalama (Chunking) Stratejileri: Sabit Boyut, Sliding Window & Semantik
- **Ders 21:** Doküman ETL & Yükleme Pipeline'ı: PDF, Markdown, DOCX & Apache Tika
- **Ders 22:** Metadata Filtreleme & Çok Kiracılı (Multi-Tenant) RAG Mimarisi
- **Ders 23:** Uçtan Uca RAG Pipeline: Spring AI `QuestionAnswerAdvisor` Mimarisi
- **Ders 24:** LangChain4j ile `ContentRetriever` ve Gelişmiş RAG Orkestrasyonu

### 🚀 Bölüm 5: İleri Düzey RAG & Değerlendirme (Advanced RAG & Evals)
- **Ders 25:** Hibrit Arama (Hybrid Search): Dense Vektör + BM25 Sparse & RRF (Reciprocal Rank Fusion)
- **Ders 26:** Yeniden Sıralama (Re-ranking): Cross-Encoder Modelleri ve Cohere Rerank
- **Ders 27:** Sorgu Dönüştürme (Query Transformation): Multi-Query, HyDE & Alt Sorgular
- **Ders 28:** Bağlam Sıkıştırma (Context Compression) ve "Lost in the Middle" Problemi
- **Ders 29:** RAG Değerlendirme Çerçevesi: RAG Triad (Context Relevance, Groundedness, Answer Relevance)
- **Ders 30:** Otomatik Test & CI/CD Doğrulama: Ragas Metrikleri ve LLM-as-a-Judge

### 🛠️ Bölüm 6: Araçlar (Tools) ve Fonksiyon Çağırma (Function Calling)
- **Ders 31:** Function Calling Mekanizması: LLM'e 'El ve Kol' Verme Prensipleri
- **Ders 32:** Spring AI ile `@Tool` Tanımlama ve Çoklu Fonksiyon Yönetimi
- **Ders 33:** LangChain4j ile `@Tool` ve `@P` Parametre Doğrulama Mimarisi
- **Ders 34:** Çok Adımlı Araç Kullanımı: Text-to-SQL ve REST API Entegrasyon Ajanı
- **Ders 35:** Araç Güvenliği: Tool Hijacking Koruması ve Human-in-the-Loop (HitL) Onayı
- **Ders 36:** Model Context Protocol (MCP): Antigravity & Anthropic Araç Standartları

### 🤖 Bölüm 7: AI Ajanları (Agents) ve Bellek Sistemleri
- **Ders 37:** LLM vs AI Agent: Otonom Karar Döngüsü (ReAct Pattern)
- **Ders 38:** Bellek (Memory) Mimarileri: Kısa Vadeli (ChatMemory) vs Uzun Vadeli Vektör Bellek
- **Ders 39:** Planlama Stratejileri: Plan-and-Solve, Reflexion ve Kendi Kendini Düzeltme
- **Ders 40:** Çoklu-Ajan Sistemleri (Multi-Agent): Supervisor, Router ve İşbirlikçi Ajanlar
- **Ders 41:** LangChain4j ile Durumsal (Stateful) Ajan ve Checkpointing Mimarisi
- **Ders 42:** Spring AI ile Dağıtık ve Asenkron Ajan İş Akışları Tasarlamak

### ⚡ Bölüm 8: Performans, Maliyet & Model Optimizasyonu
- **Ders 43:** Prompt Caching & Semantic Cache: Redis ile LLM İsteklerini Hızlandırma
- **Ders 44:** Dinamik Model Yönlendirme (Model Routing): GPT-4o vs GPT-4o-mini
- **Ders 45:** Gecikme (Latency) Mühendisliği: TTFT Düşürme, Paralel Çağrılar & Speculative Decoding
- **Ders 46:** RAG vs Fine-Tuning: Karar Matrisi ve Mimari Takaslar (Trade-offs)
- **Ders 47:** OpenAI Fine-Tuning API: Veri Hazırlama (JSONL), Eğitim ve Değerlendirme
- **Ders 48:** Token Bütçeleme (Token Budgeting) ve Pencere Sınırı Yönetimi

### 🏭 Bölüm 9: Gerçek Dünya Üretim Mimarileri (Case Studies)
- **Ders 49:** Vaka 1: Milyon Kullanıcılı Kurumsal Müşteri Destek Ajanı
- **Ders 50:** Vaka 2: Kod Asistanı & Dokümantasyon Ajanı (Copilot Klonu & AST Parsing)
- **Ders 51:** Vaka 3: Kurumsal Bilgi Arama Motoru (Glean / Perplexity Klonu + Alıntılar)
- **Ders 52:** Vaka 4: Çok Modlu E-Ticaret Öneri Ajanı (Görsel Arama + Kullanıcı Geçmişi)
- **Ders 53:** Vaka 5: Finansal Rapor Analizi & Özetleme (Chunking, Map-Reduce & Guard)
- **Ders 54:** Vaka 6: Gerçek Zamanlı WebRTC Sesli Asistan (OpenAI Realtime API Mimarisi)

### 🛡️ Bölüm 10: Güvenlik, Gözlemlenebilirlik & MAANG Mülakat Başarısı
- **Ders 55:** LLM Güvenlik Açıkları: Prompt Injection, Jailbreak & Llama-Guard Koruması
- **Ders 56:** Çıktı Güvenliği (Output Guardrails), PII Maskeleme & Zararlı İçerik Filtresi
- **Ders 57:** LLM Gözlemlenebilirliği (Observability): Langfuse, OpenTelemetry & Tracing
- **Ders 58:** 45 Dakikalık MAANG AI Mülakatını Yönetme: Zaman Paylaşımı ve Beyaz Tahta
- **Ders 59:** Gecikme vs Kalite vs Maliyet Üçlemi (The Trilemma): Mülakatta Savunma
- **Ders 60:** Staff+ AI Engineer Rubriği: Teknik Liderlik, Mimarinin Savunulması ve Özet

---

## 📦 Çıktılar ve İndirilebilir PDF'ler

Proje derleme komutu ile otomatik olarak **71 adet yayın kalitesinde PDF** üretilir:
1. **Master Mega-Kitap (`output/book/AI_Engineer_MAANG_ELI5.pdf`)**: 252 Sayfa, Tüm 60 Ders, Renkli Bloklar, Ön Kapak, İçindekiler ve Önsöz.
2. **10 Bölüm Paketi (`output/modules/`)**: Her biri 6 dersten oluşan 10 adet tematik PDF.
3. **60 Tekil Ders PDF'i (`output/individual/`)**: Her ders için bağımsız hazırlanmış 60 PDF.

### Yeniden Derlemek İçin:
```bash
# Tüm 71 PDF'i derle
python3 build_all.py --all

# Sadece master kitabı derle
python3 build_all.py --book

# Sadece bölüm paketlerini derle
python3 build_all.py --modules
```

---

## 🌐 İnteraktif Web Companion Reader

Müfredatı tarayıcınızda canlı arama, anında kod kopyalama ve çift dilli görünümle incelemek için:

1. **Doğrudan Açma (Offline Destekli):**
   `web/index.html` dosyasını herhangi bir tarayıcıda çift tıklayarak açabilirsiniz (file:// protokolü tam desteklenir).

2. **Yerel Sunucu ile Çalıştırma:**
   ```bash
   python3 -m http.server 4596
   # Tarayıcınızda http://localhost:4596/web/ adresine gidin.
   ```

---

## 💻 Çalıştırılabilir Java 25 Örnekleri (`examples/`)

```bash
# 1. Semantic Cache Simülasyonu (Sub-millisecond Vector Lookup)
java examples/SemanticCacheDemo.java

# 2. Reciprocal Rank Fusion (RRF Hybrid Search Fusing Dense + Sparse BM25)
java examples/ReciprocalRankFusionDemo.java

# 3. Autonomous ReAct Agent Governor with Circuit Breaker
java examples/ReActAgentGovernor.java

# 4. Enterprise PII Redaction & API Key Guardrail
java examples/PiiRedactionGuard.java
```

---

## ⚖️ Lisans

Bu proje MIT lisansı ile lisanslanmıştır. Eğitim ve mülakat hazırlığı amacıyla serbestçe kullanılabilir, genişletilebilir ve paylaşılabilir.
