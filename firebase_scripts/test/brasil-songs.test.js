const test = require("node:test");
const assert = require("node:assert/strict");
const { monthsToProcess, docId, parseSongResponse, toDocument, buildPrompt, validateSongs } = require("../brasil-songs");

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

const now = new Date(2026, 10, 22);
const valid = { artist: "Tom Jobim", songName: "Garota de Ipanema", spotifyUrl: "", month: "3", year: "1995" };
const validate = (songs) => validateSongs(songs, now);
const messagesFor = (songs, key) => validate(songs).filter((e) => e.key === key).map((e) => e.message);

test("validateSongs aceita o que o toDocument gera e um arquivo vazio", () => {
  assert.deepEqual(validate({ "1995-03": valid }), []);
  assert.deepEqual(validate({ "1995-03": toDocument({ year: "1995", month: "3" }, { artist: "A", songName: "B" }) }), []);
  assert.deepEqual(validate({}), []);
});

test("validateSongs aceita entrada sem spotifyUrl, que o app não lê", () => {
  const { spotifyUrl, ...withoutUrl } = valid;
  assert.deepEqual(validate({ "1995-03": withoutUrl }), []);
});

test("validateSongs rejeita chave fora do formato AAAA-MM", () => {
  for (const key of ["1995-3", "95-03", "abc", "1995/03", "1995-03 "]) {
    assert.match(messagesFor({ [key]: valid }, key).join(), /AAAA-MM/, key);
  }
});

test("validateSongs rejeita chave diferente do ano/mês da entrada", () => {
  const errors = validate({ "1995-04": valid });
  assert.deepEqual(errors, [{ key: "1995-04", message: "a chave não bate com year/month (esperado 1995-03)" }]);
});

test("validateSongs rejeita mês fora de 1 a 12, com zero à esquerda ou que não seja string", () => {
  for (const month of ["13", "0", "03", "", "x", 3]) {
    assert.match(messagesFor({ "1995-03": { ...valid, month } }, "1995-03").join(), /month/, String(month));
  }
});

test("validateSongs rejeita ano antes de FIRST_YEAR, no futuro ou que não seja string de 4 dígitos", () => {
  for (const year of ["1924", "2027", "95", "abcd", 1995]) {
    const key = `${year}-03`;
    assert.match(messagesFor({ [key]: { ...valid, year } }, key).join(), /year/, String(year));
  }
  assert.deepEqual(validate({ "1925-03": { ...valid, year: "1925" }, "2026-03": { ...valid, year: "2026" } }), []);
});

test("validateSongs rejeita placeholder, texto vazio ou longo demais em artist/songName", () => {
  for (const artist of ["Desconhecido", "unknown", " N/A ", "", "   ", "x".repeat(121), 42, null]) {
    assert.match(messagesFor({ "1995-03": { ...valid, artist } }, "1995-03").join(), /artist/, String(artist));
  }
  assert.match(messagesFor({ "1995-03": { ...valid, songName: "Desconhecido" } }, "1995-03").join(), /songName/);
  assert.deepEqual(validate({ "1995-03": { ...valid, songName: "x".repeat(120) } }), []);
});

test("validateSongs rejeita campo faltando, sem repetir o erro de conteúdo", () => {
  const { artist, ...withoutArtist } = valid;
  assert.deepEqual(validate({ "1995-03": withoutArtist }), [{ key: "1995-03", message: "falta o campo artist" }]);
});

test("validateSongs rejeita campos extras", () => {
  assert.deepEqual(validate({ "1995-03": { ...valid, genre: "bossa" } }), [
    { key: "1995-03", message: "campo inesperado: genre" },
  ]);
});

test("validateSongs rejeita entrada que não é objeto e raiz que não é objeto", () => {
  assert.match(messagesFor({ "1995-03": "texto" }, "1995-03").join(), /objeto/);
  assert.match(messagesFor({ "1995-03": null }, "1995-03").join(), /objeto/);
  assert.equal(validate([valid]).length, 1);
  assert.equal(validate(null).length, 1);
});

test("validateSongs lista os erros de todas as entradas, cada um com a sua chave", () => {
  const errors = validate({
    "1995-03": valid,
    "1995-13": { ...valid, month: "13" },
    "1996-01": { ...valid, month: "1", year: "1996", artist: "Unknown" },
    oops: valid,
  });
  assert.deepEqual([...new Set(errors.map((e) => e.key))].sort(), ["1995-13", "1996-01", "oops"]);
});
