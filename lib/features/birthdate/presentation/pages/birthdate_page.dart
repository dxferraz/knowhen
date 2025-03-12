import 'package:auto_route/auto_route.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowhen/core/theme/widgets/app_logo.dart';
import 'package:knowhen/core/theme/widgets/custom_button.dart';
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
              Text(l10n.selectBirthdateTitle),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 200,
                child: SvgPicture.network('https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/app-media%2Fbirthday.svg?alt=media&token=164027d8-0352-4ca7-90a1-d04c9208451e'),
              ),
              const SizedBox(height: 20),
              CustomButton(
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
                    slidersColor: Theme.of(context).colorScheme.secondary,
                    highlightColor: Theme.of(context).colorScheme.tertiary,
                    slidersSize: 20,
                    splashColor: Theme.of(context).colorScheme.primary,
                    splashRadius: 30,
                    centerLeadingDate: true,
                  ).then((value) => setState(() => birthDate = value));
                },
                text: birthDate != null ? formatDate(birthDate!) : 'Selecionar data',
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SummaryPage(birthDate: birthDate!),
                        ),
                      );
                    },
                    text: l10n.continueLabel,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
