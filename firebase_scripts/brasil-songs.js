// Regras puras do preenchimento de `brasil-songs`, separadas do script para serem testadas sem rede.

const FIRST_YEAR = 1925;

// Respostas que o modelo dá quando não sabe (ou que não são uma música de verdade).
const PLACEHOLDERS = new Set(["unknown", "desconhecido", "desconhecida", "n/a", "na", "nenhum", "nenhuma", "-", "?"]);

/** Todos os meses de `fromYear` até `toYear`, sem ultrapassar o mês de `now`. Mês e ano como string, como o app lê. */
function monthsToProcess(fromYear, toYear, now = new Date()) {
  const months = [];
  for (let year = fromYear; year <= toYear; year++) {
    for (let month = 1; month <= 12; month++) {
      const isFuture = year > now.getFullYear() || (year === now.getFullYear() && month > now.getMonth() + 1);
      if (!isFuture) months.push({ year: String(year), month: String(month) });
    }
  }
  return months;
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

/** Lê "Cantor: ..." e "Música: ..." da resposta. Devolve `null` se faltar um campo ou se for um placeholder. */
function parseSongResponse(text) {
  if (typeof text !== "string") return null;
  const artistMatch = text.match(/Cantor:\s*(.+)/i);
  const songMatch = text.match(/M[úu]sica:\s*(.+)/i);
  if (!artistMatch || !songMatch) return null;

  const artist = clean(artistMatch[1]);
  const songName = clean(songMatch[1]);
  if (!isValidField(artist) || !isValidField(songName)) return null;
  return { artist, songName };
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
  for (const [key, entry] of Object.entries(songs)) {
    for (const message of validateEntry(key, entry, now)) errors.push({ key, message });
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

function buildPrompt({ year, month }) {
  return `Qual lançamento de música foi um sucesso no Brasil no mês ${month} de ${year}? Responda apenas com o nome do cantor e o nome da música, neste formato:

Cantor: [Nome do cantor]
Música: [Nome da música]

Só responda se tiver certeza de que a música existe e foi sucesso no Brasil nesse período. Se não tiver certeza, responda exatamente:

Cantor: Desconhecido
Música: Desconhecido`;
}

module.exports = { FIRST_YEAR, monthsToProcess, docId, parseSongResponse, toDocument, buildPrompt, validateSongs };
