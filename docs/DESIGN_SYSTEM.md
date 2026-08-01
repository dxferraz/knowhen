# Knowhen — Design System

Estudo de design e referência de implementação do tema do app.
Movimento adotado: **Glassmorphism**.

- Código: `lib/core/theme/`
- Import único: `import 'package:knowhen/core/theme/theme.dart';`
- Styleguide vivo: `DesignSystemPage` (`lib/core/theme/showcase/`)

---

## 1. Diagnóstico do ponto de partida

| Achado | Impacto |
| --- | --- |
| Paleta genérica (azul/verde/âmbar padrão de framework CSS) | O app não tinha assinatura visual própria; qualquer captura de tela poderia ser de qualquer app |
| Três famílias tipográficas concorrendo (Inter + Poppins + Yatra One) sem regra de uso | Títulos irmãos apareciam em fontes diferentes entre telas |
| Escala de texto com saltos irregulares (32 → 28 → 24 → 16) e `height: 1.5` em tudo | Títulos grandes com entrelinha de parágrafo; hierarquia fraca |
| Valores mágicos espalhados (`padding: 20`, `borderRadius: 20`, `bottom: 50`) | Cada tela nova reinventava o espaçamento |
| Fundo chapado + cards `primaryContainer` opacos | Nenhuma profundidade; o conteúdo "flutuava" sem camada |
| Fontes baixadas em runtime (`google_fonts`) | Sem rede, o texto não renderiza; com rede, há um flash de fonte na primeira abertura |
| Seção de concepção virava uma **página em branco** para menores de 18 | Furo no fluxo do resumo |

---

## 2. Direção de design

O Knowhen revela o que a **data de nascimento** de alguém esconde: tempo vivido, fase da lua,
o Brasil daquele momento. É um app de *revelação* — o conteúdo aparece em camadas.

O Glassmorphism é a escolha certa aqui justamente porque é um estilo de **camadas**: existe
uma cena colorida ao fundo (o "universo" da pessoa) e painéis translúcidos por cima
(as revelações). O vidro deixa a cena vazar — a informação sempre parece estar *sobre*
algo maior.

Isso impõe uma regra estrutural, que é a base de todo o sistema:

```
Camada 0 — Cena      gradiente base + orbes de aurora   (AuroraBackground)
Camada 1 — Vidro     painéis translúcidos com desfoque  (GlassContainer)
Camada 2 — Conteúdo  texto e números de alto contraste  (AppText)
Camada 3 — Ação      o único elemento sólido da tela    (GlassButton primary)
```

Vidro sobre fundo chapado é só um card cinza. **Se uma tela não tiver a camada 0,
o estilo não funciona** — por isso `GlassScaffold` já a monta.

---

## 3. Cor

### 3.1 Estratégia

Quatro famílias cromáticas, cada uma com papel narrativo, sobre uma rampa neutra
levemente violeta (nunca cinza puro — cinza neutro sobre aurora suja a imagem).

| Família | Papel | Onde aparece |
| --- | --- | --- |
| **Iris** (violeta) | Marca e ação principal | CTA, seleção, foco, orbe dominante |
| **Aqua** (turquesa) | Dado, tempo, precisão | Relógio da vida, métricas |
| **Solar** (âmbar) | Corpo celeste, destaque | Lua, "w" do logo |
| **Nebula** (magenta) | Emoção, origem | Concepção, selos de IA, fim do gradiente da marca |
| **Ink** (neutro violáceo) | Texto e estrutura | Tudo o mais |

Arquivo: `tokens/app_palette.dart` — **é a única camada com hexadecimais literais.**

### 3.2 Tokens semânticos

Telas nunca usam a paleta bruta. Usam função (`tokens/app_colors.dart`, via `context.colors`):

```dart
context.colors.textPrimary     // leitura principal
context.colors.textSecondary   // apoio
context.colors.textTertiary    // metadado (só ≥18px ou 14px bold)
context.colors.primary         // ação
context.colors.accent          // decoração
```

Trocar a marca inteira = remapear `AppColors.light` / `AppColors.dark`. Nenhuma tela muda.

### 3.3 Contraste medido (WCAG 2.1)

| Par | Claro | Escuro |
| --- | --- | --- |
| `textPrimary` sobre a cena | 15.4:1 | 16.7:1 |
| `textSecondary` sobre a cena | 6.1:1 | 7.7:1 |
| `textTertiary` sobre a cena | 3.9:1 ⚠️ | 4.6:1 |
| `onPrimary` sobre `primary` | 5.2:1 | 5.4:1 |

⚠️ `textTertiary` **não passa AA para texto pequeno no tema claro** — por isso é reservado
a overlines (bold) e legendas grandes. É uma restrição do sistema, não um descuido:
`AppText.caption` e `AppText.overline` são os únicos papéis que o usam.

O tint do vidro no tema claro é alto de propósito (72%→44% de branco). Abaixo disso o texto
sobre o painel cai de contraste conforme o orbe que passa por trás — o contraste passaria a
depender da posição na tela, que é exatamente o que não pode acontecer.

---

## 4. Tipografia

### 4.1 Pareamento

| Família | Papel | Por quê |
| --- | --- | --- |
| **Sora** | Display, títulos, números | Geométrica, terminais retos, contraforma ampla: aguenta tracking negativo em corpo grande e mantém nitidez sobre superfície translúcida |
| **Inter** | Texto corrido, rótulos, botões | Altura-x alta e formas abertas: sustenta leitura em baixo contraste |
| **Yatra One** | Só o logotipo | Herança da marca, isolada do resto do sistema |

As três são **empacotadas no app** (`lib/core/assets/fonts`, licença OFL) em vez de baixadas
em runtime. Isso elimina o flash de fonte, garante texto sem rede e tira um servidor de
terceiros do caminho crítico. Só os pesos usados são embarcados (~1,3 MB no total).

> `google_fonts` continua no `pubspec.yaml` mas não é mais usada pelo tema; pode ser removida
> quando não houver outra dependência dela.

### 4.2 Escala

Base 16, razão ~1.2, com tracking decrescente conforme o corpo cresce e entrelinha
proporcional ao papel (títulos apertados, texto arejado).

| Papel (`AppText.*`) | Fonte | Tam. | Peso | Entrelinha | Tracking |
| --- | --- | --- | --- | --- | --- |
| `displayLarge` | Sora | 44 | 700 | 1.08 | -1.2 |
| `display` | Sora | 36 | 700 | 1.12 | -0.9 |
| `headline` | Sora | 26 | 600 | 1.24 | -0.4 |
| `headlineSmall` | Sora | 20 | 600 | 1.30 | 0 |
| `title` | Sora | 18 | 600 | 1.35 | 0 |
| `subtitle` | Inter | 16 | 600 | 1.40 | +0.1 |
| `bodyLarge` | Inter | 17 | 400 | 1.55 | +0.1 |
| `body` | Inter | 15 | 400 | 1.55 | +0.1 |
| `caption` | Inter | 13 | 400 | 1.50 | +0.2 |
| `label` | Inter | 14 | 600 | 1.20 | +0.4 |
| `overline` | Inter | 11 | 700 | 1.20 | +0.9, CAIXA ALTA |
| `numericHero` | Sora | 40 | 700 | 1.05 | -1.5, **tabular** |
| `numeric` | Sora | 24 | 600 | 1.10 | -0.5, **tabular** |

### 4.3 Regras

1. **Escolha pelo papel, nunca pelo tamanho.** `AppText.headline`, não "texto de 26px".
2. **Números que atualizam usam algarismos tabulares.** Sem isso o relógio da vida treme a
   cada segundo, porque a largura dos dígitos muda.
3. **Máximo dois papéis de display por tela.** O eyebrow (`overline`) resolve a maioria dos
   casos em que se sentiria falta de mais um nível.
4. Texto sobre gradiente usa `AppText(..., gradient: ...)`, que aplica o gradiente como
   máscara — nunca uma cor sólida "parecida".

---

## 5. Espaço, raio e movimento

**Espaço** (`AppSpacing`) — grade de 4pt:
`xSmall 4 · small 8 · sMedium 12 · medium 16 · mLarge 20 · large 24 · xLarge 32 · xxLarge 40 · huge 48`

- `screenGutter = 20` é a margem lateral de toda tela;
- `bottomBarHeight = 88` é o espaço reservado para a barra flutuante.

**Raio** (`AppRadius`) — `small 12 · medium 16 · large 20 · xLarge 24 · xxLarge 32 · pill`

Glassmorphism exige raios generosos: em cantos fechados o desfoque vaza nas quinas e o
painel perde a leitura de vidro. Cards usam 24, painéis em foco 32, botões `pill`.

**Movimento** (`AppMotion`) — `fast 140ms · normal 240ms · slow 420ms · page 520ms`

Curva padrão `easeOutCubic` (desaceleração): o estilo é físico, então tudo precisa parecer
material deslizando, não estado trocando. `GlassReveal` faz a entrada em cascata
(fade + 18px de deslocamento, 70ms de degrau entre elementos) e respeita
"reduzir movimento" do sistema.

---

## 6. A receita do vidro

Os parâmetros ficam em `tokens/app_glass.dart` e são montados em `GlassTheme`
(`ThemeExtension`), acessível por `context.glass`.

| Parâmetro | Claro | Escuro | Razão |
| --- | --- | --- | --- |
| Desfoque (σ) sutil / regular / forte | 8 / 18 / 30 | 8 / 18 / 30 | Três profundidades ópticas; acima de ~32 o custo cresce sem ganho visual |
| Saturação do backdrop | 1.18 | 1.35 | Vidro real satura o que está atrás; sem isso o desfoque lava a aurora e o painel fica cinza |
| Tint (topo→base) | 72% → 44% branco | 14% → 5% branco | No claro sustenta o contraste do texto; no escuro é vidro fumê |
| Traço | branco 95% → iris 25% | branco 32% → 6% | Hairline em gradiente diagonal: simula uma fonte de luz única e fixa na cena |
| Sombra | preto 10%, blur 30 | preto 55%, blur 40 | Sempre projetada **para fora** do painel |
| Halo | primary 10% | primary 20% | Cor vazando por baixo, une painel e cena |

Três decisões de implementação que sustentam a qualidade (`glass_container.dart`):

1. **Sombra só para fora.** O interior é recortado antes de desenhar. Sombra sob um painel
   translúcido é capturada pelo `BackdropFilter` e encardece o vidro — visível sobretudo no
   tema claro.
2. **Área de pintura justa.** O retângulo da sombra é calculado a partir do alcance real das
   sombras. Folga excessiva aumenta o *cull rect* da camada e faz o desfoque amostrar região
   demais.
3. **Traço como `foregroundPainter`.** Um `Border` comum não aceita gradiente; pintar por
   cima garante o hairline de 1px nítido em qualquer densidade de tela.

### Modo econômico

`BackdropFilter` é caro em Android de entrada. `AppGlassConfig.enableBlur = false` converte
**todo** o sistema para superfícies opacas equivalentes, sem mudar uma única medida de
layout. `AppGlassConfig.maxBlurSigma` limita o σ globalmente.

A deriva animada da aurora (`animatedAurora`) vem **desligada**: qualquer animação atrás de
um `BackdropFilter` obriga o desfoque da tela inteira a ser recalculado a cada frame. O
movimento do app vive acima do vidro (`GlassReveal`), onde é barato.

---

## 7. Componentes

| Componente | Uso |
| --- | --- |
| `GlassScaffold` | Toda tela. Monta a cena, deixa o `Scaffold` transparente e posiciona app bar / barra inferior |
| `GlassAppBar` | Barra superior translúcida sobre o conteúdo |
| `GlassBottomBar` | Barra de ação flutuante, destacada das bordas |
| `AppSection` | Layout canônico de seção: `overline → título → subtítulo → conteúdo → rodapé` |
| `GlassContainer` | Primitivo de superfície (3 níveis de profundidade) |
| `GlassCard` | Card com slots de eyebrow/título/leading/trailing |
| `GlassStatTile` | Métrica: número grande (tabular, com gradiente) + rótulo |
| `GlassBadge` | Selo curto |
| `GlassButton` | Ações: `primary` (gradiente sólido), `glass`, `ghost` |
| `GlassIconButton` | Ação flutuante circular |
| `AppText` | Todo texto do app |
| `AppPageIndicator` | Indicador de página (horizontal ou vertical) |
| `GlassReveal` | Entrada em cascata |

**Uma ação primária por tela.** O botão primário é o único elemento sólido do sistema: ele
precisa furar o vidro para ser inequivocamente o próximo passo.

### Exemplo

```dart
GlassScaffold(
  appBar: const GlassAppBar(title: 'Resumo', actions: [ThemeButton()]),
  body: AppSection(
    eyebrow: 'Tempo de vida',
    title: 'Você já viveu',
    child: GlassCard(
      child: GlassStatTile(
        value: '12.480',
        label: 'dias',
        gradient: context.glass.coolGradient,
      ),
    ),
  ),
  bottomBar: GlassBottomBar(
    child: GlassButton(label: 'Continuar', expand: true, onPressed: _go),
  ),
);
```

---

## 8. Armadilhas conhecidas

- **`Align`/`Center` dentro de `Expanded` numa `Row`** se expandem até a altura máxima
  permitida. Dentro de `GlassBottomBar` isso significa a tela inteira: passe `heightFactor: 1`.
- **Scroll aninhado em `PageView` vertical** rouba o gesto de paginação. Por isso
  `AppSection` não rola por padrão: o conteúdo é `Flexible` e encolhe em telas baixas.
- **Não empilhe `BackdropFilter`s** sem necessidade: cada um é uma amostragem do fundo.

---

## 9. Verificação

`test/design_system_test.dart` renderiza as 9 telas nos 2 temas (390×844, com as fontes
reais do app) e falha se houver exceção de build, layout ou overflow.

```bash
flutter test          # 19 testes
make lint             # dart analyze --fatal-infos --fatal-warnings
```

Não há goldens versionados de propósito: imagens de referência ficariam desatualizadas a
cada ajuste de token e pesariam ~13 MB. Para inspeção visual, use a `DesignSystemPage`.

---

## 10. Próximos passos sugeridos

1. **Textos fixos em português no código** (`'Céu da sua noite'`, `'anos'`, `'meses'`) deveriam
   migrar para o ARB — o design system já está pronto para isso, faltam as chaves.
2. **Grão/noise sutil** sobre a cena aproximaria ainda mais do vidro real; exige um asset de
   textura, então ficou fora deste ciclo.
3. **Perfil de performance por device**: ligar `AppGlassConfig.enableBlur = false`
   automaticamente em aparelhos de baixo custo.
4. **Logo**: `Yatra One` é a única peça que ainda não conversa com a linguagem geométrica do
   resto. Vale um estudo de logotipo à parte.
