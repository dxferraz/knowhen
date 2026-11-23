import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/ad_service.dart';
import 'package:knowhen/core/theme/tokens/kn_colors.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:provider/provider.dart';

/// O visual do anúncio nativo nas cores do tema em que ele foi pedido: o anúncio é uma caixa própria (visão nativa),
/// então leva o fundo e o texto junto, e continua legível se a pessoa trocar o tema depois.
NativeTemplateStyle nativeAdStyle(KnColors c) {
  NativeTemplateTextStyle text(Color color, {Color? background}) =>
      NativeTemplateTextStyle(
        textColor: color,
        backgroundColor: background,
        style: NativeTemplateFontStyle.normal,
      );
  return NativeTemplateStyle(
    templateType: TemplateType.small,
    mainBackgroundColor: c.surface,
    cornerRadius: KnRadius.sm,
    primaryTextStyle: text(c.ink),
    secondaryTextStyle: text(c.inkMuted),
    tertiaryTextStyle: text(c.inkMuted),
    callToActionTextStyle: text(c.onPrimary, background: c.primary),
  );
}

/// Espaço do anúncio nativo no cartão final (DXF-9, 4.9): o rótulo "Anúncio" e, separado do conteúdo, o anúncio
/// já carregado. Quem o carregou é quem o descarta.
class NativeAdSlot extends StatelessWidget {
  const NativeAdSlot({super.key, required this.ad});

  final NativeAd ad;

  /// Altura mínima do modelo pequeno do AdMob.
  static const double adHeight = 100;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.kn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: KnSpace.xs,
      children: [
        Text(
          l10n.adLabel,
          style: context.knText.caption.copyWith(color: c.inkMuted),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(KnRadius.sm),
          child: SizedBox(
            height: adHeight,
            child: context.read<AdService>().nativeAdView(ad),
          ),
        ),
      ],
    );
  }
}
