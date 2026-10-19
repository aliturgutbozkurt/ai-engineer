// Java 25 LTS: Autonomous ReAct Agent Governor with Circuit Breaker
// Author: MAANG AI Engineering Guild

import java.util.*;

public class ReActAgentGovernor {

    public sealed interface AgentAction permits CallTool, FinishAnswer, EscalateToHuman {}
    public record CallTool(String toolName, Map<String, Object> arguments) implements AgentAction {}
    public record FinishAnswer(String finalOutput) implements AgentAction {}
    public record EscalateToHuman(String reason) implements AgentAction {}

    public static class AgentGovernor {
        private final int maxIterations;
        private final int maxTokenBudget;
        private int currentIteration = 0;
        private int cumulativeTokensUsed = 0;

        public AgentGovernor(int maxIterations, int maxTokenBudget) {
            this.maxIterations = maxIterations;
            this.maxTokenBudget = maxTokenBudget;
        }

        public AgentAction evaluateStep(AgentAction proposedAction, int stepTokens) {
            currentIteration++;
            cumulativeTokensUsed += stepTokens;

            System.out.printf("[Governor] Adım #%d | Harcanan Token: %d / %d bütçe%n", 
                currentIteration, cumulativeTokensUsed, maxTokenBudget);

            // Circuit Breaker 1: Infinite Loop Prevention
            if (currentIteration > maxIterations) {
                return new EscalateToHuman("CIRCUIT_BREAKER_TRIGGERED: Maksimum adım sınırı (" + maxIterations + ") aşıldı! Ajan döngüye girmiş olabilir.");
            }

            // Circuit Breaker 2: Token Budget Guard
            if (cumulativeTokensUsed > maxTokenBudget) {
                return new EscalateToHuman("BUDGET_EXCEEDED: Token bütçesi (" + maxTokenBudget + ") aşıldı! Fatura koruması devreye girdi.");
            }

            return proposedAction;
        }
    }

    public static void main(String[] args) {
        System.out.println("=== MAANG AI Engineer: ReAct Agent Governor & Safety Circuit Breaker ===");
        var governor = new AgentGovernor(3, 4000);

        // Simulation Step 1: Agent calls SQL Tool
        var action1 = governor.evaluateStep(new CallTool("queryDatabase", Map.of("sql", "SELECT balance FROM users WHERE id = 12;")), 800);
        System.out.println("-> Karar 1: " + action1);

        // Simulation Step 2: Agent calls Calculator Tool
        var action2 = governor.evaluateStep(new CallTool("calculateTax", Map.of("amount", 4500.0)), 1200);
        System.out.println("-> Karar 2: " + action2);

        // Simulation Step 3: Agent keeps calling tools repetitively
        var action3 = governor.evaluateStep(new CallTool("queryDatabase", Map.of("sql", "SELECT * FROM logs;")), 1500);
        System.out.println("-> Karar 3: " + action3);

        // Simulation Step 4: Step limit exceeded (Infinite loop prevented!)
        var action4 = governor.evaluateStep(new CallTool("queryDatabase", Map.of("sql", "SELECT 1;")), 600);
        System.out.println("-> Karar 4: " + action4);

        if (action4 instanceof EscalateToHuman escalation) {
            System.out.println("\n🚨 GÜVENLİK TETİKLENDİ: " + escalation.reason());
            System.out.println("   İşlem insan operatör (Human-in-the-Loop) ekranına yönlendirildi.");
        }
    }
}
