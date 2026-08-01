# Fontes empacotadas

Todas as famílias abaixo são distribuídas sob a
[SIL Open Font License 1.1](https://openfontlicense.org), que permite o uso e
a redistribuição embutida em aplicativos.

| Família | Arquivos | Uso no app | Origem |
| --- | --- | --- | --- |
| Inter | `Inter-Regular` (400), `Inter-SemiBold` (600), `Inter-Bold` (700) | Texto corrido, rótulos, botões | Google Fonts |
| Sora | `Sora-SemiBold` (600), `Sora-Bold` (700) | Títulos, números-herói | Google Fonts |
| Yatra One | `YatraOne-Regular` (400) | Logotipo | Google Fonts |

Só estão empacotados os pesos efetivamente usados pela escala tipográfica
(`AppTypography`). Ao adicionar um peso novo ao design system, adicione também
o arquivo correspondente aqui e no bloco `fonts:` do `pubspec.yaml` — caso
contrário o Flutter sintetiza o peso e o resultado fica visivelmente pior.
