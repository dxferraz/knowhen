# firebase_scripts

Scripts Node.js que populam o Firestore do projeto `knowhen` usando a OpenAI.

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
   - `OPEN_AI_PROJECT_KEY` / `OPENAI_API_KEY`: credenciais da OpenAI.

4. Instale as dependências e rode o script desejado:

   ```sh
   npm install
   node fill-brasil-featured-song.js
   ```

Também é possível passar a variável direto no shell, sem `.env`:

```sh
GOOGLE_APPLICATION_CREDENTIALS=~/.config/knowhen/service-account.json node fill-brasil-featured-song.js
```

`.env` e `serviceAccountKey*.json` estão no `.gitignore`.
