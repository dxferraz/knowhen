// Preenche a coleção `brasil-songs` (música em destaque de cada mês) em duas etapas, para dar tempo de revisar
// o conteúdo gerado pela IA antes de publicar:
//
//   node fill-brasil-featured-song.js generate [--from 1925] [--to 2026] [--out brasil-songs.json]
//     Pergunta ao modelo, mês a mês, e grava só as respostas válidas no JSON. Dá para interromper e rodar de novo:
//     os meses que já estão no arquivo são pulados. Não toca no Firestore.
//
//   node fill-brasil-featured-song.js publish [--in brasil-songs.json]
//     Grava o JSON (já revisado) no Firestore, um documento por mês (id `AAAA-MM`). Rodar de novo sobrescreve
//     os mesmos documentos, sem duplicar.
//
// Veja firebase_scripts/README.md para as credenciais.

const fs = require("node:fs");
const { FIRST_YEAR, monthsToProcess, docId, parseSongResponse, toDocument, buildPrompt } = require("./brasil-songs");

const MODEL = "gpt-4o-mini";
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
  return fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, "utf8")) : {};
}

async function askModel(openai, date) {
  const response = await openai.chat.completions.create({
    model: MODEL,
    temperature: 0,
    messages: [
      { role: "system", content: "Você é um historiador dos sucessos musicais brasileiros." },
      { role: "user", content: buildPrompt(date) },
    ],
  });
  return response.choices[0].message.content;
}

async function generate({ from = FIRST_YEAR, to = new Date().getFullYear(), out = "brasil-songs.json" }) {
  const OpenAIApi = require("openai").default;
  const apiKey = process.env.OPENAI_API_KEY || process.env.OPEN_AI_API_KEY;
  if (!apiKey) throw new Error("OPENAI_API_KEY não definido. Veja firebase_scripts/README.md.");
  const openai = new OpenAIApi({ apiKey, project: process.env.OPEN_AI_PROJECT_KEY || undefined });

  const songs = readSongs(out);
  const pending = monthsToProcess(Number(from), Number(to)).filter((date) => !songs[docId(date)]);
  let skipped = 0;
  console.log(`${pending.length} meses para gerar (${Object.keys(songs).length} já no arquivo ${out}).`);

  for (const date of pending) {
    try {
      const song = parseSongResponse(await askModel(openai, date));
      if (song) {
        songs[docId(date)] = toDocument(date, song);
        fs.writeFileSync(out, JSON.stringify(songs, null, 2));
      } else {
        skipped++;
        console.log(`${docId(date)}: sem resposta válida, mês ignorado.`);
      }
    } catch (error) {
      // Falha de rede/cota: para aqui; o que já foi gerado fica no arquivo e a próxima rodada continua dele.
      console.error(`${docId(date)}: erro ao consultar o modelo (${error.message}). Rode de novo para continuar.`);
      process.exitCode = 1;
      break;
    }
  }
  console.log(`Fim: ${Object.keys(songs).length} músicas em ${out}, ${skipped} meses ignorados.`);
}

async function publish({ in: file = "brasil-songs.json" }) {
  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    throw new Error("GOOGLE_APPLICATION_CREDENTIALS não definido. Veja firebase_scripts/README.md.");
  }
  const admin = require("firebase-admin");
  admin.initializeApp({ credential: admin.credential.applicationDefault() });
  const db = admin.firestore();

  const entries = Object.entries(readSongs(file));
  if (entries.length === 0) throw new Error(`Nada para publicar em ${file}.`);

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
  require("dotenv").config();
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
