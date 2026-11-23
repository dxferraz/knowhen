const test = require("node:test");
const assert = require("node:assert/strict");
const { generateYear, YEAR_RESPONSE_SCHEMA, buildYearPrompt } = require("../brasil-songs");
const {
  BudgetExceededError,
  resolvePrice,
  callCost,
  worstCaseCost,
  estimateInputTokens,
  attemptInputTokens,
  parseCallOptions,
  estimateRun,
  extractUsage,
  createUsageTracker,
  createAsk,
} = require("../openai-usage");

const SYSTEM = "Sistema de teste.";
const rangeNow = new Date(2026, 10, 22);
const closeTo = (actual, expected, message) => assert.ok(Math.abs(actual - expected) < 1e-9, `${message ?? ""} esperado ${expected}, veio ${actual}`);

test("resolvePrice conhece os três modelos e aceita o snapshot datado", () => {
  assert.deepEqual(resolvePrice("gpt-5.5-pro"), { input: 30, output: 180, reasoning: true });
  assert.deepEqual(resolvePrice("gpt-5.5"), { input: 5, output: 30, reasoning: true });
  assert.deepEqual(resolvePrice("gpt-4o-mini"), { input: 0.15, output: 0.6, reasoning: false });
  assert.equal(resolvePrice("gpt-5.5-pro-2026-04-23"), resolvePrice("gpt-5.5-pro"));
  assert.equal(resolvePrice("gpt-5.5-2026-04-23"), resolvePrice("gpt-5.5"));
});

test("resolvePrice recusa modelo fora da tabela, inclusive parecido com um da tabela", () => {
  for (const model of ["gpt-4o", "gpt-5.5-pro-mini", "gpt-5", "o3", "", undefined]) {
    assert.throws(() => resolvePrice(model), /fora da tabela de preços.*recusado/, String(model));
  }
});

test("callCost usa US$/1M tokens e o flex custa metade do default", () => {
  const tokens = { inputTokens: 1_000_000, outputTokens: 1_000_000 };
  closeTo(callCost({ model: "gpt-5.5-pro", tier: "default", ...tokens }), 210);
  closeTo(callCost({ model: "gpt-5.5-pro", tier: "flex", ...tokens }), 105);
  closeTo(callCost({ model: "gpt-5.5", tier: "default", ...tokens }), 35);
  closeTo(callCost({ model: "gpt-5.5", tier: "flex", ...tokens }), 17.5);
  closeTo(callCost({ model: "gpt-4o-mini", tier: "default", ...tokens }), 0.75);
  closeTo(callCost({ model: "gpt-4o-mini", tier: "flex", ...tokens }), 0.375);
});

test("callCost de uma chamada típica do gpt-5.5-pro em flex", () => {
  // 250 de entrada e 3000 de saída (raciocínio incluído): 250*15/1e6 + 3000*90/1e6
  closeTo(callCost({ model: "gpt-5.5-pro", tier: "flex", inputTokens: 250, outputTokens: 3000 }), 0.27375);
});

test("callCost recusa tier desconhecido", () => {
  assert.throws(() => callCost({ model: "gpt-5.5", tier: "priority", inputTokens: 1, outputTokens: 1 }), /--tier/);
});

test("worstCaseCost é a entrada estimada mais max_output_tokens inteiros", () => {
  closeTo(worstCaseCost({ model: "gpt-5.5-pro", tier: "flex", inputTokens: 1000, maxOutputTokens: 16000 }), 1000 * 15e-6 + 16000 * 90e-6);
});

test("estimateInputTokens arredonda para cima e superestima o português", () => {
  assert.equal(estimateInputTokens("abc", "def"), 2);
  assert.equal(estimateInputTokens("abcd"), 2);
  const first = attemptInputTokens({ prompt: buildYearPrompt(1995), system: SYSTEM, schema: YEAR_RESPONSE_SCHEMA });
  assert.ok(first >= 250, `a 1ª tentativa estima ${first}, abaixo dos ~250 tokens medidos`);
});

test("parseCallOptions aplica os padrões: flex, effort high e 16000 tokens de saída", () => {
  assert.deepEqual(parseCallOptions({ model: "gpt-5.5-pro" }), { model: "gpt-5.5-pro", tier: "flex", effort: "high", maxOutputTokens: 16000 });
  assert.deepEqual(parseCallOptions({}, { defaultModel: "gpt-5.5" }).model, "gpt-5.5");
});

test("parseCallOptions lê tier, effort, max-output-tokens e budget (strings da linha de comando)", () => {
  const parsed = parseCallOptions(
    { model: "gpt-5.5", tier: "default", effort: "low", "max-output-tokens": "8000", budget: "12.5" },
    { requireBudget: true },
  );
  assert.deepEqual(parsed, { model: "gpt-5.5", tier: "default", effort: "low", maxOutputTokens: 8000, budget: 12.5 });
});

test("parseCallOptions exige --budget quando pedido e aceita sem budget no estimate", () => {
  assert.throws(() => parseCallOptions({ model: "gpt-5.5" }, { requireBudget: true }), /--budget.*obrigatório/);
  assert.equal(parseCallOptions({ model: "gpt-5.5" }).budget, undefined);
});

test("parseCallOptions rejeita budget, max-output-tokens, tier, effort e modelo inválidos", () => {
  const base = { model: "gpt-5.5" };
  for (const budget of ["0", "-1", "abc", "", "1e3", "NaN", "Infinity"]) {
    assert.throws(() => parseCallOptions({ ...base, budget }), /--budget/, budget);
  }
  for (const value of ["0", "-5", "1.5", "abc", ""]) {
    assert.throws(() => parseCallOptions({ ...base, "max-output-tokens": value }), /--max-output-tokens/, value);
  }
  assert.throws(() => parseCallOptions({ ...base, tier: "priority" }), /--tier/);
  assert.throws(() => parseCallOptions({ ...base, effort: "extreme" }), /--effort/);
  assert.throws(() => parseCallOptions({ model: "gpt-9" }), /recusado/);
  assert.throws(() => parseCallOptions({}), /recusado/, "sem --model e sem padrão");
});

test("parseCallOptions não manda effort para modelo sem raciocínio", () => {
  assert.equal(parseCallOptions({ model: "gpt-4o-mini", effort: "high" }).effort, null);
});

const estimateInput = { system: SYSTEM, schema: YEAR_RESPONSE_SCHEMA, now: rangeNow };

test("estimateRun conta anos, chamadas (2 por ano) e o teto de custo sem rede", () => {
  const result = estimateRun({ from: "1930", to: "2023", model: "gpt-5.5-pro", tier: "flex", maxOutputTokens: 16000, ...estimateInput });
  assert.equal(result.years, 94);
  assert.equal(result.maxCalls, 188);
  const outputOnly = 188 * 16000 * 90e-6;
  assert.ok(result.maxCostUsd > outputOnly, "inclui a entrada");
  assert.ok(result.maxCostUsd < outputOnly * 1.05, "a entrada é pouco perto da saída");
});

test("estimateRun de um ano só e tier default dobra o preço", () => {
  const args = { from: "1990", to: "1990", model: "gpt-5.5", maxOutputTokens: 1000, ...estimateInput };
  const flex = estimateRun({ ...args, tier: "flex" });
  const full = estimateRun({ ...args, tier: "default" });
  assert.equal(flex.years, 1);
  assert.equal(flex.maxCalls, 2);
  closeTo(full.maxCostUsd, flex.maxCostUsd * 2);
});

test("estimateRun usa o intervalo padrão e valida --from/--to", () => {
  const result = estimateRun({ model: "gpt-4o-mini", tier: "flex", maxOutputTokens: 1000, ...estimateInput });
  assert.equal(result.years, 94);
  assert.throws(() => estimateRun({ from: "2000", to: "1990", model: "gpt-4o-mini", tier: "flex", maxOutputTokens: 1000, ...estimateInput }), /não pode ser maior/);
});

const trackerOf = (overrides = {}) =>
  createUsageTracker({ model: "gpt-5.5-pro", tier: "flex", maxOutputTokens: 16000, budget: 10, now: () => new Date("2026-11-23T12:00:00Z"), ...overrides });
const responseOf = ({ input = 250, output = 3000, reasoning = 2700, status = "completed", ...rest } = {}) => ({
  status,
  usage: { input_tokens: input, output_tokens: output, output_tokens_details: { reasoning_tokens: reasoning } },
  ...rest,
});

test("extractUsage lê os tokens e trata campo ausente como zero", () => {
  assert.deepEqual(extractUsage(responseOf()), { inputTokens: 250, outputTokens: 3000, reasoningTokens: 2700 });
  assert.deepEqual(extractUsage({}), { inputTokens: 0, outputTokens: 0, reasoningTokens: 0 });
  assert.deepEqual(extractUsage(undefined), { inputTokens: 0, outputTokens: 0, reasoningTokens: 0 });
});

test("o tracker soma o custo de cada chamada e loga ano, tentativa, tokens, custo e total", () => {
  const tracker = trackerOf();
  const first = tracker.record({ year: 1990, attempt: 1, response: responseOf() });
  const second = tracker.record({ year: 1990, attempt: 2, response: responseOf({ input: 400, output: 4000, reasoning: 3500 }) });
  assert.deepEqual(first, {
    at: "2026-11-23T12:00:00.000Z",
    year: 1990,
    attempt: 1,
    status: "completed",
    tier: "flex",
    inputTokens: 250,
    outputTokens: 3000,
    reasoningTokens: 2700,
    costUsd: first.costUsd,
    totalCostUsd: first.costUsd,
  });
  closeTo(first.costUsd, 0.27375);
  closeTo(second.costUsd, 400 * 15e-6 + 4000 * 90e-6);
  closeTo(second.totalCostUsd, first.costUsd + second.costUsd);
  closeTo(tracker.spent, second.totalCostUsd);
  assert.equal(tracker.calls.length, 2);
});

test("o raciocínio já está na saída: não é cobrado duas vezes", () => {
  const tracker = trackerOf();
  const entry = tracker.record({ year: 1990, attempt: 1, response: responseOf({ output: 3000, reasoning: 3000 }) });
  closeTo(entry.costUsd, 250 * 15e-6 + 3000 * 90e-6);
});

test("o tracker cobra no tier que a OpenAI diz ter usado, se vier na resposta", () => {
  const tracker = trackerOf();
  const entry = tracker.record({ year: 1990, attempt: 1, response: responseOf({ service_tier: "default" }) });
  assert.equal(entry.tier, "default");
  closeTo(entry.costUsd, 250 * 30e-6 + 3000 * 180e-6);
  assert.equal(tracker.record({ year: 1991, attempt: 1, response: responseOf({ service_tier: "scale" }) }).tier, "flex");
});

test("o guarda de orçamento deixa chamar enquanto gasto + pior caso couber (inclusive igual)", () => {
  const worst = worstCaseCost({ model: "gpt-5.5-pro", tier: "flex", inputTokens: 1000, maxOutputTokens: 16000 });
  trackerOf({ budget: worst }).assertWithinBudget(1000);
  trackerOf({ budget: worst * 2 }).assertWithinBudget(1000);
});

test("o guarda de orçamento para quando o pior caso estoura, sem gastar nada", () => {
  const worst = worstCaseCost({ model: "gpt-5.5-pro", tier: "flex", inputTokens: 1000, maxOutputTokens: 16000 });
  const tracker = trackerOf({ budget: worst - 0.001 });
  assert.throws(() => tracker.assertWithinBudget(1000), (error) => error instanceof BudgetExceededError && /Parando sem chamar/.test(error.message));
  assert.equal(tracker.spent, 0);
});

test("o guarda considera o gasto acumulado, não só a próxima chamada", () => {
  const tracker = trackerOf({ budget: 2 });
  tracker.assertWithinBudget(1000); // pior caso ~1,45: cabe
  tracker.record({ year: 1990, attempt: 1, response: responseOf({ output: 8000, reasoning: 8000 }) }); // ~0,72
  assert.throws(() => tracker.assertWithinBudget(1000), BudgetExceededError); // 0,72 + 1,45 > 2
});

test("toLog acumula as rodadas anteriores do arquivo e soma o total de todas", () => {
  const tracker = trackerOf();
  tracker.record({ year: 1990, attempt: 1, response: responseOf() });
  const previous = { allRunsCostUsd: 1, runs: [{ totalCostUsd: 1, calls: [] }] };
  const log = tracker.toLog(previous);
  assert.equal(log.runs.length, 2);
  assert.equal(log.runs[1].model, "gpt-5.5-pro");
  assert.equal(log.runs[1].budgetUsd, 10);
  assert.equal(log.runs[1].calls.length, 1);
  closeTo(log.allRunsCostUsd, 1 + tracker.spent);
  assert.equal(tracker.toLog().runs.length, 1, "sem arquivo anterior");
  assert.equal(tracker.toLog({ runs: "lixo" }).runs.length, 1, "arquivo anterior com formato inesperado");
});

const songsJson = (year, count) =>
  JSON.stringify({ songs: Array.from({ length: count }, (_, i) => ({ artist: `Artista ${i}`, songName: `Música ${i}`, releaseYear: year })) });
const clientOf = (...responses) => {
  const requests = [];
  return { requests, responses: { create: async (request) => (requests.push(request), responses[requests.length - 1]) } };
};
const askOf = (client, overrides = {}) => {
  const tracker = overrides.tracker ?? trackerOf();
  const entries = [];
  const ask = createAsk({
    client,
    tracker,
    model: "gpt-5.5-pro",
    tier: "flex",
    effort: "high",
    maxOutputTokens: 16000,
    system: SYSTEM,
    schema: YEAR_RESPONSE_SCHEMA,
    onCall: (entry) => entries.push(entry),
    ...overrides,
  });
  return { ask, tracker, entries };
};

test("createAsk chama a Responses API com json_schema strict, flex, effort e max_output_tokens, sem temperature", async () => {
  const client = clientOf(responseOf({ output_text: songsJson(1990, 3) }));
  const { ask, entries } = askOf(client);
  assert.equal(await ask("prompt do ano", 1, 1990), songsJson(1990, 3));
  assert.equal(client.requests.length, 1);
  const [request] = client.requests;
  assert.equal(request.model, "gpt-5.5-pro");
  assert.equal(request.instructions, SYSTEM);
  assert.equal(request.input, "prompt do ano");
  assert.deepEqual(request.text, { format: { type: "json_schema", ...YEAR_RESPONSE_SCHEMA } });
  assert.equal(request.text.format.strict, true);
  assert.equal(request.service_tier, "flex");
  assert.equal(request.max_output_tokens, 16000);
  assert.deepEqual(request.reasoning, { effort: "high" });
  assert.ok(!("temperature" in request));
  assert.ok(!("messages" in request) && !("response_format" in request), "nada da chat.completions");
  assert.equal(entries.length, 1);
  assert.equal(entries[0].year, 1990);
  assert.equal(entries[0].attempt, 1);
});

test("createAsk não manda reasoning para modelo sem raciocínio", async () => {
  const client = clientOf(responseOf({ output_text: "{}" }));
  await askOf(client, { model: "gpt-4o-mini", effort: null }).ask("p", 1, 1990);
  assert.ok(!("reasoning" in client.requests[0]));
});

test("resposta incomplete entra no custo e vira resposta vazia, sem derrubar o script", async () => {
  const client = clientOf(responseOf({ status: "incomplete", output: 16000, reasoning: 16000, incomplete_details: { reason: "max_output_tokens" }, output_text: '{"songs":[{"artist":"A' }));
  const { ask, tracker, entries } = askOf(client);
  assert.equal(await ask("p", 1, 1990), "");
  closeTo(tracker.spent, 250 * 15e-6 + 16000 * 90e-6);
  assert.equal(entries[0].status, "incomplete");
  assert.equal(entries[0].incompleteReason, "max_output_tokens");
  assert.equal(entries[0].reasoningTokens, 16000);
});

test("generateYear trata resposta incomplete como vazia: tenta de novo e, sem músicas, ignora o ano", async () => {
  const incomplete = responseOf({ status: "incomplete", incomplete_details: { reason: "max_output_tokens" }, output_text: "{" });
  const client = clientOf(incomplete, incomplete);
  const { ask, tracker } = askOf(client);
  assert.equal(await generateYear({ year: 1990, ask, seen: new Set() }), null);
  assert.equal(client.requests.length, 2);
  assert.equal(tracker.calls.length, 2, "as duas chamadas foram cobradas");
  assert.equal(tracker.calls[1].attempt, 2);
  assert.equal(tracker.calls[1].year, 1990);
});

test("generateYear aproveita a 2ª tentativa depois de uma 1ª incomplete", async () => {
  const client = clientOf(
    responseOf({ status: "incomplete", output_text: "{" }),
    responseOf({ output_text: songsJson(1990, 12) }),
  );
  const { ask } = askOf(client);
  assert.equal((await generateYear({ year: 1990, ask, seen: new Set() })).length, 12);
});

test("createAsk não chama a API quando o orçamento não comporta o pior caso", async () => {
  const client = clientOf(responseOf({ output_text: "{}" }));
  const { ask, tracker } = askOf(client, { tracker: trackerOf({ budget: 0.5 }) });
  await assert.rejects(ask("p", 1, 1990), BudgetExceededError);
  assert.equal(client.requests.length, 0);
  assert.equal(tracker.spent, 0);
});

test("o orçamento para a rodada no meio: mantém o que já gastou e não chama de novo", async () => {
  const client = clientOf(responseOf({ output: 16000, reasoning: 16000, output_text: songsJson(1990, 3) }), responseOf());
  const { ask, tracker } = askOf(client, { tracker: trackerOf({ budget: 2 }) });
  await ask("p", 1, 1990); // gasta ~1,44
  await assert.rejects(ask("p", 2, 1990), BudgetExceededError);
  assert.equal(client.requests.length, 1);
  closeTo(tracker.spent, 250 * 15e-6 + 16000 * 90e-6);
});

test("createAsk cobra a resposta failed e levanta erro", async () => {
  const client = clientOf(responseOf({ status: "failed", error: { message: "boom" } }));
  const { ask, tracker } = askOf(client);
  await assert.rejects(ask("p", 1, 1990), /boom/);
  assert.equal(tracker.calls.length, 1);
});

test("createAsk deixa o erro de rede subir sem gravar custo", async () => {
  const client = { responses: { create: async () => { throw new Error("429"); } } };
  const { ask, tracker } = askOf(client);
  await assert.rejects(ask("p", 1, 1990), /429/);
  assert.equal(tracker.calls.length, 0);
});
