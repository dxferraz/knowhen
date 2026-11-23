// Preenche a coleção `brasil-songs` (música em destaque de cada mês) em duas etapas, para dar tempo de revisar
// o conteúdo gerado pela IA antes de publicar:
//
//   node fill-brasil-featured-song.js generate [--from 1930] [--to 2023] [--out brasil-songs.json] [--model gpt-4o-mini]
//     Pergunta ao modelo, ano a ano, 12 sucessos diferentes lançados naquele ano e distribui um por mês. Descarta
//     músicas repetidas (no ano e entre anos) e as que o modelo diz ter outro ano de lançamento. Se o ano não
//     render músicas suficientes em duas tentativas, ele fica de fora. Dá para interromper e rodar de novo: os
//     anos que já estão no arquivo são pulados. Não toca no Firestore.
//
//   node fill-brasil-featured-song.js publish [--in brasil-songs.json]
//     Valida todas as entradas do JSON (já revisado) e só então grava no Firestore, um documento por mês (id
//     `AAAA-MM`). Se alguma entrada for inválida, lista todas e não grava nada. Rodar de novo sobrescreve os
//     mesmos documentos, sem duplicar.
//
// Veja firebase_scripts/README.md para as credenciais.

const fs = require("node:fs");
const { parseYearRange, songKey, generateYear, yearDocuments, validateSongs, YEAR_RESPONSE_SCHEMA } = require("./brasil-songs");

const DEFAULT_MODEL = "gpt-4o-mini";
const BATCH_SIZE = 400; // o Firestore aceita até 500 operações por batch

function parseArgs(argv) {
  const [command, ...rest] = argv;
  const options = {};
  for (let i = 0; i < rest.length; i += 2) {
    options[rest[i].replace(/^--/, "")] = rest[i + 1];
  }
  return { command, options };
}

function readSongs(file) {
  if (!fs.existsSync(file)) return {};
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch (error) {
    throw new Error(`${file} não é um JSON válido: ${error.message}`);
  }
}

async function generate({ from, to, out = "brasil-songs.json", model = DEFAULT_MODEL }) {
  const range = parseYearRange(from, to);
  const OpenAIApi = require("openai").default;
  const apiKey = process.env.OPENAI_API_KEY || process.env.OPEN_AI_API_KEY;
  if (!apiKey) throw new Error("OPENAI_API_KEY não definido. Veja firebase_scripts/README.md.");
  const openai = new OpenAIApi({ apiKey, project: process.env.OPEN_AI_PROJECT_KEY || undefined });

  const ask = async (prompt, attempt) => {
    const response = await openai.chat.completions.create({
      model,
      temperature: attempt === 1 ? 0 : 0.5,
      response_format: { type: "json_schema", json_schema: YEAR_RESPONSE_SCHEMA },
      messages: [
        { role: "system", content: "Você é um historiador dos sucessos musicais brasileiros. Prefira dizer menos músicas a inventar." },
        { role: "user", content: prompt },
      ],
    });
    return response.choices[0].message.content;
  };

  const songs = readSongs(out);
  const seen = new Set(Object.values(songs).map(songKey));
  const doneYears = new Set(Object.values(songs).map((entry) => String(entry.year)));
  const years = [];
  for (let year = range.from; year <= range.to; year++) if (!doneYears.has(String(year))) years.push(year);
  console.log(`${years.length} anos para gerar de ${range.from} a ${range.to} (${doneYears.size} já no arquivo ${out}).`);

  const skipped = [];
  for (const year of years) {
    try {
      const yearSongs = await generateYear({ year, ask, seen });
      if (!yearSongs) {
        skipped.push(year);
        console.log(`${year}: poucas músicas válidas e inéditas, ano ignorado.`);
        continue;
      }
      Object.assign(songs, yearDocuments(year, yearSongs));
      yearSongs.forEach((song) => seen.add(songKey(song)));
      fs.writeFileSync(out, JSON.stringify(songs, null, 2));
    } catch (error) {
      // Falha de rede/cota: para aqui; o que já foi gerado fica no arquivo e a próxima rodada continua dele.
      console.error(`${year}: erro ao consultar o modelo (${error.message}). Rode de novo para continuar.`);
      process.exitCode = 1;
      break;
    }
  }
  console.log(`Fim: ${Object.keys(songs).length} músicas em ${out}. Anos ignorados: ${skipped.join(", ") || "nenhum"}.`);
}

async function publish({ in: file = "brasil-songs.json" }) {
  const songs = readSongs(file);
  const errors = validateSongs(songs);
  if (errors.length > 0) {
    const lines = errors.map(({ key, message }) => `  ${key}: ${message}`).join("\n");
    throw new Error(`${errors.length} problema(s) em ${file}, nada foi gravado:\n${lines}`);
  }
  const entries = Object.entries(songs);
  if (entries.length === 0) throw new Error(`Nada para publicar em ${file}.`);

  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    throw new Error("GOOGLE_APPLICATION_CREDENTIALS não definido. Veja firebase_scripts/README.md.");
  }
  const { applicationDefault, initializeApp } = require("firebase-admin/app");
  const { getFirestore } = require("firebase-admin/firestore");
  initializeApp({ credential: applicationDefault() });
  const db = getFirestore();

  for (let i = 0; i < entries.length; i += BATCH_SIZE) {
    const batch = db.batch();
    for (const [id, doc] of entries.slice(i, i + BATCH_SIZE)) {
      batch.set(db.collection("brasil-songs").doc(id), doc);
    }
    await batch.commit();
  }
  console.log(`${entries.length} documentos gravados em brasil-songs.`);
}

if (require.main === module) {
  require("dotenv").config({ quiet: true });
  const { command, options } = parseArgs(process.argv.slice(2));
  const commands = { generate, publish };
  if (!commands[command]) {
    console.error("Uso: node fill-brasil-featured-song.js <generate|publish> [opções]. Veja o topo do arquivo.");
    process.exit(1);
  }
  commands[command](options).catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
}
