import 'package:auto_route/auto_route.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:knowhen/core/theme/widgets/app_logo.dart';
import 'package:knowhen/core/theme/widgets/custom_button.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/summary/presentation/pages/summary_page.dart';
import 'package:knowhen/l10n/generated/app_localizations.dart';

@RoutePage()
class BirthdatePage extends StatefulWidget {
  const BirthdatePage({super.key});

  @override
  State<BirthdatePage> createState() => _BirthdatePageState();
}

class _BirthdatePageState extends State<BirthdatePage> {
  DateTime? birthDate;
  TimeOfDay? _birthTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String formatDate(DateTime date) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return dateFormat.format(date);
  }

  Future<void> _selecionarHora(BuildContext context) async {
    final TimeOfDay? horaEscolhida = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? TimeOfDay(hour: 12, minute: 00),
      helpText: 'Você sabe a hora exata do seu nascimento?',
      cancelText: 'Não sei',
      confirmText: 'Confirmar',
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );

    if (horaEscolhida != null && horaEscolhida != _birthTime) {
      setState(() {
        _birthTime = horaEscolhida;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    debugPrint('birthDate: ${birthDate?.toString()}');

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: AppLogo(),
          centerTitle: true,
          actions: [
            ThemeButton(),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrimaryH2(
                text: l10n.selectBirthdateTitle,
                textAlign: TextAlign.center,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 20),
              SizedBox(height: 20),
              DatePicker(
                maxDate: DateTime(2024, 12, 31),
                minDate: DateTime(1925, 1, 1),
                initialPickerType: PickerType.years,
                initialDate: birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
                onDateSelected: (value) {
                  debugPrint('Date saved: ${value.toString()}');
                  setState(() {
                    birthDate = value;
                  });
                },
                slidersColor: Theme.of(context).colorScheme.secondary,
                highlightColor: Theme.of(context).colorScheme.secondary,
                splashColor: Theme.of(context).colorScheme.secondary,
                daysOfTheWeekTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                selectedCellDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(100),
                ),
                leadingDateTextStyle: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w700),
                centerLeadingDate: true,
                padding: EdgeInsets.all(20),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.all(20),
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (birthDate != null)
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      if (birthDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.selectABirthdate),
                          ),
                        );
                        return;
                      }
                      _selecionarHora(context).then((value) {
                        context.mounted
                            ? Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SummaryPage(birthDate: birthDate!, birthTime: _birthTime),
                                ),
                              )
                            : null;
                      });
                    },
                    text: l10n.continueLabel,
                    backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
