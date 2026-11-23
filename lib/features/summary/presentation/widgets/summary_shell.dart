import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/components/kn_background.dart';
import 'package:knowhen/core/theme/components/kn_button.dart';
import 'package:knowhen/core/theme/components/kn_icon_button.dart';
import 'package:knowhen/core/theme/components/kn_story_progress.dart';
import 'package:knowhen/core/theme/components/kn_top_bar.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/share/domain/share_section.dart';

/// Um cartão do resumo: o conteúdo, o nome dele no Analytics e a seção que ele oferece para compartilhar
/// (`null` quando não há o que compartilhar).
typedef SummaryCard = ({String analyticsName, Widget section, ShareSection? share});

/// Casca do resumo (DXF-9, 4.4): cartões horizontais no padrão "stories", com barra de progresso em segmentos
/// no topo e, no rodapé, compartilhar *este* cartão e "Próximo". Avança com o botão, com toque na metade direita
/// (a esquerda volta) ou com swipe. No último cartão o botão leva a outra data, em vez de uma seta sem destino.
class SummaryShell extends StatefulWidget {
  const SummaryShell({
    super.key,
    required this.birthDate,
    required this.cards,
    required this.menu,
    required this.onClose,
    required this.onShare,
    required this.onChooseAnotherDate,
    this.initialPage = 0,
    this.controller,
    this.onPageViewed,
  });

  final DateTime birthDate;
  final List<SummaryCard> cards;

  /// Menu de opções do resumo (salvar a data, escolher outra, compartilhar tudo), no canto superior direito.
  final Widget menu;
  final VoidCallback onClose;
  final void Function(ShareSection section) onShare;
  final VoidCallback onChooseAnotherDate;
  final int initialPage;

  /// Controle da página, para quem precisa levar o resumo a outro cartão (o "Ver o que já está pronto" do fato). Sem
  /// ele a casca cria o seu a partir de [initialPage]; com ele, quem o passa é quem o descarta.
  final PageController? controller;

  /// Chamado com o índice de cada cartão que passa a ser exibido, inclusive o inicial.
  final void Function(int index)? onPageViewed;

  @override
  State<SummaryShell> createState() => _SummaryShellState();
}

class _SummaryShellState extends State<SummaryShell> {
  late final PageController _controller = widget.controller ?? PageController(initialPage: widget.initialPage);
  late int _current = _controller.initialPage;
  bool _started = false;

  static const Duration _pageDuration = Duration(milliseconds: 300);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onPageViewed?.call(_current);
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.cards.length || index == _current) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(index, duration: _pageDuration, curve: Curves.easeOutCubic);
    }
  }

  void _next() {
    // Toque leve de háptico no "Próximo" (2.5). Sem plugin de vibração (testes, emulador) é só ignorado.
    unawaited(HapticFeedback.selectionClick().catchError((_) {}));
    _goTo(_current + 1);
  }

  void _onTapUp(TapUpDetails details, double width) {
    _goTo(details.localPosition.dx > width / 2 ? _current + 1 : _current - 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.kn;
    final cards = widget.cards;
    final isLast = _current == cards.length - 1;
    final share = cards[_current].share;

    return Scaffold(
      backgroundColor: c.bg,
      body: KnBackground(
        child: SafeArea(
          child: Column(
            children: [
              KnTopBar(
                sideWidth: 2 * KnSize.touchTarget + KnSpace.sm,
                leading: KnIconButton(icon: Icons.close_rounded, label: l10n.summaryClose, onPressed: widget.onClose),
                center: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(DateText.compact(widget.birthDate), style: context.knText.label),
                ),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [widget.menu, const ThemeButton()]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: KnSpace.xl),
                child: Semantics(
                  liveRegion: true,
                  child: KnStoryProgress(
                    count: cards.length,
                    current: _current,
                    semanticsLabel: l10n.summaryProgress(_current + 1, cards.length),
                  ),
                ),
              ),
              const SizedBox(height: KnSpace.sm),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Fora da árvore de Semantics: o toque nas metades é atalho para quem enxerga. "Próximo" e o próprio
                    // `PageView` já dão navegação acessível, e o gesto criaria um nó `tap` do tamanho do cartão, sem rótulo.
                    return GestureDetector(
                      excludeFromSemantics: true,
                      behavior: HitTestBehavior.translucent,
                      onTapUp: (details) => _onTapUp(details, constraints.maxWidth),
                      child: PageView(
                        controller: _controller,
                        onPageChanged: (index) {
                          setState(() => _current = index);
                          widget.onPageViewed?.call(index);
                        },
                        children: [for (final card in cards) card.section],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(KnSpace.xl, KnSpace.sm, KnSpace.xl, KnSpace.lg),
                child: Row(
                  children: [
                    if (share != null) ...[
                      KnIconButton(icon: Icons.ios_share_rounded, label: l10n.summaryShareCard, onPressed: () => widget.onShare(share)),
                      const SizedBox(width: KnSpace.md),
                    ],
                    Expanded(
                      child: isLast
                          ? KnButton(label: l10n.chooseAnotherDate, kind: KnButtonKind.secondary, onPressed: widget.onChooseAnotherDate)
                          : KnButton(label: l10n.next, icon: Icons.arrow_forward_rounded, onPressed: _next),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
