import 'package:auto_route/auto_route.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowhen/core/theme/constants/app_colors.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/summary/presentation/pages/summary_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@RoutePage()
class BirthdatePage extends StatefulWidget {
  const BirthdatePage({super.key});

  @override
  State<BirthdatePage> createState() => _BirthdatePageState();
}

class _BirthdatePageState extends State<BirthdatePage> {
  DateTime? birthDate;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l10n.appTitle),
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
              Text(l10n.selectBirthdateTitle),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 200,
                child: SvgPicture.network('https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/app-media%2Fbirthday.svg?alt=media&token=164027d8-0352-4ca7-90a1-d04c9208451e'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDatePickerDialog(
                    context: context,
                    minDate: DateTime(1925, 1, 1),
                    maxDate: DateTime(2024, 12, 31),
                    initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                    width: 300,
                    height: 300,
                    daysOfTheWeekTextStyle: const TextStyle(),
                    disabledCellsTextStyle: const TextStyle(),
                    enabledCellsDecoration: const BoxDecoration(),
                    enabledCellsTextStyle: const TextStyle(),
                    initialPickerType: PickerType.years,
                    selectedCellDecoration: const BoxDecoration(),
                    selectedCellTextStyle: const TextStyle(),
                    leadingDateTextStyle: const TextStyle(),
                    slidersColor: isDark ? DarkAppColors.accent : LightAppColors.accent,
                    highlightColor: isDark ? DarkAppColors.secondary : LightAppColors.secondary,
                    slidersSize: 20,
                    splashColor: isDark ? DarkAppColors.primary : LightAppColors.primary,
                    splashRadius: 30,
                    centerLeadingDate: true,
                  ).then((value) => setState(() => birthDate = value));
                },
                child: Text(
                  birthDate != null ? formatDate(birthDate!) : 'Selecionar data',
                ),
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
                  child: ElevatedButton(
                    onPressed: () {
                      if (birthDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.selectABirthdate),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SummaryPage(birthDate: birthDate!),
                        ),
                      );
                    },
                    child: Text(l10n.continueLabel),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
