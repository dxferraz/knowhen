import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/calculate_age.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/theme/components/kn_background.dart';
import 'package:knowhen/core/theme/components/kn_button.dart';
import 'package:knowhen/core/theme/components/kn_icon_button.dart';
import 'package:knowhen/core/theme/components/kn_top_bar.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:knowhen/core/theme/widgets/app_logo.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/birthdate/domain/birthdate_input.dart';
import 'package:knowhen/features/birthdate/presentation/widgets/birth_time_card.dart';
import 'package:knowhen/features/birthdate/presentation/widgets/date_field.dart';
import 'package:knowhen/features/summary/presentation/pages/summary_page.dart';
import 'package:provider/provider.dart';

/// Data de nascimento em uma tela só: três campos Dia, Mês e Ano, hora opcional no mesmo lugar e um CTA
/// sempre visível (DXF-9, 4.2).
class BirthdatePage extends StatefulWidget {
  /// Data já escolhida (ao voltar do resumo para escolher outra).
  final DateTime? initialBirthDate;

  const BirthdatePage({super.key, this.initialBirthDate});

  @override
  State<BirthdatePage> createState() => _BirthdatePageState();
}

class _BirthdatePageState extends State<BirthdatePage> {
  final _day = TextEditingController();
  final _month = TextEditingController();
  final _year = TextEditingController();
  final _dayFocus = FocusNode();
  final _monthFocus = FocusNode();
  final _yearFocus = FocusNode();
  final _scroll = ScrollController();

  bool _hasBirthTime = false;
  TimeOfDay _birthTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  void initState() {
    super.initState();
    final initial = widget.initialBirthDate;
    if (initial != null) _fill(initial);
  }

  @override
  void dispose() {
    for (final controller in [_day, _month, _year]) {
      controller.dispose();
    }
    for (final focus in [_dayFocus, _monthFocus, _yearFocus]) {
      focus.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  void _fill(DateTime date) {
    _day.text = date.day.toString().padLeft(2, '0');
    _month.text = date.month.toString().padLeft(2, '0');
    _year.text = date.year.toString().padLeft(4, '0');
  }

  BirthdateInput get _input => BirthdateInput.parse(
    _day.text,
    _month.text,
    _year.text,
    now: DateTime.now(),
  );

  Future<void> _pickFromCalendar() async {
    FocusScope.of(context).unfocus();
    final today = DateUtils.dateOnly(DateTime.now());
    final current = _input.date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(today.year - 25, today.month, today.day),
      firstDate: DateTime(BirthdateInput.firstYear),
      lastDate: today,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null) return;
    setState(() => _fill(picked));
  }

  void _toggleBirthTime(bool value) {
    setState(() => _hasBirthTime = value);
    if (!value) return;
    // Abre o seletor de hora e traz ele para a tela, sem que o usuário precise rolar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final end = _scroll.position.maxScrollExtent;
      if (MediaQuery.disableAnimationsOf(context)) {
        _scroll.jumpTo(end);
      } else {
        _scroll.animateTo(
          end,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submit(DateTime birthDate) {
    FocusScope.of(context).unfocus();
    final birthTime = _hasBirthTime ? _birthTime : null;
    context.read<AnalyticsService>().logBirthdateSubmitted(
      age: calculateAge(birthDate, DateTime.now()),
      hasBirthTime: birthTime != null,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SummaryPage(birthDate: birthDate, birthTime: birthTime),
      ),
    );
  }

  String _errorText(AppLocalizations l10n, BirthdateError error) =>
      switch (error) {
        BirthdateError.invalid => l10n.birthdateErrorInvalid,
        BirthdateError.future => l10n.birthdateErrorFuture,
        BirthdateError.tooOld => l10n.birthdateErrorTooOld,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.kn;
    final text = context.knText;
    final input = _input;
    final date = input.date;
    final error = input.error;

    return Scaffold(
      backgroundColor: c.bg,
      body: KnBackground(
        child: SafeArea(
          child: Column(
            children: [
              KnTopBar(
                leading: Navigator.of(context).canPop()
                    ? KnIconButton(
                        icon: Icons.arrow_back_rounded,
                        label: l10n.birthdateBack,
                        onPressed: () => Navigator.of(context).maybePop(),
                      )
                    : null,
                center: const AppLogo(),
                trailing: const ThemeButton(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: KnSpace.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: KnSpace.xl),
                      Text(
                        l10n.birthdateEyebrow.toUpperCase(),
                        style: text.eyebrow,
                      ),
                      const SizedBox(height: KnSpace.sm),
                      Semantics(
                        header: true,
                        child: Text(l10n.birthdateTitle, style: text.title),
                      ),
                      const SizedBox(height: KnSpace.xl),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DateField(
                              label: l10n.birthdateDay,
                              hint: l10n.birthdateDayHint,
                              controller: _day,
                              focusNode: _dayFocus,
                              maxLength: 2,
                              next: _monthFocus,
                              hasError: error != null,
                              onChanged: () => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: KnSpace.md),
                          Expanded(
                            child: DateField(
                              label: l10n.birthdateMonth,
                              hint: l10n.birthdateMonthHint,
                              controller: _month,
                              focusNode: _monthFocus,
                              maxLength: 2,
                              previous: _dayFocus,
                              next: _yearFocus,
                              hasError: error != null,
                              onChanged: () => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: KnSpace.md),
                          Expanded(
                            flex: 2,
                            child: DateField(
                              label: l10n.birthdateYear,
                              hint: l10n.birthdateYearHint,
                              controller: _year,
                              focusNode: _yearFocus,
                              maxLength: 4,
                              previous: _monthFocus,
                              hasError: error != null,
                              onChanged: () => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: KnSpace.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                error != null
                                    ? _errorText(l10n, error)
                                    : date != null
                                    ? DateText.long(date)
                                    : l10n.birthdateHint,
                                style: error != null
                                    ? text.caption.copyWith(color: c.danger)
                                    : text.caption,
                              ),
                            ),
                          ),
                          KnIconButton(
                            icon: Icons.calendar_month_rounded,
                            label: l10n.birthdatePickFromCalendar,
                            onPressed: _pickFromCalendar,
                          ),
                        ],
                      ),
                      const SizedBox(height: KnSpace.lg),
                      BirthTimeCard(
                        enabled: _hasBirthTime,
                        time: _birthTime,
                        onToggle: _toggleBirthTime,
                        onTimeChanged: (time) =>
                            setState(() => _birthTime = time),
                      ),
                      const SizedBox(height: KnSpace.xl),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KnSpace.xl,
                  KnSpace.sm,
                  KnSpace.xl,
                  KnSpace.lg,
                ),
                child: KnButton(
                  label: l10n.birthdateReveal,
                  icon: Icons.auto_awesome_rounded,
                  onPressed: date == null ? null : () => _submit(date),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
