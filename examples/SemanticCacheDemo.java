// Java 25 LTS: Semantic Cache for LLM Query Acceleration & Token Cost Reduction
// Author: MAANG AI Engineering Guild

import java.util.*;

public class SemanticCacheDemo {

    public record CachedEntry(String userQuery, float[] queryEmbedding, String llmResponse, long cachedAtEpoch) {}

    public static class SemanticCache {
        private final List<CachedEntry> cacheStore = new ArrayList<>();
        private final double similarityThreshold;

        public SemanticCache(double similarityThreshold) {
            this.similarityThreshold = similarityThreshold;
        }

        public void put(String query, float[] embedding, String response) {
            cacheStore.add(new CachedEntry(query, embedding, response, System.currentTimeMillis()));
        }

        public Optional<CachedEntry> lookup(float[] incomingEmbedding) {
            CachedEntry bestMatch = null;
            double bestScore = -1.0;

            for (CachedEntry entry : cacheStore) {
                double score = cosineSimilarity(entry.queryEmbedding(), incomingEmbedding);
                if (score > bestScore && score >= similarityThreshold) {
                    bestScore = score;
                    bestMatch = entry;
                }
            }
            return Optional.ofNullable(bestMatch);
        }

        private double cosineSimilarity(float[] vA, float[] vB) {
            double dot = 0.0, normA = 0.0, normB = 0.0;
            for (int i = 0; i < vA.length; i++) {
                dot += vA[i] * vB[i];
                normA += vA[i] * vA[i];
                normB += vB[i] * vB[i];
            }
            if (normA == 0.0 || normB == 0.0) return 0.0;
            return dot / (Math.sqrt(normA) * Math.sqrt(normB));
        }
    }

    public static void main(String[] args) {
        System.out.println("=== MAANG AI Engineer: Semantic Cache Simulation (Java 25) ===");
        var cache = new SemanticCache(0.95);

        // Pre-fill cache with a previously answered expensive LLM query
        float[] baseEmbedding = {0.85f, 0.40f, -0.15f, 0.30f};
        cache.put(
            "Java 25 ile Virtual Threads nasıl kullanılır?",
            baseEmbedding,
            "Java 25'te Virtual Threads: Thread.ofVirtual().start(() -> { ... }); ile başlatılır."
        );
        System.out.println("✔ Cache Store'a 1 adet pahalı GPT-4o yanıtı kaydedildi.");

        // Simulate incoming query #1: Semantically nearly identical (paraphrased)
        float[] query1Embedding = {0.84f, 0.41f, -0.14f, 0.31f}; // Cosine similarity ~ 0.999
        System.out.println("\n[Sorgu 1]: 'Java 25 sanal thread ornegi verir misin?'");
        long start = System.nanoTime();
        var hit1 = cache.lookup(query1Embedding);
        long elapsedMicros = (System.nanoTime() - start) / 1000;

        hit1.ifPresentOrElse(
            entry -> System.out.printf("  ⚡ SEMANTIC CACHE HIT! (%d µs) -> Yanıt: %s%n", elapsedMicros, entry.llmResponse()),
            () -> System.out.println("  ❌ CACHE MISS -> OpenAI API'ye istek gönderiliyor...")
        );

        // Simulate incoming query #2: Unrelated topic
        float[] query2Embedding = {-0.60f, 0.70f, 0.20f, -0.10f}; // Completely different vector
        System.out.println("\n[Sorgu 2]: 'Kuantum dolanıklığı nedir?'");
        var hit2 = cache.lookup(query2Embedding);
        hit2.ifPresentOrElse(
            entry -> System.out.printf("  ⚡ SEMANTIC CACHE HIT! -> Yanıt: %s%n", entry.llmResponse()),
            () -> System.out.println("  ❌ CACHE MISS (Doğru Davranış) -> OpenAI API'ye 1500ms LLM çağrısı yönlendiriliyor.")
        );
    }
}
