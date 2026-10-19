#import "/template.typ": *

#show: doc => setup_book(
  title: "Aptala Anlatır Gibi MAANG AI Mühendisliği El Kitabı",
  author: "Antigravity & MAANG AI Engineering Guild",
  doc
)

#book_front_cover()

#pagebreak()
#v(20pt)
#align(center)[
  #text(size: 20pt, weight: "bold", fill: rgb("0f172a"))[Önsöz ve Başlarken / Preface & Getting Started]
]
#v(16pt)

#grid(
  columns: (1fr, 1fr),
  gutter: 20pt,
  [
    == 🇹🇷 Bu Eğitim Hakkında
    Bu kitap; Meta, Amazon, Apple, Netflix, Google (MAANG) ve benzeri dünya devi teknoloji şirketlerinin *AI Engineer / Staff AI Systems Engineer* mülakatlarına hazırlanan yazılım mühendisleri ve mimarlar için özel olarak hazırlanmıştır.

    Artık devasa temel modeller (Foundation Models) OpenAI, Anthropic ve Google tarafından eğitilmektedir. Bir AI Engineer'ın görevi sıfırdan trilyon parametreli model eğitmek değil; bu olasılıksal (probabilistic) LLM güçlerini *deterministik, güvenli, ultra düşük gecikmeli ve kurumsal düzeyde çalışan sistemlere* dönüştürmektir.

    Bu 60 derslik kapsamlı müfredatta; *Spring AI*, *LangChain4j*, *OpenAI API* ve modern *Java 25* (Compact main, IO, Records, Virtual Threads) kullanarak;
    - Token ekonomisi, BPE ve Attention mekanizmasını,
    - Yapılandırılmış JSON çıktılarını ve SSE streaming akışlarını,
    - pgvector, HNSW, Dense + BM25 Sparse Hibrit Arama ve Cohere Reranking mimarilerini,
    - ReAct döngüleri, Çoklu-Ajan denetçileri (Multi-Agent Supervisor) ve MCP protokolünü,
    - Prompt Caching, Semantic Cache, Model Routing ve RAG Triad değerlendirme metriklerini,
    - Prompt Injection, Jailbreak korumaları ve 45 dakikalık MAANG mülakat sunum taktiklerini
    *bir aptala anlatır gibi* en yalın analojiler, mimari ASCII akış şemaları ve çalışan kurumsal kodlarla inceleyeceksiniz.
  ],
  [
    == 🇬🇧 About This Masterclass
    This masterclass is engineered for software engineers, enterprise architects, and technical leaders targeting Senior and Staff AI Engineer positions at Tier-1 tech giants (MAANG / FAANG).

    Foundation models are built by research labs, but the high-impact value is captured by AI Engineers who can orchestrate these probabilistic reasoning engines into resilient, low-latency, and deterministic production software.

    Across 60 deep-dive lessons organized into 10 structured modules, and powered by *Java 25*, *Spring AI*, *LangChain4j*, and *OpenAI*, you will master:
    - Token economics, BPE tokenization, and temperature/sampling mechanics,
    - Fluent ChatClient orchestration and type-safe structured JSON schemas,
    - High-scale vector search, pgvector, HNSW indexing, and Hybrid Reciprocal Rank Fusion,
    - Advanced RAG, Context Compression, and automated RAG Triad evaluation,
    - Tool function calling, Human-in-the-Loop gates, and Model Context Protocol (MCP),
    - Autonomous ReAct loops, multi-agent supervisors, and stateful memory,
    - Prompt caching, dynamic model routing, and TTFT latency engineering,
    - Prompt injection defenses, PII redaction, and 45-minute whiteboard mastery.
  ]
)

#v(20pt)
#line(length: 100%, stroke: 0.8pt + rgb("e2e8f0"))
#v(10pt)

#outline(
  title: [İçindekiler / Table of Contents],
  depth: 2,
  indent: auto
)

#pagebreak()

#module_cover(
  1,
  "AI Engineer Rolü, LLM Anatomisi & MAANG Mülakat Çerçevesi",
  "The AI Engineer Role, LLM Anatomy & The MAANG Interview Framework",
  "AI Engineer rolünün sınırları, LLM çalışma prensibi (Next-Token Prediction, Tokenization, Attention), hiperparametreler, prompt stratejileri ve Spring AI/LangChain4j ile ilk OpenAI entegrasyonu.",
  "Defining the AI Engineer role vs MLE/DS, internal mechanics of LLMs (Next-Token Prediction, BPE Tokenization, Attention), hyperparameters, prompting paradigms, and the first Java 25 OpenAI setup."
)

#include "/content/module_01_fundamentals/lesson_01.typ"
#v(14pt)

#include "/content/module_01_fundamentals/lesson_02.typ"
#v(14pt)

#include "/content/module_01_fundamentals/lesson_03.typ"
#v(14pt)

#include "/content/module_01_fundamentals/lesson_04.typ"
#v(14pt)

#include "/content/module_01_fundamentals/lesson_05.typ"
#v(14pt)

#include "/content/module_01_fundamentals/lesson_06.typ"
#v(14pt)


#module_cover(
  2,
  "Spring AI & LangChain4j Temel Yapı Taşları ve Chat Modelleri",
  "Core Foundations: Spring AI, LangChain4j & Modern Chat Models",
  "Spring AI ChatClient fluent API, LangChain4j AiServices deklaratif modelleri, prompt şablonları, yapılandırılmış çıktılar (Structured Outputs), streaming token akışı ve çok modlu (Multimodal) görsel analiz.",
  "Spring AI ChatClient fluent builder, LangChain4j declarative AiServices, prompt templates, structured JSON outputs, streaming token fluxes, and multimodal vision analysis with GPT-4o."
)

#include "/content/module_02_chat_models/lesson_07.typ"
#v(14pt)

#include "/content/module_02_chat_models/lesson_08.typ"
#v(14pt)

#include "/content/module_02_chat_models/lesson_09.typ"
#v(14pt)

#include "/content/module_02_chat_models/lesson_10.typ"
#v(14pt)

#include "/content/module_02_chat_models/lesson_11.typ"
#v(14pt)

#include "/content/module_02_chat_models/lesson_12.typ"
#v(14pt)


#module_cover(
  3,
  "Vektörler, Embedding'ler ve Vektör Veritabanları",
  "Vectors, Embeddings & Vector Database Architecture",
  "Embedding modelleri, metinlerin yüksek boyutlu uzayda haritalanması, Cosine Similarity ve Dot Product metrikleri, HNSW graf indeksleme, pgvector ve kurumsal vektör veritabanı seçimi.",
  "Embedding models, dense high-dimensional semantic spaces, Cosine Similarity vs Dot Product, HNSW graph indexing algorithms, pgvector, and enterprise vector database trade-offs."
)

#include "/content/module_03_vectors_embeddings/lesson_13.typ"
#v(14pt)

#include "/content/module_03_vectors_embeddings/lesson_14.typ"
#v(14pt)

#include "/content/module_03_vectors_embeddings/lesson_15.typ"
#v(14pt)

#include "/content/module_03_vectors_embeddings/lesson_16.typ"
#v(14pt)

#include "/content/module_03_vectors_embeddings/lesson_17.typ"
#v(14pt)

#include "/content/module_03_vectors_embeddings/lesson_18.typ"
#v(14pt)


#module_cover(
  4,
  "Üretim Seviyesinde RAG: Temeller, Chunking & ETL",
  "Production RAG Core: Fundamentals, Chunking & Ingestion Pipelines",
  "Retrieval-Augmented Generation (RAG) anatomisi, chunking stratejileri (Fixed-size, Sliding Window, Semantic), ETL doküman ayrıştırma, metadata filtreleme, Spring AI ve LangChain4j RAG pipeline'ları.",
  "Anatomy of production RAG, document chunking algorithms (Fixed-size, Sliding Window, Semantic), ETL parsers, metadata enrichment, and end-to-end Spring AI & LangChain4j ingestion pipelines."
)

#include "/content/module_04_rag_core/lesson_19.typ"
#v(14pt)

#include "/content/module_04_rag_core/lesson_20.typ"
#v(14pt)

#include "/content/module_04_rag_core/lesson_21.typ"
#v(14pt)

#include "/content/module_04_rag_core/lesson_22.typ"
#v(14pt)

#include "/content/module_04_rag_core/lesson_23.typ"
#v(14pt)

#include "/content/module_04_rag_core/lesson_24.typ"
#v(14pt)


#module_cover(
  5,
  "İleri Düzey RAG (Advanced RAG) & Bilgi Getirme Optimizasyonu",
  "Advanced RAG & Information Retrieval Optimization",
  "Hibrit Arama (Dense Vector + Sparse BM25) ve Reciprocal Rank Fusion (RRF), Cross-Encoder Re-ranking (Cohere), Sorgu Dönüşümü (HyDE & Multi-Query), Lost in the Middle problemi ve RAG Triad (RAGAS) değerlendirme metrikleri.",
  "Hybrid Search (Dense + Sparse BM25), Reciprocal Rank Fusion (RRF), Cross-Encoder Re-ranking, Query Transformation (HyDE & Multi-Query), Context Compression, and automated RAG Triad (RAGAS) evaluation frameworks."
)

#include "/content/module_05_advanced_rag/lesson_25.typ"
#v(14pt)

#include "/content/module_05_advanced_rag/lesson_26.typ"
#v(14pt)

#include "/content/module_05_advanced_rag/lesson_27.typ"
#v(14pt)

#include "/content/module_05_advanced_rag/lesson_28.typ"
#v(14pt)

#include "/content/module_05_advanced_rag/lesson_29.typ"
#v(14pt)

#include "/content/module_05_advanced_rag/lesson_30.typ"
#v(14pt)


#module_cover(
  6,
  "Function Calling, Tool Use ve API Entegrasyonu",
  "Function Calling, Tool Integration & Agent Tooling Protocols",
  "Function Calling temelleri, Spring AI \@Tool ve FunctionCallback, LangChain4j \@Tool açıklamaları, çok adımlı SQL ajanları, Tool Hijacking güvenlik önlemleri, Human-in-the-Loop ve Model Context Protocol (MCP).",
  "Mechanics of Function Calling, Spring AI \@Tool definitions, LangChain4j dynamic parameter extraction, multi-step database agents, Tool Hijacking defense, Human-in-the-Loop approvals, and Model Context Protocol (MCP)."
)

#include "/content/module_06_tools_function_calling/lesson_31.typ"
#v(14pt)

#include "/content/module_06_tools_function_calling/lesson_32.typ"
#v(14pt)

#include "/content/module_06_tools_function_calling/lesson_33.typ"
#v(14pt)

#include "/content/module_06_tools_function_calling/lesson_34.typ"
#v(14pt)

#include "/content/module_06_tools_function_calling/lesson_35.typ"
#v(14pt)

#include "/content/module_06_tools_function_calling/lesson_36.typ"
#v(14pt)


#module_cover(
  7,
  "AI Ajanları (AI Agents), Otonom Akışlar ve Bellek Mimarisi",
  "AI Agents, Autonomous Loops & Conversational Memory Systems",
  "LLM vs AI Agent farkı, ReAct (Reasoning + Acting) döngüsü, kısa ve uzun vadeli bellek (ChatMemory vs Vector Memory), Plan-and-Solve, Reflexion, Çoklu Ajan (Multi-Agent Supervisor) ve LangChain4j durumsal ajan tasarımı.",
  "LLM vs AI Agent taxonomy, ReAct iterative loop, short/long-term memory architectures (Sliding Window ChatMemory vs Vector Memory), Plan-and-Solve, Reflexion self-correction, Multi-Agent Supervisor networks, and stateful orchestration in Java."
)

#include "/content/module_07_agents_memory/lesson_37.typ"
#v(14pt)

#include "/content/module_07_agents_memory/lesson_38.typ"
#v(14pt)

#include "/content/module_07_agents_memory/lesson_39.typ"
#v(14pt)

#include "/content/module_07_agents_memory/lesson_40.typ"
#v(14pt)

#include "/content/module_07_agents_memory/lesson_41.typ"
#v(14pt)

#include "/content/module_07_agents_memory/lesson_42.typ"
#v(14pt)


#module_cover(
  8,
  "LLM Performansı, Caching, Maliyet & Gecikme Optimizasyonu",
  "LLM Performance Engineering: Caching, Model Routing & Cost Optimization",
  "OpenAI Prompt Caching ve Redis Semantik Önbellek, Dinamik Model Yönlendirme (Routing), TTFT ve akış gecikmesi optimizasyonu, RAG vs Fine-Tuning karar matrisi, JSONL veri hazırlığı ve token bütçeleme.",
  "OpenAI native Prompt Caching, Redis Semantic Caching, dynamic model routing (GPT-4o vs mini), TTFT latency engineering, RAG vs Fine-Tuning trade-off matrix, JSONL tuning datasets, and token budgeting."
)

#include "/content/module_08_perf_costs_eval/lesson_43.typ"
#v(14pt)

#include "/content/module_08_perf_costs_eval/lesson_44.typ"
#v(14pt)

#include "/content/module_08_perf_costs_eval/lesson_45.typ"
#v(14pt)

#include "/content/module_08_perf_costs_eval/lesson_46.typ"
#v(14pt)

#include "/content/module_08_perf_costs_eval/lesson_47.typ"
#v(14pt)

#include "/content/module_08_perf_costs_eval/lesson_48.typ"
#v(14pt)


#module_cover(
  9,
  "Üretim Düzeyinde AI Sistem Tasarımı (MAANG Vaka Çalışmaları)",
  "Production AI System Design: Flagship MAANG Case Studies",
  "Gerçek dünya AI Sistem Tasarımı: Kurumsal Müşteri Destek Ajanı, GitHub Copilot Kod Asistanı, Kurumsal Perplexity/Glean Arama Motoru, Çok Modlu E-Ticaret Öneri Sistemi, Finansal Map-Reduce Raporlama ve OpenAI Realtime Sesli Asistan.",
  "Real-world AI System Design case studies: Enterprise Customer Support Agent, GitHub Copilot Code Assistant, Enterprise Perplexity/Glean Search Engine, Multimodal E-Commerce Recommender, Financial Map-Reduce Summarizer, and OpenAI Realtime WebRTC Voice Assistant."
)

#include "/content/module_09_production_architectures/lesson_49.typ"
#v(14pt)

#include "/content/module_09_production_architectures/lesson_50.typ"
#v(14pt)

#include "/content/module_09_production_architectures/lesson_51.typ"
#v(14pt)

#include "/content/module_09_production_architectures/lesson_52.typ"
#v(14pt)

#include "/content/module_09_production_architectures/lesson_53.typ"
#v(14pt)

#include "/content/module_09_production_architectures/lesson_54.typ"
#v(14pt)


#module_cover(
  10,
  "AI Güvenliği, Gözlemlenebilirlik & MAANG Mülakat Ustalığı",
  "AI Security, Observability & The MAANG Interview Mastery Rubric",
  "Prompt Injection ve Jailbreak savunması, NeMo Guardrails, OpenTelemetry ve Langfuse ile LLM Tracing, MAANG 45 dakikalık mülakat zaman yönetimi, Latency vs Cost vs Quality trade-off savunusu ve Staff+ değerlendirme rubriği.",
  "Adversarial Prompt Injection defense, NeMo Guardrails, OpenTelemetry/Langfuse LLM observability, 45-minute whiteboard interview pacing, Latency vs Cost vs Quality trade-off defense, and Staff+ leadership rubrics."
)

#include "/content/module_10_security_interview/lesson_55.typ"
#v(14pt)

#include "/content/module_10_security_interview/lesson_56.typ"
#v(14pt)

#include "/content/module_10_security_interview/lesson_57.typ"
#v(14pt)

#include "/content/module_10_security_interview/lesson_58.typ"
#v(14pt)

#include "/content/module_10_security_interview/lesson_59.typ"
#v(14pt)

#include "/content/module_10_security_interview/lesson_60.typ"
#v(14pt)


#pagebreak()
#v(40pt)
#align(center)[
  #rect(fill: rgb("08111e"), radius: 10pt, inset: (x: 24pt, y: 32pt), width: 90%)[
    #text(size: 24pt, fill: rgb("34d399"), weight: "bold")[🎓 TEBRİKLER! / CONGRATULATIONS!]    #v(10pt)
    #text(size: 14pt, fill: white)[60 Derslik MAANG AI Engineer Yolculuğunu Başarıyla Tamamladınız!]    #v(6pt)
    #text(size: 11pt, fill: rgb("94a3b8"))[You have conquered all 60 lessons of the MAANG AI Engineer Masterclass!]    #v(20pt)
    #line(length: 60%, stroke: 1pt + rgb("10b981"))
    #v(15pt)
    #text(size: 10pt, fill: rgb("cbd5e1"))[
      Spring AI • LangChain4j • OpenAI GPT-4o • Hybrid RAG • ReAct Agents • Java 25
    ]
  ]
]
