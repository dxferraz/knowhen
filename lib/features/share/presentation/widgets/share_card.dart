import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knowhen/core/config/app_links.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/features/share/domain/share_card_content.dart';

/// Card no formato Stories (9:16).
///
/// Desenhado em [logicalSize] (360×640) com cores fixas, independentes do tema do app, para ficar
/// legível nos temas claro e escuro. Capturado com `pixelRatio` [exportPixelRatio] vira 1080×1920.
class ShareCard extends StatelessWidget {
  static const logicalSize = Size(360, 640);
  static const exportPixelRatio = 3.0;

  static const background = Color(0xFF14142B);
  static const onBackground = Color(0xFFF8FAFC);
  static const muted = Color(0xFFB4B8D0);
  static const accent = Color(0xFF60A5FA);

  static const _horizontalPadding = 32.0;

  final ShareCardContent content;

  const ShareCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final font = GoogleFonts.inter().fontFamily;

    return SizedBox.fromSize(
      size: logicalSize,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [background, Color(0xFF1F1F46)]),
        ),
        child: Padding(
          // Margens maiores em cima e embaixo: a interface do Stories cobre essas faixas.
          padding: const EdgeInsets.fromLTRB(_horizontalPadding, 72, _horizontalPadding, 56),
          child: Column(
            children: [
              Text(
                content.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: font, fontSize: 20, fontWeight: FontWeight.w600, color: muted),
              ),
              const SizedBox(height: 24),
              _Illustration(content: content),
              const SizedBox(height: 24),
              // Destaque e detalhes encolhem para caber, em vez de estourar ou cortar o texto.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: logicalSize.width - _horizontalPadding * 2,
                    child: Column(
                      children: [
                        Text(
                          content.highlight,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: font, fontSize: 32, height: 1.2, fontWeight: FontWeight.w800, color: onBackground),
                        ),
                        const SizedBox(height: 16),
                        for (final line in content.details)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              line,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: font,
                                fontSize: 16,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                color: onBackground,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                content.birthLabel,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: font, fontSize: 14, fontWeight: FontWeight.w500, color: muted),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.shareWatermark,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: font, fontSize: 16, fontWeight: FontWeight.w700, color: accent),
              ),
              const SizedBox(height: 4),
              Text(
                AppLinks.storeUrl,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(fontFamily: font, fontSize: 9, fontWeight: FontWeight.w500, color: muted),
              ),
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
    final icon = Icon(content.icon, size: 96, color: ShareCard.accent);
    final imageUrl = content.imageUrl;

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: ShareCard.accent.withAlpha(30), borderRadius: BorderRadius.circular(32)),
      child: imageUrl == null
          ? icon
          : Image.network(imageUrl, width: _size, height: _size, fit: BoxFit.cover, errorBuilder: (_, _, _) => icon),
    );
  }
}
