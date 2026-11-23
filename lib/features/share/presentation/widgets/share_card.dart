import 'package:flutter/material.dart';
import 'package:knowhen/core/config/app_links.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/components/kn_background.dart';
import 'package:knowhen/core/theme/components/kn_moon.dart';
import 'package:knowhen/core/theme/components/kn_stat.dart';
import 'package:knowhen/core/theme/tokens/kn_colors.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:knowhen/features/share/domain/share_card_content.dart';

/// Card no formato Stories (9:16), no "Céu de Nascimento" (DXF-9, 4.9).
///
/// Desenhado em [logicalSize] (360×640) sempre com a paleta noturna, qualquer que seja o tema do app, e sem acompanhar
/// a escala de fonte do aparelho: a imagem compartilhada é a mesma para todo mundo. Capturado com `pixelRatio`
/// [exportPixelRatio] vira 1080×1920.
class ShareCard extends StatelessWidget {
  static const logicalSize = Size(360, 640);
  static const exportPixelRatio = 3.0;

  static const _horizontalPadding = 32.0;

  final ShareCardContent content;

  const ShareCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const night = KnColors.night;
    return Theme(
      data: theme.copyWith(brightness: Brightness.dark, extensions: [night, KnTextStyles.from(night)]),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Builder(builder: _buildCard),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.kn;
    final text = context.knText;

    return SizedBox.fromSize(
      size: logicalSize,
      child: KnBackground(
        child: Padding(
          // Margens maiores em cima e embaixo: a interface do Stories cobre essas faixas.
          padding: const EdgeInsets.fromLTRB(_horizontalPadding, 72, _horizontalPadding, 56),
          child: Column(
            children: [
              KnEyebrow(content.title),
              const SizedBox(height: KnSpace.xl),
              _Illustration(content: content),
              const SizedBox(height: KnSpace.xl),
              // Destaque e detalhes encolhem para caber, em vez de estourar ou cortar o texto.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: logicalSize.width - _horizontalPadding * 2,
                    child: Column(
                      children: [
                        Text(content.highlight, textAlign: TextAlign.center, style: text.display),
                        const SizedBox(height: KnSpace.lg),
                        for (final line in content.details)
                          Padding(
                            padding: const EdgeInsets.only(bottom: KnSpace.sm),
                            child: Text(line, textAlign: TextAlign.center, style: text.body),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(content.birthLabel, textAlign: TextAlign.center, style: text.caption.copyWith(color: c.inkMuted)),
              const SizedBox(height: KnSpace.lg),
              Text(l10n.shareWatermark, textAlign: TextAlign.center, style: text.label.copyWith(color: c.accentText)),
              const SizedBox(height: KnSpace.xs),
              Text(AppLinks.storeUrl, textAlign: TextAlign.center, maxLines: 2, style: text.caption.copyWith(fontSize: 9, color: c.inkMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final ShareCardContent content;

  const _Illustration({required this.content});

  static const _size = 150.0;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    final moonFraction = content.moonFraction;
    // A lua é desenhada na fase exata, sem baixar imagem. O Brasil fica no hemisfério sul: a Lua se vê espelhada.
    if (moonFraction != null) return KnMoon(phase: moonFraction, size: _size, southernHemisphere: true);

    final icon = Icon(content.icon, size: 96, color: c.primary);
    final imageUrl = content.imageUrl;

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(KnRadius.lg), border: Border.all(color: c.outline)),
      child: imageUrl == null
          ? icon
          : Image.network(imageUrl, width: _size, height: _size, fit: BoxFit.cover, errorBuilder: (_, _, _) => icon),
    );
  }
}
