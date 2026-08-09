import { evaluateBusinessGrowth } from "./modules/businesses/growth.engine.js";

async function runTest() {
  const businessIds = ["b-001", "b-002", "b-003"];
  console.log("=== ROUJLI SMART BUSINESS GROWTH ENGINE TEST ===");

  for (const id of businessIds) {
    const result = await evaluateBusinessGrowth(id);
    console.log(`\n--------------------------------------------------`);
    console.log(`BUSINESS ID: ${id}`);
    console.log(`GROWTH SCORE: ${result.scoreResult.growthScore}/100 (Monthly Change: ${result.scoreResult.monthlyGrowth} pts)`);
    console.log(`SCORE BREAKDOWN:`);
    console.dir(result.scoreResult.breakdown);
    console.log(`\nRECOMMENDATIONS (${result.recommendations.length}):`);
    result.recommendations.forEach((r, idx) => {
      console.log(` ${idx + 1}. [${r.relatedMetric}] ${r.recommendation}`);
      console.log(`    Problem: ${r.problem}`);
      console.log(`    Impact: ${r.expectedImpact}`);
    });
    console.log(`\nACTIONABLE TASKS (${result.tasks.length}):`);
    result.tasks.forEach((t, idx) => {
      console.log(` ${idx + 1}. [${t.completed ? "COMPLETED" : "PENDING"}] ${t.title} (+${t.points} pts)`);
    });
    console.log(`\nMATCHED OPPORTUNITIES (${result.opportunities.length}):`);
    result.opportunities.forEach((o, idx) => {
      console.log(` ${idx + 1}. [${o.type}] ${o.title}: ${o.matchReason}`);
    });
  }
}

runTest().catch(console.error);
