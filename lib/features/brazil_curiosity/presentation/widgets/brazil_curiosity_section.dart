import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/components/kn_button.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';

class BrazilCuriositySection extends StatelessWidget {
  final String imageUrl;

  /// `null` mostra um estado vazio: sem curiosidade para o mês/ano ou, com [loadFailed], erro ao carregar.
  final String? curiosity;
  final bool loadFailed;

  /// "Tentar de novo" do estado de erro; sem ele o erro fica só com a mensagem.
  final VoidCallback? onRetry;

  /// Há uma nova tentativa em andamento: o botão fica desabilitado.
  final bool retrying;
  const BrazilCuriositySection({
    super.key,
    required this.imageUrl,
    required this.curiosity,
    this.loadFailed = false,
    this.onRetry,
    this.retrying = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final curiosity = this.curiosity;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SecondaryH1(
              l10n.historicalFact,
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: curiosity == null ? _buildEmpty(context, l10n) : _buildFact(context, l10n, curiosity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    final message = PrimaryParagraphS(
      loadFailed ? l10n.historicalFactLoadError : l10n.noHistoricalFact,
      textAlign: TextAlign.center,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    );
    if (!loadFailed || onRetry == null) return message;
    return Column(
      children: [
        message,
        const SizedBox(height: 16),
        KnButton(label: l10n.factRetry, kind: KnButtonKind.secondary, onPressed: retrying ? null : onRetry),
      ],
    );
  }

  Widget _buildFact(BuildContext context, AppLocalizations l10n, String curiosity) {
    final factParagraphs = curiosity.split('. ');

    return Column(
      children: [
        PrimaryParagraphS(
          l10n.firstFactParagraph(factParagraphs.first),
          textAlign: TextAlign.center,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        const SizedBox(height: 15),
        Column(
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.hardEdge,
              width: 250,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                          ? child
                          : CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimaryContainer),
                      errorBuilder: (context, error, stackTrace) => Text(l10n.noImageForFact, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    )
                  : Text(l10n.noImageForFact, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
            ),
            const SizedBox(height: 5),
            SecondaryCaption(
              l10n.aiGeneratedImage,
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ],
        ),
        const SizedBox(height: 15),
        PrimaryParagraphS(
          l10n.lastFactParagraph(factParagraphs.last),
          textAlign: TextAlign.center,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ],
    );
  }
}
