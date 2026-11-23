import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/components/kn_button.dart';
import 'package:knowhen/core/theme/components/kn_story_page.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:knowhen/features/brazil_curiosity/domain/fact_text.dart';

typedef ImageProviderFor = ImageProvider Function(String url);

/// Cartão "Fato histórico" (DXF-9, 4.8 e 4.10): o fato do mês do nascimento, com a ilustração quando há, e a linha
/// fixa que o liga à pessoa (o fato vem do mês e ano, então a ponte em dias não se calcula). Se só a parte remota
/// falhar, o cartão explica e oferece tentar de novo ou voltar ao que já está pronto.
class BrazilCuriositySection extends StatelessWidget {
  const BrazilCuriositySection({
    super.key,
    required this.birthDate,
    required this.imageUrl,
    required this.curiosity,
    this.loadFailed = false,
    this.onRetry,
    this.onSeeReady,
    this.retrying = false,
    this.imageProviderFor = NetworkImage.new,
  });

  final DateTime birthDate;
  final String imageUrl;

  /// `null` mostra um estado vazio: sem fato para o mês/ano ou, com [loadFailed], erro ao carregar.
  final String? curiosity;
  final bool loadFailed;

  /// "Tentar de novo" do estado de erro; sem ele o botão não aparece.
  final VoidCallback? onRetry;

  /// "Ver o que já está pronto" do estado de erro; sem ele o botão não aparece.
  final VoidCallback? onSeeReady;

  /// Há uma nova tentativa em andamento: "Tentar de novo" fica desabilitado.
  final bool retrying;

  /// Só para testes: troca o download da imagem.
  final ImageProviderFor imageProviderFor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = context.knText;
    final curiosity = this.curiosity;

    if (curiosity == null) {
      return loadFailed ? _buildError(context, l10n) : _buildEmpty(l10n, text);
    }

    final (:title, :body) = splitFact(curiosity);

    return KnStoryPage(
      eyebrow: l10n.factEyebrowDated(DateText.monthYear(birthDate)),
      title: title,
      children: [
        if (imageUrl.isNotEmpty) _FactImage(provider: imageProviderFor(imageUrl), badge: l10n.factAiBadge),
        if (body.isNotEmpty) Text(body, style: text.body),
        Text(l10n.factBirthMonthBridge, style: text.bodyMuted),
      ],
    );
  }

  Widget _buildEmpty(AppLocalizations l10n, KnTextStyles text) {
    return KnStoryPage(
      eyebrow: l10n.factEyebrow,
      title: l10n.factEmptyTitle,
      children: [Text(l10n.factEmptyBody, style: text.bodyMuted)],
    );
  }

  Widget _buildError(BuildContext context, AppLocalizations l10n) {
    final c = context.kn;
    final text = context.knText;
    return KnStoryPage(
      eyebrow: l10n.factEyebrow,
      title: l10n.factErrorTitle,
      children: [
        ExcludeSemantics(child: Icon(Icons.cloud_off_rounded, size: 56, color: c.inkMuted)),
        Text(l10n.factErrorBody, style: text.bodyMuted),
        if (onRetry != null) KnButton(label: l10n.factRetry, icon: Icons.refresh_rounded, onPressed: retrying ? null : onRetry),
        if (onSeeReady != null) KnButton(label: l10n.factSeeWhatIsReady, kind: KnButtonKind.secondary, onPressed: onSeeReady),
      ],
    );
  }
}

/// Ilustração 16:10 com o selo "Ilustração gerada por IA" sobre ela. Se a imagem falhar, o bloco inteiro some, junto
/// com o selo.
class _FactImage extends StatefulWidget {
  const _FactImage({required this.provider, required this.badge});

  final ImageProvider provider;
  final String badge;

  @override
  State<_FactImage> createState() => _FactImageState();
}

class _FactImageState extends State<_FactImage> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();
    final c = context.kn;

    return ClipRRect(
      borderRadius: BorderRadius.circular(KnRadius.md),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: c.surface),
            Image(
              image: widget.provider,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (context, error, stackTrace) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _failed = true);
                });
                return const SizedBox.shrink();
              },
            ),
            Positioned(
              left: KnSpace.sm,
              bottom: KnSpace.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: KnSpace.sm, vertical: KnSpace.xs),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(KnRadius.pill)),
                child: Text(widget.badge, style: context.knText.caption.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
