// Regras puras do preenchimento de `brasil-songs`, separadas do script para serem testadas sem rede.

const FIRST_YEAR = 1925;
// O modelo não conhece bem a música brasileira antes de ~1930 nem depois do seu corte de conhecimento.
const DEFAULT_FROM_YEAR = 1930;
const DEFAULT_TO_YEAR = 2023;
const SONGS_PER_YEAR = 12;
// Menos que isso e o ano fica de fora: preferimos um mês sem música (o app esconde a seção) a um chute.
const MIN_SONGS_PER_YEAR = 8;
const MAX_ATTEMPTS_PER_YEAR = 2;

// Respostas que o modelo dá quando não sabe (ou que não são uma música de verdade).
const PLACEHOLDERS = new Set(["unknown", "desconhecido", "desconhecida", "n/a", "na", "nenhum", "nenhuma", "-", "?"]);
const ARTICLES = new Set(["o", "a", "os", "as", "um", "uma", "the"]);

/** Valida `--from`/`--to`: anos de quatro dígitos, de FIRST_YEAR até o ano atual, com `from <= to`. */
function parseYearRange(from = DEFAULT_FROM_YEAR, to = DEFAULT_TO_YEAR, now = new Date()) {
  const last = now.getFullYear();
  const parse = (value, name) => {
    if (!/^\d{4}$/.test(String(value)) || Number(value) < FIRST_YEAR || Number(value) > last) {
      throw new Error(`--${name} deve ser um ano de ${FIRST_YEAR} a ${last}, recebi "${value}".`);
    }
    return Number(value);
  };
  const range = { from: parse(from, "from"), to: parse(to, "to") };
  if (range.from > range.to) throw new Error(`--from (${range.from}) não pode ser maior que --to (${range.to}).`);
  return range;
}

/** Id determinístico: rodar duas vezes sobrescreve o mesmo documento em vez de duplicar. */
function docId({ year, month }) {
  return `${year}-${String(month).padStart(2, "0")}`;
}

function clean(value) {
  return value
    .replace(/\*\*/g, "")
    .replace(/^["“'«\[]+|["”'»\]]+$/g, "")
    .trim();
}

/** Chave de comparação: sem caixa, acento, pontuação nem artigos, para "O Amor É o Meu País" = "O Amor É Meu País". */
function normalize(text) {
  return text
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, " ")
    .split(/\s+/)
    .filter((word) => word && !ARTICLES.has(word))
    .join(" ");
}

function songKey({ artist, songName }) {
  return `${normalize(artist)}|${normalize(songName)}`;
}

/**
 * Lê a resposta JSON de um ano e devolve só as músicas bem formadas cujo `releaseYear` é o ano pedido.
 * Resposta que não é JSON, ou sem a lista `songs`, vira lista vazia.
 */
function parseYearResponse(text, year) {
  let data;
  try {
    data = JSON.parse(text);
  } catch {
    return [];
  }
  if (!Array.isArray(data?.songs)) return [];
  return data.songs.flatMap((item) => {
    if (item === null || typeof item !== "object") return [];
    if (typeof item.artist !== "string" || typeof item.songName !== "string") return [];
    if (Number(item.releaseYear) !== Number(year)) return [];
    const artist = clean(item.artist);
    const songName = clean(item.songName);
    return isValidField(artist) && isValidField(songName) ? [{ artist, songName }] : [];
  });
}

/** Separa as músicas novas das repetidas (entre si ou em `seen`, o conjunto de `songKey` já usados). */
function dedupeSongs(candidates, seen) {
  const taken = new Set(seen);
  const accepted = [];
  const rejected = [];
  for (const song of candidates) {
    const key = songKey(song);
    if (taken.has(key)) {
      rejected.push(song);
    } else {
      taken.add(key);
      accepted.push(song);
    }
  }
  return { accepted, rejected };
}

/**
 * Pergunta ao modelo (`ask(prompt, attempt, year)` devolve o texto da resposta) as músicas de um ano. Tenta de novo uma
 * vez, juntando o que veio de novo, se faltar música válida e inédita. Devolve `null` se, depois disso, ainda
 * houver menos de MIN_SONGS_PER_YEAR: o ano fica de fora. Erros de rede de `ask` sobem para quem chamou.
 */
async function generateYear({ year, ask, seen, minSongs = MIN_SONGS_PER_YEAR }) {
  const songs = [];
  const asked = [];
  for (let attempt = 1; attempt <= MAX_ATTEMPTS_PER_YEAR; attempt++) {
    const candidates = parseYearResponse(await ask(buildYearPrompt(year, asked), attempt, year), year);
    // No máximo SONGS_PER_YEAR vão para o prompt da próxima tentativa: é a premissa do teto de custo de `estimateRun`.
    asked.push(...candidates.slice(0, Math.max(0, SONGS_PER_YEAR - asked.length)));
    const taken = new Set([...seen, ...songs.map(songKey)]);
    songs.push(...dedupeSongs(candidates, taken).accepted);
    if (songs.length >= SONGS_PER_YEAR) break;
  }
  return songs.length >= minSongs ? songs.slice(0, SONGS_PER_YEAR) : null;
}

/**
 * Espalha as músicas do ano pelos meses, uma por mês, da primeira em janeiro à última em dezembro (com 12, uma em cada
 * mês). Com até 12 músicas os meses nunca se repetem. Devolve `{ AAAA-MM: doc }`.
 */
function yearDocuments(year, songs) {
  const documents = {};
  const picked = songs.slice(0, SONGS_PER_YEAR);
  picked.forEach((song, index) => {
    const month = picked.length === 1 ? 1 : Math.round((index * 11) / (picked.length - 1)) + 1;
    const date = { year: String(year), month: String(month) };
    documents[docId(date)] = toDocument(date, song);
  });
  return documents;
}

function isValidField(value) {
  return typeof value === "string" && value.length > 0 && value.length <= 120 && !PLACEHOLDERS.has(value.toLowerCase());
}

/** Documento no formato que o app lê (`BirthSongDTO`): ano e mês como string. */
function toDocument({ year, month }, song) {
  return { artist: song.artist, songName: song.songName, spotifyUrl: "", month: String(month), year: String(year) };
}

const KEY_PATTERN = /^\d{4}-\d{2}$/;
const MONTH_PATTERN = /^([1-9]|1[0-2])$/;
const YEAR_PATTERN = /^\d{4}$/;
const REQUIRED_FIELDS = ["artist", "songName", "month", "year"];
const OPTIONAL_FIELDS = ["spotifyUrl"]; // o app não lê, mas o `generate` grava vazio

/**
 * Confere o JSON revisado à mão antes do `publish`. Devolve a lista de problemas (vazia se estiver tudo certo),
 * cada um com a chave da entrada, para o script listar todos de uma vez e não gravar nada.
 */
function validateSongs(songs, now = new Date()) {
  if (songs === null || typeof songs !== "object" || Array.isArray(songs)) {
    return [{ key: "(arquivo)", message: "o JSON deve ser um objeto com uma entrada por mês" }];
  }
  const errors = [];
  const firstKeyBySong = new Map();
  for (const [key, entry] of Object.entries(songs).sort(([a], [b]) => a.localeCompare(b))) {
    for (const message of validateEntry(key, entry, now)) errors.push({ key, message });
    if (typeof entry?.artist === "string" && typeof entry?.songName === "string") {
      const songId = songKey(entry);
      const first = firstKeyBySong.get(songId);
      if (first) errors.push({ key, message: `música repetida (já usada em ${first})` });
      else firstKeyBySong.set(songId, key);
    }
  }
  return errors;
}

function validateEntry(key, entry, now) {
  const problems = [];
  if (!KEY_PATTERN.test(key)) problems.push("a chave deve ter o formato AAAA-MM");
  if (entry === null || typeof entry !== "object" || Array.isArray(entry)) {
    return [...problems, "a entrada deve ser um objeto"];
  }

  for (const field of REQUIRED_FIELDS) {
    if (!(field in entry)) problems.push(`falta o campo ${field}`);
  }
  const allowed = new Set([...REQUIRED_FIELDS, ...OPTIONAL_FIELDS]);
  for (const field of Object.keys(entry)) {
    if (!allowed.has(field)) problems.push(`campo inesperado: ${field}`);
  }

  const monthOk = typeof entry.month === "string" && MONTH_PATTERN.test(entry.month);
  if ("month" in entry && !monthOk) problems.push('month deve ser uma string de "1" a "12", sem zero à esquerda');
  const yearOk = typeof entry.year === "string" && YEAR_PATTERN.test(entry.year);
  if ("year" in entry && !yearOk) {
    problems.push("year deve ser uma string com o ano de quatro dígitos");
  } else if (yearOk && (Number(entry.year) < FIRST_YEAR || Number(entry.year) > now.getFullYear())) {
    problems.push(`year deve estar entre ${FIRST_YEAR} e ${now.getFullYear()}`);
  }
  if (monthOk && yearOk && KEY_PATTERN.test(key) && key !== docId(entry)) {
    problems.push(`a chave não bate com year/month (esperado ${docId(entry)})`);
  }

  for (const field of ["artist", "songName"]) {
    if (field in entry && !isValidField(typeof entry[field] === "string" ? entry[field].trim() : entry[field])) {
      problems.push(`${field} deve ser um texto de 1 a 120 caracteres que não seja placeholder`);
    }
  }
  if ("spotifyUrl" in entry && typeof entry.spotifyUrl !== "string") problems.push("spotifyUrl deve ser uma string");
  return problems;
}

function buildYearPrompt(year, asked = []) {
  const avoid = asked.length
    ? `\n\nNão repita nenhuma destas, já listadas: ${asked.map((song) => `${song.artist} - ${song.songName}`).join("; ")}.`
    : "";
  return `Liste ${SONGS_PER_YEAR} músicas diferentes que foram sucesso no Brasil e que foram LANÇADAS em ${year}. Cada música deve ter sido lançada exatamente nesse ano: não use músicas lançadas antes ou depois, nem regravações posteriores. Não repita músicas. Informe o ano de lançamento de cada uma em releaseYear. Só inclua músicas que você tem certeza que existem, com cantor e título corretos; se não souber ${SONGS_PER_YEAR}, devolva menos.${avoid}`;
}

/** Formato estruturado da resposta, para o `response_format` da OpenAI. */
const YEAR_RESPONSE_SCHEMA = {
  name: "year_songs",
  strict: true,
  schema: {
    type: "object",
    additionalProperties: false,
    required: ["songs"],
    properties: {
      songs: {
        type: "array",
        items: {
          type: "object",
          additionalProperties: false,
          required: ["artist", "songName", "releaseYear"],
          properties: {
            artist: { type: "string" },
            songName: { type: "string" },
            releaseYear: { type: "integer" },
          },
        },
      },
    },
  },
};

module.exports = {
  FIRST_YEAR,
  DEFAULT_FROM_YEAR,
  DEFAULT_TO_YEAR,
  SONGS_PER_YEAR,
  MIN_SONGS_PER_YEAR,
  MAX_ATTEMPTS_PER_YEAR,
  YEAR_RESPONSE_SCHEMA,
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
};
