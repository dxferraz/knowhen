import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/functions/life_milestones.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/life_profile_service.dart';
import 'package:knowhen/core/services/milestone_notifier.dart';
import 'package:knowhen/core/theme/widgets/custom_button.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:provider/provider.dart';

/// Card "Próximo marco": contagem regressiva e o botão "Me avise".
class NextMilestoneSection extends StatelessWidget {
  const NextMilestoneSection({super.key, required this.birthDate, required this.birthTime, this.now});

  final DateTime birthDate;
  final TimeOfDay? birthTime;

  /// Só para testes.
  final DateTime? now;

  Future<void> _enable(BuildContext context, LifeProfileService profile) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await profile.enableReminders(birthDate, birthTime);
    switch (outcome) {
      case RemindersOutcome.enabled:
        break;
      case RemindersOutcome.permissionDenied:
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.notificationPermissionDenied),
            action: SnackBarAction(label: l10n.openSettings, onPressed: profile.openNotificationSettings),
          ),
        );
      case RemindersOutcome.failed:
        messenger.showSnackBar(SnackBar(content: Text(l10n.reminderFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final profile = context.watch<LifeProfileService>();

    final today = now ?? DateTime.now();
    final milestone = nextMilestone(birthDate, today, birthTime: birthTimeOf(birthTime));
    final remindersActive = profile.remindersEnabled && profile.saved?.date == DateUtils.dateOnly(birthDate);

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8.0,
          children: [
            SecondaryH2(
              l10n.nextMilestoneTitle,
              textAlign: TextAlign.center,
              color: colors.onSurface,
            ),
            Container(
              key: const Key('next_milestone_card'),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: colors.primaryContainer,
              ),
              child: Column(
                children: [
                  PrimaryH3(
                    milestoneName(l10n, milestone),
                    textAlign: TextAlign.center,
                    color: colors.onPrimaryContainer,
                  ),
                  const SizedBox(height: 10),
                  PrimaryH4(
                    l10n.milestoneCountdown(milestone.daysUntil(today)),
                    textAlign: TextAlign.center,
                    color: colors.onPrimaryContainer,
                  ),
                  const SizedBox(height: 10),
                  PrimaryParagraphM(
                    l10n.milestoneOnDate(DateText.numeric(milestone.date)),
                    textAlign: TextAlign.center,
                    color: colors.onPrimaryContainer,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (remindersActive) ...[
              PrimaryParagraphM(
                l10n.remindersEnabledInfo,
                textAlign: TextAlign.center,
                color: colors.onSurface,
              ),
              TextButton(
                onPressed: profile.disableReminders,
                child: Text(l10n.disableReminders),
              ),
            ] else ...[
              CustomButton(
                onPressed: () => _enable(context, profile),
                text: l10n.remindMeButton,
                backgroundColor: colors.onSurfaceVariant,
              ),
              if (profile.saved?.date != DateUtils.dateOnly(birthDate))
                PrimaryCaption(
                  l10n.remindersSaveDateInfo,
                  textAlign: TextAlign.center,
                  color: colors.onSurface,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
