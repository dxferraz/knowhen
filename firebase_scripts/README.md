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

1. **Gerar** (usa a OpenAI, uma chamada por ano; não toca no Firestore):

   ```sh
   node fill-brasil-featured-song.js generate --from 1930 --to 2023 --out brasil-songs.json
   ```

   Para cada ano o modelo lista 12 sucessos diferentes lançados nele, e o script põe um por mês. Entram só as
   músicas bem formadas, com `releaseYear` igual ao ano pedido e que não repetem outra do mesmo ano nem de outro
   ano (a comparação ignora caixa, acento, pontuação e artigos). Se o ano não render pelo menos 8 músicas assim,
   o script tenta de novo uma vez e, se continuar faltando, deixa o ano de fora (o app esconde a seção para os
   meses sem música). `--from`/`--to` só aceitam anos de 1925 até o ano atual; o padrão é 1930 a 2023, porque
   fora disso o modelo não conhece bem a música brasileira. `--model` troca o modelo (padrão `gpt-4o-mini`). Se a
   rodada cair (cota, rede), rode de novo: os anos que já estão no arquivo são pulados.

   **Atenção:** o `releaseYear` é o próprio modelo que informa, então não prova nada. Em teste, o `gpt-4o-mini`
   ainda atribui música ao artista ou ao ano errado; a revisão do passo 2 é obrigatória.

2. **Revisar** o `brasil-songs.json`: confira por amostragem, pelo menos de 1960 em diante, se a música existe
   e foi sucesso no mês. Apague do JSON as entradas erradas.

3. **Publicar** (usa `GOOGLE_APPLICATION_CREDENTIALS`):

   ```sh
   node fill-brasil-featured-song.js publish --in brasil-songs.json
   ```

   Cada mês vira um documento com id `AAAA-MM`; publicar de novo sobrescreve os mesmos documentos, sem duplicar.
   O app lê direto por esse id, então documentos antigos com id aleatório são ignorados.

   Antes de gravar, o `publish` valida todas as entradas (chave `AAAA-MM` igual ao ano/mês, `month` de "1" a "12",
   `year` entre 1925 e o ano atual, `artist`/`songName` preenchidos e sem placeholder, nenhuma música repetida, sem campos extras). Se alguma
   falhar, ele lista todas, com a chave, e não grava nada: corrija o JSON e rode de novo.

`npm test` roda os testes das regras (intervalo de anos, parse da resposta, deduplicação, distribuição pelos meses, validação do JSON).

As credenciais também podem vir direto do shell, sem `.env`:

```sh
GOOGLE_APPLICATION_CREDENTIALS=~/.config/knowhen/service-account.json node fill-brasil-featured-song.js publish
```

`.env` e `serviceAccountKey*.json` estão no `.gitignore`.
