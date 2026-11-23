const test = require("node:test");
const assert = require("node:assert/strict");
const { monthsToProcess, docId, parseSongResponse, toDocument, buildPrompt } = require("../brasil-songs");

test("monthsToProcess cobre todos os meses do intervalo, como string", () => {
  const months = monthsToProcess(1990, 1991, new Date(2026, 10, 22));
  assert.equal(months.length, 24);
  assert.deepEqual(months[0], { year: "1990", month: "1" });
  assert.deepEqual(months[23], { year: "1991", month: "12" });
});

test("monthsToProcess não passa do mês atual", () => {
  const months = monthsToProcess(2026, 2026, new Date(2026, 10, 22));
  assert.equal(months.length, 11);
  assert.deepEqual(months.at(-1), { year: "2026", month: "11" });
});

test("monthsToProcess 1925 a 2026 gera um mês por vez, sem repetir", () => {
  const months = monthsToProcess(1925, 2026, new Date(2026, 10, 22));
  assert.equal(months.length, 101 * 12 + 11);
  assert.equal(new Set(months.map(docId)).size, months.length);
});

test("docId é determinístico e com mês de dois dígitos", () => {
  assert.equal(docId({ year: "1995", month: "3" }), "1995-03");
  assert.equal(docId({ year: "1995", month: "12" }), "1995-12");
});

test("parseSongResponse lê cantor e música", () => {
  const song = parseSongResponse("Cantor: Tom Jobim\nMúsica: Garota de Ipanema");
  assert.deepEqual(song, { artist: "Tom Jobim", songName: "Garota de Ipanema" });
});

test("parseSongResponse limpa markdown e aspas", () => {
  const song = parseSongResponse('Cantor: **Roberto Carlos**  \nMúsica: "Detalhes"');
  assert.deepEqual(song, { artist: "Roberto Carlos", songName: "Detalhes" });
});

test("parseSongResponse rejeita Desconhecido/Unknown em qualquer campo", () => {
  assert.equal(parseSongResponse("Cantor: Desconhecido\nMúsica: Desconhecido"), null);
  assert.equal(parseSongResponse("Cantor: Unknown\nMúsica: Detalhes"), null);
  assert.equal(parseSongResponse("Cantor: Roberto Carlos\nMúsica: n/a"), null);
});

test("parseSongResponse rejeita resposta fora do formato, vazia ou sem texto", () => {
  assert.equal(parseSongResponse("Não sei responder."), null);
  assert.equal(parseSongResponse("Cantor: Roberto Carlos"), null);
  assert.equal(parseSongResponse("Cantor:\nMúsica:"), null);
  assert.equal(parseSongResponse(null), null);
});

test("toDocument usa o formato que o app lê, com ano e mês como string", () => {
  const doc = toDocument({ year: 1995, month: 3 }, { artist: "Tom Jobim", songName: "Garota de Ipanema" });
  assert.deepEqual(doc, { artist: "Tom Jobim", songName: "Garota de Ipanema", spotifyUrl: "", month: "3", year: "1995" });
});

test("buildPrompt pede para admitir quando não souber", () => {
  const prompt = buildPrompt({ year: "1995", month: "3" });
  assert.match(prompt, /mês 3 de 1995/);
  assert.match(prompt, /Desconhecido/);
});
