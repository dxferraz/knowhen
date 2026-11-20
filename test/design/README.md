# Capturas de design (DXF-9)

Não são testes de regressão. Geram as imagens da auditoria e da proposta de
redesign "Céu de Nascimento". Rodar com Flutter 3.38.x:

```sh
flutter test test/design/audit_capture.dart --update-goldens     # main atual → shots/current/
flutter test test/design/proposal_capture.dart --update-goldens  # mockups    → shots/proposal/
flutter test test/design/sheets_capture.dart --update-goldens    # pranchas   → shots/sheets/
```

- `proposal/kn_design.dart`: tokens (paleta, espaço, raio, tipografia) e componentes
  de referência (`KnButton`, `KnCard`, `KnStoryProgress`, `KnMoon`...).
- `proposal/kn_screens.dart`: telas do protótipo com dados fixos (14/03/1991).
- `shots/glass/`: capturas da exploração `claude/glassmorphism-custom-theme-yyfvyf`,
  usadas na prancha da alternativa.
- `fixtures/fonts`: Inter, DM Serif Display, Poppins e Yatra One (SIL OFL).
  `fixtures/gstatic`: os mesmos arquivos que o `google_fonts` baixa hoje em runtime.
