import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/components/kn_button.dart';
import 'package:knowhen/core/theme/components/kn_story_page.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:knowhen/features/share/domain/share_card_content.dart';
import 'package:knowhen/features/share/presentation/widgets/share_card.dart';

/// Cartão final do resumo (DXF-9, 4.9): a prévia do cartão compartilhável (9:16) e "Compartilhar meu resumo". "Escolher
/// outra data" e o anúncio nativo, abaixo das ações, são do rodapé da casca.
class SummaryEndSection extends StatelessWidget {
  const SummaryEndSection({super.key, required this.birthDate, required this.content, required this.onShare});

  final DateTime birthDate;

  /// O que a prévia mostra: o mesmo conteúdo do cartão que sai no compartilhamento.
  final ShareCardContent content;
  final VoidCallback onShare;

  /// Altura da prévia; a largura sai da proporção 9:16. Proporcional à tela para "Compartilhar meu resumo" caber sem
  /// rolar a 100% de fonte, mesmo com o anúncio nativo abaixo (em 360x640 são ~180 dp).
  static double previewHeightFor(double screenHeight) => (screenHeight * 0.28).clamp(150.0, 240.0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return KnStoryPage(
      eyebrow: l10n.endEyebrow,
      title: l10n.endTitle(DateText.dayMonthYear(birthDate)),
      children: [
        Center(
          child: _Preview(content: content, label: l10n.endPreviewLabel, height: previewHeightFor(MediaQuery.sizeOf(context).height)),
        ),
        KnButton(label: l10n.endShare, icon: Icons.ios_share_rounded, onPressed: onShare),
      ],
    );
  }
}

/// O [ShareCard] real, em miniatura: o que se vê aqui é o que sai na imagem. Para o leitor de tela é uma imagem só,
/// descrita pelos textos do cartão.
class _Preview extends StatelessWidget {
  const _Preview({required this.content, required this.label, required this.height});

  final ShareCardContent content;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    return Semantics(
      image: true,
      label: [label, content.highlight, ...content.details].join('. '),
      excludeSemantics: true,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(KnRadius.md),
          border: Border.all(color: c.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: ShareCard.logicalSize.width / ShareCard.logicalSize.height,
          child: FittedBox(child: ShareCard(content: content)),
        ),
      ),
    );
  }
}
