import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/historical_facts/data/repositories/historical_facts_repository_impl.dart';
import 'package:knowhen/features/historical_facts/presentation/widgets/brazil_curiosity_section.dart';
import 'package:knowhen/features/summary/bloc/summary_bloc.dart';
import 'package:knowhen/features/summary/bloc/summary_events.dart';
import 'package:knowhen/features/summary/bloc/summary_state.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@RoutePage()
class SummaryPage extends StatefulWidget {
  final DateTime birthDate;
  const SummaryPage({super.key, required this.birthDate});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    int getUserAge() {
      final now = DateTime.now();
      final difference = now.difference(widget.birthDate);
      final age = difference.inDays ~/ 365;

      return age;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.summaryPageTitle(dateFormat.format(widget.birthDate)),
        ),
        centerTitle: true,
        actions: [
          ThemeButton(),
        ],
      ),
      body: BlocProvider(
        create: (context) => SummaryBloc(HistoricalFactsRepositoryImpl(firestore: FirebaseFirestore.instance))
          ..add(
            GetSummary(birthDate: widget.birthDate),
          ),
        child: BlocBuilder<SummaryBloc, SummaryState>(
          builder: (context, state) {
            if (state is SummaryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SummaryLoaded) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      YearsOfLifeSection(birthDate: widget.birthDate),
                      getUserAge() > 18 ? ConceptionSection(birthDate: widget.birthDate) : Container(),
                      BrazilCuriositySection(imageUrl: state.curiosityImage, curiosity: state.brazilCuriosity.fact),
                      // HistoricalFactSection(imageUrl: state.factImage, fact: state.historicalFact.fact),
                    ],
                  ),
                ),
              );
            }
            if (state is SummaryError) {
              return Center(child: Text(state.message));
            }
            return Container();
          },
        ),
      ),
    );
  }
}
