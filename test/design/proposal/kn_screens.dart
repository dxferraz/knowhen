// Telas do protótipo "Céu de Nascimento" (DXF-9). Dados fixos de exemplo:
// nascimento em 14/03/1991 às 07:32, "agora" = 20/11/2026 10:00.
import 'package:flutter/material.dart';

import 'kn_design.dart';

final DateTime kBirth = DateTime(1991, 3, 14, 7, 32);
final DateTime kNow = DateTime(2026, 11, 20, 10, 0);

String thousands(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

({int y, int m, int d}) ymd(DateTime from, DateTime to) {
  int y = to.year - from.year;
  int m = to.month - from.month;
  int d = to.day - from.day;
  if (d < 0) {
    m -= 1;
    d += DateTime(to.year, to.month, 0).day;
  }
  if (m < 0) {
    y -= 1;
    m += 12;
  }
  return (y: y, m: m, d: d);
}

const _summaryCount = 5;

// ---------------------------------------------------------------------------
// Onboarding (1 tela)
// ---------------------------------------------------------------------------

class OnboardingMock extends StatelessWidget {
  final KnPalette p;
  const OnboardingMock({super.key, required this.p});

  Widget _row(IconData icon, String title, String sub) => Padding(
    padding: const EdgeInsets.symmetric(vertical: KnSpace.sm),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: p.surfaceHi, borderRadius: BorderRadius.circular(KnRadius.sm)),
          child: Icon(icon, size: 20, color: p.accentText),
        ),
        const SizedBox(width: KnSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: KnText.label(p)),
              Text(sub, style: KnText.caption(p)),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return KnScreen(
      p: p,
      topBar: KnTopBar(
        p: p,
        center: KnLogo(p: p),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: KnSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: KnSpace.xl),
            Center(
              child: ExcludeSemantics(child: KnMoon(p: p, phase: 0.18, size: 132)),
            ),
            const SizedBox(height: KnSpace.xl),
            Semantics(
              header: true,
              child: Text('O que o dia em que você nasceu tem a contar?', style: KnText.title(p)),
            ),
            const SizedBox(height: KnSpace.md),
            Text('Informe sua data de nascimento e veja quatro revelações sobre ela.', style: KnText.bodyMuted(p)),
            const SizedBox(height: KnSpace.lg),
            _row(Icons.hourglass_bottom_rounded, 'Tempo de vida', 'Anos, dias e segundos, ao vivo'),
            _row(Icons.favorite_border_rounded, 'Concepção', 'Quando sua história começou'),
            _row(Icons.nightlight_round, 'Fase da lua', 'Como estava o céu naquela noite'),
            _row(Icons.history_edu_rounded, 'Fato histórico', 'O que acontecia no Brasil'),
          ],
        ),
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KnButton(p: p, text: 'Começar', icon: Icons.arrow_forward_rounded),
          const SizedBox(height: KnSpace.sm),
          Text('Leva menos de um minuto', style: KnText.caption(p)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data de nascimento
// ---------------------------------------------------------------------------

class BirthdateMock extends StatelessWidget {
  final KnPalette p;
  final bool filled;
  const BirthdateMock({super.key, required this.p, this.filled = true});

  Widget _field(String label, String value, String hint, {int flex = 1, bool focused = false}) => Expanded(
    flex: flex,
    child: Semantics(
      textField: true,
      label: label,
      value: value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(child: Text(label, style: KnText.caption(p))),
          const SizedBox(height: KnSpace.xs + 2),
          Container(
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(KnRadius.sm),
              border: Border.all(color: focused ? p.lavender : p.outline, width: focused ? 2 : 1),
            ),
            child: ExcludeSemantics(
              child: Text(
                value.isEmpty ? hint : value,
                style: TextStyle(
                  fontFamily: knSerif,
                  fontSize: 30,
                  color: value.isEmpty ? p.inkMuted.withValues(alpha: 0.6) : p.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return KnScreen(
      p: p,
      topBar: KnTopBar(
        p: p,
        leading: KnIconButton(p: p, icon: Icons.arrow_back_rounded, label: 'Voltar'),
        center: KnLogo(p: p, size: 22),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: KnSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: KnSpace.xl),
            KnEyebrow('Só falta isso', p: p),
            const SizedBox(height: KnSpace.sm),
            Semantics(header: true, child: Text('Quando você nasceu?', style: KnText.title(p))),
            const SizedBox(height: KnSpace.xl),
            Row(
              children: [
                _field('Dia', filled ? '14' : '', 'DD'),
                const SizedBox(width: KnSpace.md),
                _field('Mês', filled ? '03' : '', 'MM'),
                const SizedBox(width: KnSpace.md),
                _field('Ano', filled ? '1991' : '', 'AAAA', flex: 2, focused: !filled),
              ],
            ),
            const SizedBox(height: KnSpace.sm),
            Text(
              filled ? 'Quinta-feira, 14 de março de 1991' : 'Digite só os números. Ex.: 14 03 1991',
              style: KnText.caption(p),
            ),
            const SizedBox(height: KnSpace.xl),
            KnCard(
              p: p,
              padding: const EdgeInsets.symmetric(horizontal: KnSpace.lg, vertical: KnSpace.md),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: p.accentText),
                  const SizedBox(width: KnSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hora do nascimento', style: KnText.label(p)),
                        Text(
                          filled ? '07:32 · deixa o relógio mais preciso' : 'Opcional · deixa o relógio mais preciso',
                          style: KnText.caption(p),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    toggled: filled,
                    label: 'Informar hora do nascimento',
                    child: Container(
                      width: 52,
                      height: 32,
                      padding: const EdgeInsets.all(4),
                      alignment: filled ? Alignment.centerRight : Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: filled ? p.lavender : p.outline,
                        borderRadius: BorderRadius.circular(KnRadius.pill),
                      ),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: p.dark && filled ? p.bg : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: Opacity(
        opacity: filled ? 1 : 0.4,
        child: KnButton(p: p, text: 'Revelar meu resumo', icon: Icons.auto_awesome_rounded),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Revelação (carregando)
// ---------------------------------------------------------------------------

class RevealMock extends StatelessWidget {
  final KnPalette p;
  const RevealMock({super.key, required this.p});

  Widget _step(String text, bool done) => Padding(
    padding: const EdgeInsets.symmetric(vertical: KnSpace.xs + 2),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        done
            ? Icon(Icons.check_circle_rounded, size: 20, color: p.accentText)
            : SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: p.lavender, value: 0.6),
              ),
        const SizedBox(width: KnSpace.md),
        Text(text, style: done ? KnText.body(p) : KnText.bodyMuted(p)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return KnScreen(
      p: p,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KnSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KnMoon(p: p, phase: 0.08, size: 140),
              const SizedBox(height: KnSpace.xxl),
              Semantics(
                liveRegion: true,
                child: Text(
                  'Olhando o céu de\n14 de março de 1991…',
                  textAlign: TextAlign.center,
                  style: KnText.title(p),
                ),
              ),
              const SizedBox(height: KnSpace.xl),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _step('Calculando seu tempo de vida', true),
                  _step('Encontrando a fase da lua', true),
                  _step('Buscando um fato histórico', false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Resumo: moldura comum dos cartões
// ---------------------------------------------------------------------------

class SummaryFrame extends StatelessWidget {
  final KnPalette p;
  final int index;
  final Widget child;
  final bool last;
  const SummaryFrame({super.key, required this.p, required this.index, required this.child, this.last = false});

  @override
  Widget build(BuildContext context) {
    return KnScreen(
      p: p,
      topBar: Column(
        children: [
          KnTopBar(
            p: p,
            leading: KnIconButton(p: p, icon: Icons.close_rounded, label: 'Fechar resumo'),
            center: Text('14 mar 1991', style: KnText.label(p)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KnSpace.lg),
            child: KnStoryProgress(p: p, count: _summaryCount, current: index),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(KnSpace.xl, KnSpace.xl, KnSpace.xl, KnSpace.lg),
        child: child,
      ),
      bottom: last
          ? null
          : Row(
              children: [
                KnIconButton(p: p, icon: Icons.ios_share_rounded, label: 'Compartilhar este cartão'),
                const SizedBox(width: KnSpace.md),
                Expanded(
                  child: KnButton(p: p, text: 'Próximo', icon: Icons.arrow_forward_rounded),
                ),
              ],
            ),
    );
  }
}

class YearsCardMock extends StatelessWidget {
  final KnPalette p;
  const YearsCardMock({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    final a = ymd(kBirth, kNow);
    final lived = kNow.difference(kBirth);
    var next = DateTime(kNow.year, kBirth.month, kBirth.day);
    if (!next.isAfter(kNow)) next = DateTime(kNow.year + 1, kBirth.month, kBirth.day);
    final toBirthday = DateTime(
      next.year,
      next.month,
      next.day,
    ).difference(DateTime(kNow.year, kNow.month, kNow.day)).inDays;
    return SummaryFrame(
      p: p,
      index: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KnEyebrow('Tempo de vida', p: p),
          const SizedBox(height: KnSpace.md),
          Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${a.y} anos', style: KnText.display(p)),
                  TextSpan(
                    text: '\n${a.m} meses e ${a.d} dias',
                    style: KnText.title(p).copyWith(color: p.inkMuted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: KnSpace.xl),
          KnCard(
            p: p,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Até agora você viveu', style: KnText.caption(p)),
                const SizedBox(height: KnSpace.lg),
                Row(
                  children: [
                    Expanded(
                      child: KnStat(p: p, value: thousands(lived.inDays), label: 'dias'),
                    ),
                    Expanded(
                      child: KnStat(p: p, value: thousands(lived.inHours), label: 'horas'),
                    ),
                  ],
                ),
                const SizedBox(height: KnSpace.lg),
                Row(
                  children: [
                    Expanded(
                      child: KnStat(p: p, value: thousands(lived.inMinutes), label: 'minutos'),
                    ),
                    Expanded(
                      child: KnStat(p: p, value: thousands(lived.inSeconds), label: 'segundos · ao vivo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: KnSpace.md),
          KnCard(
            p: p,
            padding: const EdgeInsets.symmetric(horizontal: KnSpace.lg, vertical: KnSpace.md),
            child: Row(
              children: [
                Icon(Icons.cake_outlined, color: p.accentText),
                const SizedBox(width: KnSpace.md),
                Expanded(child: Text('Faltam $toBirthday dias para os seus ${a.y + 1} anos', style: KnText.label(p))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConceptionCardMock extends StatelessWidget {
  final KnPalette p;
  const ConceptionCardMock({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return SummaryFrame(
      p: p,
      index: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KnEyebrow('Concepção', p: p),
          const SizedBox(height: KnSpace.md),
          Semantics(header: true, child: Text('Sua história começou entre', style: KnText.title(p))),
          const SizedBox(height: KnSpace.xl),
          KnCard(
            p: p,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('de', style: KnText.caption(p)),
                      Text('14 jun', style: KnText.display(p).copyWith(fontSize: 36)),
                      Text('1990', style: KnText.bodyMuted(p)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: p.inkMuted),
                const SizedBox(width: KnSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('a', style: KnText.caption(p)),
                      Text('28 jun', style: KnText.display(p).copyWith(fontSize: 36)),
                      Text('1990', style: KnText.bodyMuted(p)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KnSpace.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: p.inkMuted),
              const SizedBox(width: KnSpace.sm),
              Expanded(
                child: Text(
                  'Estimativa: cerca de 38 semanas antes do nascimento, com margem de uma semana para cada lado.',
                  style: KnText.caption(p),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MoonCardMock extends StatelessWidget {
  final KnPalette p;
  const MoonCardMock({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    const phases = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875];
    return SummaryFrame(
      p: p,
      index: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KnEyebrow('Fase da lua', p: p),
          const SizedBox(height: KnSpace.md),
          Semantics(header: true, child: Text('Você nasceu numa\nLua Nova', style: KnText.title(p))),
          const SizedBox(height: KnSpace.lg),
          Center(
            child: ExcludeSemantics(child: KnMoon(p: p, phase: 0.97, size: 150)),
          ),
          const SizedBox(height: KnSpace.md),
          Semantics(
            label: 'Ciclo lunar: Lua Nova destacada',
            excludeSemantics: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final ph in phases)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ph == 0.0 ? p.primary : Colors.transparent, width: 2),
                    ),
                    child: KnMoon(p: p, phase: ph, size: 28, glow: false),
                  ),
              ],
            ),
          ),
          const SizedBox(height: KnSpace.xl),
          Text('A Lua está invisível no céu, marcando o início de um novo ciclo.', style: KnText.body(p)),
          const SizedBox(height: KnSpace.md),
          Text(
            'Pessoas nascidas sob a Lua Nova costumam ser visionárias, cheias de ideias e energia para começar do zero.',
            style: KnText.bodyMuted(p),
          ),
        ],
      ),
    );
  }
}

class FactCardMock extends StatelessWidget {
  final KnPalette p;
  const FactCardMock({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return SummaryFrame(
      p: p,
      index: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KnEyebrow('Fato histórico · 26 mar 1991', p: p),
          const SizedBox(height: KnSpace.md),
          Semantics(header: true, child: Text('Nasce o Mercosul', style: KnText.title(p))),
          const SizedBox(height: KnSpace.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(KnRadius.md),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: p.dark
                            ? const [Color(0xFF2B3A7A), Color(0xFF16523F)]
                            : const [Color(0xFFDCE4FF), Color(0xFFCDEFD9)],
                      ),
                    ),
                    child: Icon(Icons.handshake_outlined, size: 72, color: p.ink.withValues(alpha: 0.35)),
                  ),
                  Positioned(
                    left: KnSpace.sm,
                    bottom: KnSpace.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: KnSpace.sm, vertical: KnSpace.xs),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(KnRadius.pill),
                      ),
                      child: const Text(
                        'Ilustração gerada por IA',
                        style: TextStyle(fontFamily: knSans, fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: KnSpace.lg),
          Text(
            'Brasil, Argentina, Paraguai e Uruguai assinaram o Tratado de Assunção, que criou o Mercado Comum do Sul.',
            style: KnText.body(p),
          ),
          const SizedBox(height: KnSpace.sm),
          Text('Até hoje o bloco reúne os quatro países fundadores.', style: KnText.bodyMuted(p)),
          const SizedBox(height: KnSpace.sm),
          Text('12 dias depois do seu nascimento', style: KnText.label(p).copyWith(color: p.accentText)),
        ],
      ),
    );
  }
}

class EndCardMock extends StatelessWidget {
  final KnPalette p;
  const EndCardMock({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return SummaryFrame(
      p: p,
      index: 4,
      last: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KnEyebrow('Seu resumo', p: p),
          const SizedBox(height: KnSpace.md),
          Semantics(header: true, child: Text('14 de março de 1991, em um cartão', style: KnText.title(p))),
          const SizedBox(height: KnSpace.lg),
          // Prévia do cartão compartilhável (9:16 reduzido).
          KnCard(
            p: p,
            child: Row(
              children: [
                KnMoon(p: p, phase: 0.0, size: 64, glow: false),
                const SizedBox(width: KnSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('35 anos · Lua Nova', style: KnText.headline(p)),
                      const SizedBox(height: KnSpace.xs),
                      Text('13.035 dias vividos\nNasci no ano do Mercosul', style: KnText.caption(p)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KnSpace.lg),
          KnButton(p: p, text: 'Compartilhar meu resumo', icon: Icons.ios_share_rounded),
          const SizedBox(height: KnSpace.md),
          KnButton(p: p, text: 'Ver outra data', kind: KnButtonKind.secondary),
          const SizedBox(height: KnSpace.xl),
          // Espaço de anúncio nativo, identificado e separado do conteúdo.
          Semantics(
            label: 'Anúncio',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(KnSpace.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(KnRadius.sm),
                border: Border.all(color: p.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: p.surfaceHi, borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      'Anúncio',
                      style: KnText.caption(p).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: KnSpace.sm),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: p.surfaceHi, borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(width: KnSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 12, width: 140, color: p.surfaceHi),
                            const SizedBox(height: 6),
                            Container(height: 10, width: 200, color: p.surfaceHi),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Erro (falha parcial)
// ---------------------------------------------------------------------------

class ErrorMock extends StatelessWidget {
  final KnPalette p;
  const ErrorMock({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return KnScreen(
      p: p,
      topBar: KnTopBar(
        p: p,
        leading: KnIconButton(p: p, icon: Icons.arrow_back_rounded, label: 'Voltar'),
        center: Text('14 mar 1991', style: KnText.label(p)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: KnSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 56, color: p.inkMuted),
              const SizedBox(height: KnSpace.lg),
              Semantics(
                header: true,
                liveRegion: true,
                child: Text(
                  'Não conseguimos buscar o fato histórico',
                  textAlign: TextAlign.center,
                  style: KnText.title(p).copyWith(fontSize: 26),
                ),
              ),
              const SizedBox(height: KnSpace.md),
              Text(
                'Parece que você está sem internet. Tempo de vida, concepção e fase da lua já estão prontos.',
                textAlign: TextAlign.center,
                style: KnText.bodyMuted(p),
              ),
              const SizedBox(height: KnSpace.xl),
              KnButton(p: p, text: 'Tentar de novo', icon: Icons.refresh_rounded),
              const SizedBox(height: KnSpace.md),
              KnButton(p: p, text: 'Ver o que já está pronto', kind: KnButtonKind.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Folha de tokens (paleta e tipografia) para a aprovação
// ---------------------------------------------------------------------------

class TokensSheet extends StatelessWidget {
  final KnPalette p;
  const TokensSheet({super.key, required this.p});

  Widget _swatch(String name, Color c, Color on) => Expanded(
    child: Container(
      height: 64,
      margin: const EdgeInsets.only(right: KnSpace.sm),
      padding: const EdgeInsets.all(KnSpace.sm),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(KnRadius.sm),
        border: Border.all(color: p.outline),
      ),
      alignment: Alignment.bottomLeft,
      child: Text(
        name,
        style: TextStyle(fontFamily: knSans, fontSize: 11, fontWeight: FontWeight.w600, color: on),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    String hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    return KnScreen(
      p: p,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KnSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KnEyebrow(p.dark ? 'Céu de Nascimento · Noite' : 'Céu de Nascimento · Amanhecer', p: p),
            const SizedBox(height: KnSpace.lg),
            Row(
              children: [
                _swatch('bg ${hex(p.bg)}', p.bg, p.ink),
                _swatch('surface ${hex(p.surface)}', p.surface, p.ink),
                _swatch('outline', p.outline, p.ink),
              ],
            ),
            const SizedBox(height: KnSpace.sm),
            Row(
              children: [
                _swatch('ink ${hex(p.ink)}', p.ink, p.bg),
                _swatch('muted ${hex(p.inkMuted)}', p.inkMuted, p.bg),
                _swatch('primary ${hex(p.primary)}', p.primary, p.onPrimary),
              ],
            ),
            const SizedBox(height: KnSpace.sm),
            Row(
              children: [
                _swatch('accent ${hex(p.accentText)}', p.accentText, p.bg),
                _swatch('lavender ${hex(p.lavender)}', p.lavender, p.bg),
                _swatch('moon ${hex(p.moon)}', p.moon, const Color(0xFF15172E)),
              ],
            ),
            const SizedBox(height: KnSpace.xxl),
            Text('Display 44 · DM Serif', style: KnText.caption(p)),
            Text('35 anos', style: KnText.display(p)),
            const SizedBox(height: KnSpace.md),
            Text('Title 30 · DM Serif', style: KnText.caption(p)),
            Text('Quando você nasceu?', style: KnText.title(p)),
            const SizedBox(height: KnSpace.md),
            Text('Headline 20 · Inter SemiBold', style: KnText.caption(p)),
            Text('35 anos · Lua Nova', style: KnText.headline(p)),
            const SizedBox(height: KnSpace.md),
            Text('Body 16/24 · Inter', style: KnText.caption(p)),
            Text('A Lua está invisível no céu, marcando o início de um novo ciclo.', style: KnText.body(p)),
            const SizedBox(height: KnSpace.md),
            KnEyebrow('Eyebrow 12 · Inter SemiBold', p: p),
            const SizedBox(height: KnSpace.xl),
            Row(
              children: [
                Expanded(
                  child: KnButton(p: p, text: 'Primário'),
                ),
                const SizedBox(width: KnSpace.md),
                Expanded(
                  child: KnButton(p: p, text: 'Secundário', kind: KnButtonKind.secondary),
                ),
              ],
            ),
            const SizedBox(height: KnSpace.lg),
            KnStoryProgress(p: p, count: 5, current: 2),
            const SizedBox(height: KnSpace.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final ph in const [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875])
                  KnMoon(p: p, phase: ph, size: 36, glow: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
