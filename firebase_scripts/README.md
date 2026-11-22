# firebase_scripts

Scripts Node.js que populam o Firestore do projeto `knowhen` usando a OpenAI.

Requer Node.js 22 ou superior.

## Configuração

1. Gere uma chave de service account no console do Firebase/GCP
   (Configurações do projeto → Contas de serviço → Gerar nova chave privada).
2. Salve o JSON **fora do repositório**, por exemplo em
   `~/.config/knowhen/service-account.json`. Nunca faça commit desse arquivo.
3. Copie o exemplo de variáveis de ambiente e preencha:

   ```sh
   cd firebase_scripts
   cp .env.example .env
   ```

   - `GOOGLE_APPLICATION_CREDENTIALS`: caminho absoluto para o JSON do passo 2.
   - `OPENAI_API_KEY` (e, se usar, `OPEN_AI_PROJECT_KEY`): credenciais da OpenAI.

4. Instale as dependências:

   ```sh
   npm install
   ```

## Música do mês (`brasil-songs`)

O preenchimento é em duas etapas, para revisar o conteúdo da IA antes de publicar.

1. **Gerar** (usa a OpenAI, `gpt-4o-mini`, uma chamada por mês; não toca no Firestore):

   ```sh
   node fill-brasil-featured-song.js generate --from 1925 --to 2026 --out brasil-songs.json
   ```

   Só entram no JSON as respostas válidas: o modelo é instruído a responder `Desconhecido` quando não tem
   certeza, e essas respostas (e qualquer resposta fora do formato) são descartadas, nunca gravadas. Se a
   rodada cair (cota, rede), rode de novo: os meses que já estão no arquivo são pulados.

2. **Revisar** o `brasil-songs.json`: confira por amostragem, pelo menos de 1960 em diante, se a música existe
   e foi sucesso no mês. Apague do JSON as entradas erradas.

3. **Publicar** (usa `GOOGLE_APPLICATION_CREDENTIALS`):

   ```sh
   node fill-brasil-featured-song.js publish --in brasil-songs.json
   ```

   Cada mês vira um documento com id `AAAA-MM`; publicar de novo sobrescreve os mesmos documentos, sem duplicar.

`npm test` roda os testes das regras (parse da resposta, ids, meses a processar).

As credenciais também podem vir direto do shell, sem `.env`:

```sh
GOOGLE_APPLICATION_CREDENTIALS=~/.config/knowhen/service-account.json node fill-brasil-featured-song.js publish
```

`.env` e `serviceAccountKey*.json` estão no `.gitignore`.
