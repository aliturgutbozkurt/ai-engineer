// Java 25 LTS: Reciprocal Rank Fusion (RRF) for Hybrid Vector + BM25 Search
// Author: MAANG AI Engineering Guild

import java.util.*;

public class ReciprocalRankFusionDemo {

    public record Document(String id, String title) {}
    public record RankedResult(Document document, double rrfScore) {}

    private static final int K = 60; // Standard RRF smoothing constant

    public static List<RankedResult> fuse(
        List<Document> denseRankList, 
        List<Document> sparseRankList, 
        int topN
    ) {
        Map<String, Document> docRegistry = new HashMap<>();
        Map<String, Double> scoreMap = new HashMap<>();

        // 1. Process Dense Vector Rankings (1-indexed ranks)
        for (int i = 0; i < denseRankList.size(); i++) {
            Document doc = denseRankList.get(i);
            docRegistry.put(doc.id(), doc);
            int rank = i + 1;
            scoreMap.put(doc.id(), scoreMap.getOrDefault(doc.id(), 0.0) + (1.0 / (K + rank)));
        }

        // 2. Process Sparse BM25 Keyword Rankings (1-indexed ranks)
        for (int i = 0; i < sparseRankList.size(); i++) {
            Document doc = sparseRankList.get(i);
            docRegistry.put(doc.id(), doc);
            int rank = i + 1;
            scoreMap.put(doc.id(), scoreMap.getOrDefault(doc.id(), 0.0) + (1.0 / (K + rank)));
        }

        // 3. Sort by aggregated RRF score descending
        return scoreMap.entrySet().stream()
            .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
            .limit(topN)
            .map(e -> new RankedResult(docRegistry.get(e.getKey()), e.getValue()))
            .toList();
    }

    public static void main(String[] args) {
        System.out.println("=== MAANG AI Engineer: Hybrid Search RRF Demo (Java 25) ===");

        var docA = new Document("DOC-101", "PostgreSQL pgvector HNSW Kurulumu ve İndeksleme");
        var docB = new Document("DOC-102", "ERR_PG_4012 Bağlantı Havuzu Zaman Aşımı Hatası");
        var docC = new Document("DOC-103", "Spring Boot Veritabanı Connection Pool Ayarları");
        var docD = new Document("DOC-104", "Kubernetes Pod Resource Limits ve OOM Kills");

        // Dense Vector Engine: Excellent at broad semantic themes
        // Query: "Veritabanı bağlantı hatası nasıl çözülür?"
        var denseRanked = List.of(docC, docA, docB, docD);

        // Sparse BM25 Engine: Excellent at exact alphanumeric error strings
        var sparseRanked = List.of(docB, docC, docA);

        System.out.println("\n[Dense Vector Sıralaması]: 1.DOC-103, 2.DOC-101, 3.DOC-102, 4.DOC-104");
        System.out.println("[Sparse BM25 Sıralaması]:  1.DOC-102, 2.DOC-103, 3.DOC-101");

        var fused = fuse(denseRanked, sparseRanked, 3);

        System.out.println("\n--- Reciprocal Rank Fusion (RRF k=60) Birleşik Sıralama Sonucu ---");
        for (int i = 0; i < fused.size(); i++) {
            var r = fused.get(i);
            System.out.printf("#%d | Skor: %.5f | ID: %s | Başlık: %s%n",
                i + 1, r.rrfScore(), r.document().id(), r.document().title());
        }
    }
}
