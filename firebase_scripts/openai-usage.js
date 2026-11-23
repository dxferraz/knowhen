// Custo e orçamento das chamadas à OpenAI no preenchimento de `brasil-songs`, separados do script para serem
// testados sem rede. Só usa módulos nativos do Node.

const { buildYearPrompt, SONGS_PER_YEAR, MAX_ATTEMPTS_PER_YEAR, parseYearRange } = require("./brasil-songs");

// US$ por 1M de tokens no tier `default`; o `flex` custa metade. `reasoning` diz se o modelo aceita `reasoning.effort`.
// Modelo fora desta tabela é recusado: sem preço não há como limitar o gasto.
const PRICES_USD_PER_MILLION = {
  "gpt-5.5-pro": { input: 30, output: 180, reasoning: true },
  "gpt-5.5": { input: 5, output: 30, reasoning: true },
  "gpt-4o-mini": { input: 0.15, output: 0.6, reasoning: false },
};
const FLEX_FACTOR = 0.5;

const TIERS = ["flex", "default"];
const EFFORTS = ["none", "minimal", "low", "medium", "high", "xhigh", "max"];
const DEFAULT_TIER = "flex";
const DEFAULT_EFFORT = "high";
const DEFAULT_MAX_OUTPUT_TOKENS = 16000;
// Português gasta ~4 caracteres por token; 3 superestima de propósito, para o pior caso nunca ficar abaixo do real.
const CHARS_PER_TOKEN = 3;

/** Acha o preço do modelo, aceitando o snapshot datado (`gpt-5.5-pro-2026-04-23` usa o preço de `gpt-5.5-pro`). */
function resolvePrice(model) {
  const base = String(model).replace(/-\d{4}-\d{2}-\d{2}$/, "");
  const price = PRICES_USD_PER_MILLION[base];
  if (!price) {
    throw new Error(`Modelo "${model}" fora da tabela de preços (${Object.keys(PRICES_USD_PER_MILLION).join(", ")}); recusado.`);
  }
  return price;
}

function tierFactor(tier) {
  if (!TIERS.includes(tier)) throw new Error(`--tier deve ser ${TIERS.join(" ou ")}, recebi "${tier}".`);
  return tier === "flex" ? FLEX_FACTOR : 1;
}

/** Preço em US$ por token (entrada e saída) para o modelo e o tier. */
function pricePerToken(model, tier) {
  const price = resolvePrice(model);
  const factor = tierFactor(tier) / 1e6;
  return { input: price.input * factor, output: price.output * factor };
}

/** Custo de uma chamada. `outputTokens` já inclui os de raciocínio (a OpenAI cobra tudo como saída). */
function callCost({ model, tier, inputTokens, outputTokens }) {
  const price = pricePerToken(model, tier);
  return inputTokens * price.input + outputTokens * price.output;
}

/** Pior caso de uma chamada: a entrada estimada mais `maxOutputTokens` inteiros de saída. */
function worstCaseCost({ model, tier, inputTokens, maxOutputTokens }) {
  return callCost({ model, tier, inputTokens, outputTokens: maxOutputTokens });
}

function estimateInputTokens(...texts) {
  return Math.ceil(texts.reduce((sum, text) => sum + text.length, 0) / CHARS_PER_TOKEN);
}

function parsePositive(value, name, { integer = false } = {}) {
  const number = typeof value === "number" ? value : /^\d+(\.\d+)?$/.test(String(value).trim()) ? Number(value) : NaN;
  if (!Number.isFinite(number) || number <= 0 || (integer && !Number.isInteger(number))) {
    throw new Error(`--${name} deve ser um número ${integer ? "inteiro " : ""}maior que zero, recebi "${value}".`);
  }
  return number;
}

/**
 * Valida as opções da chamada (`--model`, `--tier`, `--effort`, `--max-output-tokens`, e `--budget` se
 * `requireBudget`) e aplica os padrões. Falha antes de qualquer rede.
 */
function parseCallOptions(options, { defaultModel, requireBudget = false } = {}) {
  const model = options.model ?? defaultModel;
  const price = resolvePrice(model);
  const tier = options.tier ?? DEFAULT_TIER;
  tierFactor(tier);
  const effort = options.effort ?? DEFAULT_EFFORT;
  if (!EFFORTS.includes(effort)) throw new Error(`--effort deve ser um de ${EFFORTS.join(", ")}, recebi "${effort}".`);
  const maxOutputTokens = parsePositive(options["max-output-tokens"] ?? DEFAULT_MAX_OUTPUT_TOKENS, "max-output-tokens", { integer: true });
  const parsed = { model, tier, effort: price.reasoning ? effort : null, maxOutputTokens };
  if (requireBudget && options.budget === undefined) {
    throw new Error("--budget <US$> é obrigatório no generate: é o teto de gasto da rodada. Use `estimate` para ver o teto de cada faixa de anos.");
  }
  if (options.budget !== undefined) parsed.budget = parsePositive(options.budget, "budget");
  return parsed;
}

/** Tamanho (em tokens estimados) da entrada de uma tentativa, para o guarda de orçamento e o `estimate`. */
function attemptInputTokens({ prompt, system, schema }) {
  return estimateInputTokens(system, prompt, JSON.stringify(schema));
}

/**
 * Sem rede: quantos anos, o máximo de chamadas (MAX_ATTEMPTS_PER_YEAR por ano) e o teto de custo, supondo
 * `maxOutputTokens` inteiros em toda chamada. Na 2ª tentativa a entrada inclui a lista do que já veio, que no
 * teto é de SONGS_PER_YEAR músicas com os campos no tamanho máximo (120 caracteres).
 */
function estimateRun({ from, to, model, tier, maxOutputTokens, system, schema, now }) {
  const range = parseYearRange(from, to, now);
  const years = range.to - range.from + 1;
  const longSong = { artist: "x".repeat(120), songName: "x".repeat(120) };
  const asked = Array.from({ length: SONGS_PER_YEAR }, () => longSong);
  const perYear = [buildYearPrompt(range.from), buildYearPrompt(range.from, asked)].map((prompt) =>
    worstCaseCost({ model, tier, maxOutputTokens, inputTokens: attemptInputTokens({ prompt, system, schema }) }),
  );
  return {
    years,
    maxCalls: years * MAX_ATTEMPTS_PER_YEAR,
    maxCostUsd: years * perYear.reduce((sum, cost) => sum + cost, 0),
  };
}

function formatUsd(value) {
  return `US$ ${value.toFixed(4)}`;
}

class BudgetExceededError extends Error {
  constructor({ spent, worstCase, budget }) {
    super(
      `Orçamento de ${formatUsd(budget)} não comporta a próxima chamada: gasto ${formatUsd(spent)} + pior caso ${formatUsd(worstCase)} = ${formatUsd(spent + worstCase)}. Parando sem chamar.`,
    );
    this.name = "BudgetExceededError";
  }
}

/** Lê os tokens de uma resposta da Responses API; campo ausente conta como zero. */
function extractUsage(response) {
  const usage = response?.usage ?? {};
  return {
    inputTokens: usage.input_tokens ?? 0,
    outputTokens: usage.output_tokens ?? 0,
    reasoningTokens: usage.output_tokens_details?.reasoning_tokens ?? 0,
  };
}

/**
 * Contabilidade de uma rodada: o gasto acumulado, o guarda de orçamento e o log de uso (uma entrada por chamada).
 * O orçamento vale por rodada; o log em disco acumula as rodadas (ver `usageFile`).
 */
function createUsageTracker({ model, tier, maxOutputTokens, budget, now = () => new Date() }) {
  const calls = [];
  let spent = 0;

  return {
    get spent() {
      return spent;
    },
    calls,

    /** Para (sem chamar) se o gasto acumulado mais o pior caso da próxima chamada passar do orçamento. */
    assertWithinBudget(inputTokens) {
      const worstCase = worstCaseCost({ model, tier, inputTokens, maxOutputTokens });
      if (spent + worstCase > budget) throw new BudgetExceededError({ spent, worstCase, budget });
    },

    /** Soma a chamada ao gasto e devolve a entrada do log. Cobra no tier que a OpenAI diz ter usado, se vier. */
    record({ year, attempt, response }) {
      const usage = extractUsage(response);
      const billedTier = TIERS.includes(response?.service_tier) ? response.service_tier : tier;
      const costUsd = callCost({ model, tier: billedTier, ...usage });
      spent += costUsd;
      const entry = {
        at: now().toISOString(),
        year,
        attempt,
        status: response?.status ?? "unknown",
        ...(response?.incomplete_details?.reason ? { incompleteReason: response.incomplete_details.reason } : {}),
        tier: billedTier,
        ...usage,
        costUsd,
        totalCostUsd: spent,
      };
      calls.push(entry);
      return entry;
    },

    /** Documento do `<out>.usage.json`: esta rodada somada às anteriores (`previous` é o JSON já em disco). */
    toLog(previous = {}) {
      const runs = [...(Array.isArray(previous.runs) ? previous.runs : [])];
      runs.push({ model, tier, maxOutputTokens, budgetUsd: budget, totalCostUsd: spent, calls });
      return { allRunsCostUsd: runs.reduce((sum, run) => sum + run.totalCostUsd, 0), runs };
    },
  };
}

/**
 * Monta o `ask(prompt, attempt, year)` do `generateYear` sobre a Responses API. Antes de cada chamada confere o
 * orçamento; depois soma o custo (inclusive de resposta `incomplete`, cortada por `max_output_tokens`, que devolve
 * texto vazio em vez de derrubar a rodada) e avisa `onCall` com a entrada do log.
 */
function createAsk({ client, tracker, model, tier, effort, maxOutputTokens, system, schema, onCall = () => {} }) {
  return async (prompt, attempt, year) => {
    tracker.assertWithinBudget(attemptInputTokens({ prompt, system, schema }));
    const response = await client.responses.create({
      model,
      instructions: system,
      input: prompt,
      text: { format: { type: "json_schema", ...schema } },
      service_tier: tier,
      max_output_tokens: maxOutputTokens,
      ...(effort ? { reasoning: { effort } } : {}),
    });
    onCall(tracker.record({ year, attempt, response }));
    if (response.status === "failed") throw new Error(`a OpenAI falhou a resposta: ${response.error?.message ?? "sem detalhe"}`);
    return response.status === "completed" ? response.output_text : "";
  };
}

/** Linha de log de uma chamada, no console. */
function formatCallLine(entry) {
  return `${entry.year} tentativa ${entry.attempt}: ${entry.status}, entrada ${entry.inputTokens}, saída ${entry.outputTokens} (raciocínio ${entry.reasoningTokens}), custo ${formatUsd(entry.costUsd)}, total ${formatUsd(entry.totalCostUsd)}`;
}

module.exports = {
  PRICES_USD_PER_MILLION,
  DEFAULT_TIER,
  DEFAULT_EFFORT,
  DEFAULT_MAX_OUTPUT_TOKENS,
  BudgetExceededError,
  resolvePrice,
  pricePerToken,
  callCost,
  worstCaseCost,
  estimateInputTokens,
  parseCallOptions,
  attemptInputTokens,
  estimateRun,
  extractUsage,
  createUsageTracker,
  createAsk,
  formatUsd,
  formatCallLine,
};
