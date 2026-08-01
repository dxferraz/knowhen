import 'package:auto_route/auto_route.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/theme/theme.dart';
import 'package:knowhen/features/summary/presentation/pages/summary_page.dart';

@RoutePage()
class BirthdatePage extends StatefulWidget {
  const BirthdatePage({super.key});

  @override
  State<BirthdatePage> createState() => _BirthdatePageState();
}

class _BirthdatePageState extends State<BirthdatePage> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  DateTime? birthDate;
  TimeOfDay? _birthTime;

  Future<void> _selecionarHora(BuildContext context) async {
    final TimeOfDay? horaEscolhida = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 00),
      helpText: 'Você sabe a hora exata do seu nascimento?',
      cancelText: 'Não sei',
      confirmText: 'Confirmar',
      initialEntryMode: TimePickerEntryMode.dialOnly,
      routeSettings: const RouteSettings(name: '/summary'),
      useRootNavigator: true,
    );

    if (horaEscolhida != null && horaEscolhida != _birthTime) {
      setState(() => _birthTime = horaEscolhida);
    }
  }

  Future<void> _submit() async {
    final DateTime? selected = birthDate;
    if (selected == null) return;

    await _selecionarHora(context);
    if (!mounted) return;

    final int age = DateTime.now().difference(selected).inDays ~/ 365;
    AnalyticsService.instance.logBirthdateSubmitted(
      age: age,
      hasBirthTime: _birthTime != null,
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            SummaryPage(birthDate: selected, birthTime: _birthTime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final bool hasDate = birthDate != null;

    return GlassScaffold(
      appBar: const GlassAppBar(
        titleWidget: AppLogo(),
        automaticallyImplyLeading: false,
        bottomDivider: false,
        actions: [ThemeButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenGutter,
          AppSpacing.medium,
          AppSpacing.screenGutter,
          AppSpacing.xxLarge,
        ),
        children: [
          GlassReveal(
            order: 0,
            child: AppText.headline(
              l10n.selectBirthdateTitle,
              align: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          GlassReveal(
            order: 1,
            child: GlassCard(
              padding: const EdgeInsets.all(AppSpacing.small),
              child: DatePicker(
                maxDate: DateTime(2024, 12, 31),
                minDate: DateTime(1925, 1, 1),
                initialPickerType: PickerType.years,
                selectedDate: birthDate,
                displayedDate: birthDate ??
                    DateTime.now().subtract(const Duration(days: 365 * 25)),
                onDateSelected: (value) => setState(() => birthDate = value),
                padding: const EdgeInsets.all(AppSpacing.small),
                theme: DatePickerPlusTheme(
                  headerTheme: HeaderTheme(
                    centerLeadingDate: true,
                    leadingDateTextStyle: AppTypography.titleMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                    forwardArrowWidget: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: colors.primary,
                      size: 18,
                    ),
                    backwardArrowWidget: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: colors.primary,
                      size: 18,
                    ),
                  ),
                  daysPickerTheme: DaysPickerTheme(
                    daysOfTheWeekTheme: DaysOfTheWeekTheme(
                      textStyle: AppTypography.labelSmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                    selectedCellDecoration: BoxDecoration(
                      gradient: context.glass.brandGradient,
                      shape: BoxShape.circle,
                    ),
                    inkResponseTheme: InkResponseTheme(
                      splashColor: colors.primary.withValues(alpha: 0.18),
                      highlightColor: colors.primary.withValues(alpha: 0.10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          GlassReveal(
            order: 2,
            child: AnimatedOpacity(
              duration: AppMotion.normal,
              opacity: hasDate ? 1 : 0,
              child: Center(
                child: GlassBadge(
                  icon: Icons.event_rounded,
                  label: hasDate ? _dateFormat.format(birthDate!) : '',
                  color: colors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomBar: GlassBottomBar(
        child: GlassButton(
          label: l10n.continueLabel,
          size: AppButtonSize.large,
          expand: true,
          trailingIcon: Icons.arrow_forward_rounded,
          // Sem data selecionada o botão fica visível porém inerte: some do
          // caminho sem sumir da tela, então o usuário sabe qual é o próximo
          // passo desde o primeiro segundo.
          onPressed: hasDate ? _submit : null,
        ),
      ),
    );
  }
}
