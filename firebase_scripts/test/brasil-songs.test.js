const test = require("node:test");
const assert = require("node:assert/strict");
const {
  parseYearRange,
  docId,
  normalize,
  songKey,
  parseYearResponse,
  dedupeSongs,
  generateYear,
  yearDocuments,
  toDocument,
  buildYearPrompt,
  validateSongs,
} = require("../brasil-songs");

const rangeNow = new Date(2026, 10, 22);

test("parseYearRange usa o padrão 1930 a 2023 e aceita anos válidos", () => {
  assert.deepEqual(parseYearRange(undefined, undefined, rangeNow), { from: 1930, to: 2023 });
  assert.deepEqual(parseYearRange("1960", "1960", rangeNow), { from: 1960, to: 1960 });
  assert.deepEqual(parseYearRange("1925", "2026", rangeNow), { from: 1925, to: 2026 });
});

test("parseYearRange rejeita ano com lixo, fora do intervalo ou invertido", () => {
  for (const bad of ["1223", "1924", "2027", "95", "abcd", "19999", ""]) {
    assert.throws(() => parseYearRange(bad, "2000", rangeNow), /--from/, bad);
    assert.throws(() => parseYearRange("1990", bad, rangeNow), /--to/, bad);
  }
  assert.throws(() => parseYearRange("2000", "1990", rangeNow), /não pode ser maior/);
});

test("docId é determinístico e com mês de dois dígitos", () => {
  assert.equal(docId({ year: "1995", month: "3" }), "1995-03");
  assert.equal(docId({ year: "1995", month: "12" }), "1995-12");
});

test("toDocument usa o formato que o app lê, com ano e mês como string", () => {
  const doc = toDocument({ year: 1995, month: 3 }, { artist: "Tom Jobim", songName: "Garota de Ipanema" });
  assert.deepEqual(doc, { artist: "Tom Jobim", songName: "Garota de Ipanema", spotifyUrl: "", month: "3", year: "1995" });
});

test("normalize ignora caixa, acento, pontuação e artigos", () => {
  assert.equal(normalize("O Amor É o Meu País"), normalize("o amor e meu pais"));
  assert.equal(normalize("Mas, Que Nada!"), "mas que nada");
  assert.equal(normalize("The Beatles"), "beatles");
});

test("songKey trata grafias diferentes da mesma música como a mesma", () => {
  const a = songKey({ artist: "Roberto Carlos", songName: "O Amor É o Meu País" });
  const b = songKey({ artist: "roberto carlos", songName: "O Amor É Meu País" });
  assert.equal(a, b);
  assert.notEqual(a, songKey({ artist: "Outro Cantor", songName: "O Amor É Meu País" }));
});

const yearJson = (year, songs) => JSON.stringify({ songs: songs.map(([artist, songName, releaseYear = year]) => ({ artist, songName, releaseYear })) });

test("parseYearResponse lê a lista e limpa markdown e aspas", () => {
  const text = yearJson(1995, [["**Tom Jobim**", '"Garota de Ipanema"']]);
  assert.deepEqual(parseYearResponse(text, "1995"), [{ artist: "Tom Jobim", songName: "Garota de Ipanema" }]);
});

test("parseYearResponse descarta releaseYear diferente do ano pedido", () => {
  const text = yearJson(1995, [["A", "Certa"], ["B", "De outro ano", 1964], ["C", "Sem ano", null]]);
  assert.deepEqual(parseYearResponse(text, 1995), [{ artist: "A", songName: "Certa" }]);
});

test("parseYearResponse descarta placeholder, campo que não é texto e item que não é objeto", () => {
  const text = JSON.stringify({
    songs: [
      { artist: "Desconhecido", songName: "X", releaseYear: 1995 },
      { artist: "A", songName: 7, releaseYear: 1995 },
      { artist: "A", songName: "x".repeat(121), releaseYear: 1995 },
      null,
      "texto",
      { artist: "Ok", songName: "Válida", releaseYear: 1995 },
    ],
  });
  assert.deepEqual(parseYearResponse(text, 1995), [{ artist: "Ok", songName: "Válida" }]);
});

test("parseYearResponse devolve lista vazia para resposta que não é JSON ou sem `songs`", () => {
  for (const text of ["Não sei.", "", null, undefined, "{}", '{"songs":"x"}', "[]"]) {
    assert.deepEqual(parseYearResponse(text, 1995), [], String(text));
  }
});

test("dedupeSongs separa repetidas entre si e as já usadas, ignorando caixa, acento e artigo", () => {
  const seen = new Set([songKey({ artist: "A", songName: "Antiga" })]);
  const { accepted, rejected } = dedupeSongs(
    [
      { artist: "A", songName: "A ANTIGA" },
      { artist: "B", songName: "Nova" },
      { artist: "b", songName: "O Nova" },
      { artist: "C", songName: "Outra" },
    ],
    seen,
  );
  assert.deepEqual(accepted.map((s) => s.songName), ["Nova", "Outra"]);
  assert.equal(rejected.length, 2);
  assert.equal(seen.size, 1, "não altera o conjunto recebido");
});

const songsOf = (prefix, count) => Array.from({ length: count }, (_, i) => [`Artista ${prefix}${i}`, `Música ${prefix}${i}`]);

test("generateYear devolve as 12 músicas na primeira tentativa", async () => {
  const prompts = [];
  const ask = async (prompt) => (prompts.push(prompt), yearJson(1995, songsOf("a", 12)));
  const songs = await generateYear({ year: 1995, ask, seen: new Set() });
  assert.equal(songs.length, 12);
  assert.equal(prompts.length, 1);
});

test("generateYear passa a tentativa e o ano para o ask", async () => {
  const calls = [];
  const ask = async (prompt, attempt, year) => (calls.push([attempt, year]), yearJson(1995, songsOf("a", 5)));
  await generateYear({ year: 1995, ask, seen: new Set() });
  assert.deepEqual(calls, [[1, 1995], [2, 1995]]);
});

test("generateYear tenta de novo uma vez e junta o que veio de novo, sem repetir", async () => {
  const prompts = [];
  const answers = [yearJson(1995, songsOf("a", 5)), yearJson(1995, [...songsOf("a", 5), ...songsOf("b", 4)])];
  const ask = async (prompt) => (prompts.push(prompt), answers[prompts.length - 1]);
  const songs = await generateYear({ year: 1995, ask, seen: new Set() });
  assert.equal(songs.length, 9);
  assert.equal(new Set(songs.map(songKey)).size, 9);
  assert.equal(prompts.length, 2);
  assert.match(prompts[1], /Não repita.*Artista a0 - Música a0/);
});

test("generateYear ignora o ano (null) se, depois de duas tentativas, faltar música válida e inédita", async () => {
  let calls = 0;
  const ask = async () => (calls++, yearJson(1995, songsOf("a", 5)));
  assert.equal(await generateYear({ year: 1995, ask, seen: new Set() }), null);
  assert.equal(calls, 2, "só uma nova tentativa");
});

test("generateYear não reaproveita música de outro ano (seen) nem do ano errado", async () => {
  const seen = new Set(songsOf("a", 12).map(([artist, songName]) => songKey({ artist, songName })));
  const ask = async () => yearJson(1995, [...songsOf("a", 12), ...songsOf("b", 12).map(([a, s]) => [a, s, 1970])]);
  assert.equal(await generateYear({ year: 1995, ask, seen }), null);
});

test("generateYear deixa o erro de rede subir para quem chamou", async () => {
  const ask = async () => {
    throw new Error("429");
  };
  await assert.rejects(generateYear({ year: 1995, ask, seen: new Set() }), /429/);
});

test("yearDocuments põe uma música por mês, de 1 a 12, como string", () => {
  const docs = yearDocuments(1995, songsOf("a", 12).map(([artist, songName]) => ({ artist, songName })));
  assert.deepEqual(Object.keys(docs), Array.from({ length: 12 }, (_, i) => `1995-${String(i + 1).padStart(2, "0")}`));
  assert.deepEqual(docs["1995-03"], { artist: "Artista a2", songName: "Música a2", spotifyUrl: "", month: "3", year: "1995" });
});

test("yearDocuments com menos de 12 músicas espalha pelos meses sem repetir mês", () => {
  const docs = yearDocuments(1995, songsOf("a", 8).map(([artist, songName]) => ({ artist, songName })));
  assert.equal(Object.keys(docs).length, 8);
  assert.deepEqual(Object.keys(docs), ["1995-01", "1995-03", "1995-04", "1995-06", "1995-07", "1995-09", "1995-10", "1995-12"]);
});

for (const count of [8, 9, 10, 11, 12]) {
  test(`yearDocuments com ${count} músicas usa ${count} meses distintos de 1 a 12, de janeiro a dezembro`, () => {
    const docs = yearDocuments(1995, songsOf("a", count).map(([artist, songName]) => ({ artist, songName })));
    const months = Object.values(docs).map((doc) => Number(doc.month));
    assert.equal(months.length, count);
    assert.equal(new Set(months).size, count);
    assert.ok(months.every((month) => Number.isInteger(month) && month >= 1 && month <= 12));
    assert.equal(Math.min(...months), 1);
    assert.equal(Math.max(...months), 12);
    assert.equal(docs["1995-01"].songName, "Música a0");
    assert.equal(docs["1995-12"].songName, `Música a${count - 1}`);
  });
}

test("yearDocuments com uma música só põe em janeiro", () => {
  const docs = yearDocuments(1995, songsOf("a", 1).map(([artist, songName]) => ({ artist, songName })));
  assert.deepEqual(Object.keys(docs), ["1995-01"]);
});

test("buildYearPrompt pede músicas lançadas no ano e deixa dizer menos de 12", () => {
  const prompt = buildYearPrompt(1995);
  assert.match(prompt, /12 músicas diferentes/);
  assert.match(prompt, /LANÇADAS em 1995/);
  assert.match(prompt, /devolva menos/);
  assert.doesNotMatch(prompt, /Não repita nenhuma/);
  assert.match(buildYearPrompt(1995, [{ artist: "A", songName: "B" }]), /Não repita nenhuma destas.*A - B/);
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
  assert.deepEqual(validate({ "1925-03": { ...valid, year: "1925" }, "2026-03": { ...valid, year: "2026", songName: "Outra" } }), []);
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

test("validateSongs rejeita música repetida em outro mês/ano, apontando onde ela já foi usada", () => {
  const other = { ...valid, month: "4", songName: "garota de ipanema" };
  const again = { ...valid, year: "1996", month: "1", songName: "A Garota de Ipanema" };
  assert.deepEqual(validate({ "1995-03": valid, "1995-04": other, "1996-01": again }), [
    { key: "1995-04", message: "música repetida (já usada em 1995-03)" },
    { key: "1996-01", message: "música repetida (já usada em 1995-03)" },
  ]);
  assert.deepEqual(validate({ "1995-03": valid, "1995-04": { ...other, artist: "Outro" } }), []);
});
