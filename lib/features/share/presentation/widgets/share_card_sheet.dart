import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:knowhen/core/config/app_links.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/constants/spacing.dart';
import 'package:knowhen/features/share/data/share_card_exporter.dart';
import 'package:knowhen/features/share/domain/share_card_content.dart';
import 'package:knowhen/features/share/domain/share_section.dart';
import 'package:knowhen/features/share/presentation/widgets/share_card.dart';
import 'package:share_plus/share_plus.dart';

/// Abre a folha de compartilhamento nativa com o PNG [png] e a mensagem [text].
///
/// [origin] ancora o popover no iPad.
typedef ShareImage = Future<ShareResultStatus> Function(Uint8List png, String text, Rect? origin);

Future<ShareResultStatus> _shareWithPlatform(Uint8List png, String text, Rect? origin) async {
  final result = await ShareCardExporter.sharePng(png, text: text, fileName: 'knowhen_card.png', origin: origin);
  return result.status;
}

/// Pré-visualização do card com a opção de privacidade e o botão que gera o PNG e compartilha.
class ShareCardSheet extends StatefulWidget {
  final ShareSection section;
  final ShareCardData data;

  /// Chamado quando o usuário concluiu o compartilhamento (não cancelou a folha nativa).
  final ValueChanged<ShareSection>? onShared;
  final ShareImage shareImage;

  const ShareCardSheet({super.key, required this.section, required this.data, this.onShared, this.shareImage = _shareWithPlatform});

  static Future<void> show(
    BuildContext context, {
    required ShareSection section,
    required ShareCardData data,
    ValueChanged<ShareSection>? onShared,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ShareCardSheet(section: section, data: data, onShared: onShared),
    );
  }

  @override
  State<ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<ShareCardSheet> {
  final _boundaryKey = GlobalKey();
  bool _hideFullDate = false;
  bool _precacheStarted = false;
  bool _imageReady = false;
  bool _sharing = false;
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precacheStarted) return;
    _precacheStarted = true;
    _precacheImage();
  }

  /// A imagem remota precisa estar carregada antes de capturar o card, senão o PNG sai sem ela.
  Future<void> _precacheImage() async {
    final imageUrl = _content(AppLocalizations.of(context)!).imageUrl;
    if (imageUrl != null) {
      try {
        await precacheImage(NetworkImage(imageUrl), context, onError: (_, _) {});
      } catch (_) {
        // O card cai no ícone da seção.
      }
    }
    if (mounted) setState(() => _imageReady = true);
  }

  ShareCardContent _content(AppLocalizations l10n) =>
      ShareCardContent.build(l10n, widget.section, widget.data, hideFullDate: _hideFullDate);

  Future<void> _share(AppLocalizations l10n) async {
    setState(() {
      _sharing = true;
      _failed = false;
    });
    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
      final boundary = _boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final png = await ShareCardExporter.capturePng(boundary, pixelRatio: ShareCard.exportPixelRatio);
      final status = await widget.shareImage(png, l10n.shareMessage(AppLinks.storeUrl), origin);
      if (status != ShareResultStatus.dismissed) widget.onShared?.call(widget.section);
    } catch (e) {
      debugPrint('Error sharing card: $e');
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.shareSheetTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.medium),
          Flexible(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FittedBox(
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: ShareCard(content: _content(l10n)),
                  ),
                ),
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.shareHideFullDate),
            subtitle: Text(l10n.shareHideFullDateHint),
            value: _hideFullDate,
            onChanged: _sharing ? null : (value) => setState(() => _hideFullDate = value),
          ),
          if (_failed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.small),
              child: Text(
                l10n.shareError,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.error),
              ),
            ),
          FilledButton.icon(
            onPressed: _imageReady && !_sharing ? () => _share(l10n) : null,
            icon: _sharing
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.ios_share_rounded),
            label: Text(_sharing ? l10n.shareGenerating : l10n.shareAction),
          ),
        ],
      ),
    );
  }
}
