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
  return value.length > 0 && value.length <= 120 && !PLACEHOLDERS.has(value.toLowerCase());
}

/** Documento no formato que o app lê (`BirthSongDTO`): ano e mês como string. */
function toDocument({ year, month }, song) {
  return { artist: song.artist, songName: song.songName, spotifyUrl: "", month: String(month), year: String(year) };
}

function buildPrompt({ year, month }) {
  return `Qual lançamento de música foi um sucesso no Brasil no mês ${month} de ${year}? Responda apenas com o nome do cantor e o nome da música, neste formato:

Cantor: [Nome do cantor]
Música: [Nome da música]

Só responda se tiver certeza de que a música existe e foi sucesso no Brasil nesse período. Se não tiver certeza, responda exatamente:

Cantor: Desconhecido
Música: Desconhecido`;
}

module.exports = { FIRST_YEAR, monthsToProcess, docId, parseSongResponse, toDocument, buildPrompt };
