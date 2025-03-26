import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knowhen/core/theme/widgets/custom_icon_button.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/brazil_curiosity/data/repositories/brazil_curiosity_repository_impl.dart';
import 'package:knowhen/features/brazil_curiosity/presentation/widgets/brazil_curiosity_section.dart';
import 'package:knowhen/features/summary/bloc/summary_bloc.dart';
import 'package:knowhen/features/summary/bloc/summary_events.dart';
import 'package:knowhen/features/summary/bloc/summary_state.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';
import 'package:knowhen/l10n/generated/app_localizations.dart';
import 'package:knowhen/services/ad_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

@RoutePage()
class SummaryPage extends StatefulWidget {
  final DateTime birthDate;
  final TimeOfDay? birthTime;
  const SummaryPage({super.key, required this.birthDate, this.birthTime});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late PageController _controller;
  late AdService adService;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    adService = AdService();

    adService.loadAd().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        adService.showAd();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        title: PrimaryH4(
          text: l10n.summaryPageTitle(dateFormat.format(widget.birthDate)),
          textAlign: TextAlign.center,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        centerTitle: true,
        actions: [
          ThemeButton(),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocProvider(
        create: (context) => SummaryBloc(HistoricalFactsRepositoryImpl(firestore: FirebaseFirestore.instance))
          ..add(
            GetSummary(birthDate: widget.birthDate),
          ),
        child: BlocBuilder<SummaryBloc, SummaryState>(
          builder: (context, state) {
            if (state is SummaryLoading) {
              return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurfaceVariant));
            }
            if (state is SummaryLoaded) {
              final List<Widget> sections = [
                YearsOfLifeSection(birthDate: widget.birthDate, birthTime: widget.birthTime),
                getUserAge() > 18 ? ConceptionSection(birthDate: widget.birthDate) : Container(),
                BrazilCuriositySection(imageUrl: state.curiosityImage, curiosity: state.brazilCuriosity.fact),
              ];
              return Stack(
                children: [
                  PageView(
                    controller: _controller,
                    scrollBehavior: ScrollBehavior(),
                    scrollDirection: Axis.vertical,
                    children: sections,
                  ),
                  Positioned(
                    bottom: 50,
                    right: MediaQuery.of(context).size.width / 2 - 25,
                    child: CustomIconButton(
                      icon: Icons.arrow_downward,
                      iconColor: Theme.of(context).colorScheme.surface,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height / 2 - 100,
                    right: 10,
                    child: SmoothPageIndicator(
                      controller: _controller,
                      axisDirection: Axis.vertical,
                      count: sections.length,
                      effect: WormEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        dotColor: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                        activeDotColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onDotClicked: (index) {
                        setState(() {
                          _controller.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                        });
                      },
                    ),
                  ),
                ],
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
