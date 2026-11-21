import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knowhen/core/functions/calculate_age.dart';
import 'package:knowhen/core/theme/widgets/custom_icon_button.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/brazil_curiosity/domain/repositories/brazil_curiosity_repository.dart';
import 'package:knowhen/features/brazil_curiosity/presentation/widgets/brazil_curiosity_section.dart';
import 'package:knowhen/features/moon_phase/presentation/widgets/moon_phase_section.dart';
import 'package:knowhen/features/share/domain/share_card_content.dart';
import 'package:knowhen/features/share/domain/share_section.dart';
import 'package:knowhen/features/share/presentation/widgets/share_card_sheet.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_events.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_state.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/ad_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:knowhen/core/services/analytics_service.dart';

/// Uma página do resumo e o card que ela oferece para compartilhar.
typedef _SummaryPage = ({Widget section, ShareSection? share});

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
  final Set<int> _loggedSections = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    adService = context.read<AdService>();

    final age = calculateAge(widget.birthDate, DateTime.now());
    context.read<AnalyticsService>().logSummaryViewed(age);

    adService.loadAd().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // The service outlives this page: a loaded ad stays queued for the next visit.
        if (mounted) adService.showAd();
      });
    });
  }

  void _logSectionIfNeeded(int index) {
    if (!_loggedSections.contains(index)) {
      _loggedSections.add(index);
      final showsConception = shouldShowConception(widget.birthDate, DateTime.now());
      String sectionName;
      switch (index) {
        case 0:
          sectionName = 'years_of_life';
          break;
        case 1:
          sectionName = showsConception ? 'conception' : 'conception_hidden';
          break;
        case 2:
          sectionName = 'moon_phase';
          break;
        case 3:
          sectionName = 'brazil_curiosity';
          break;
        default:
          sectionName = 'unknown';
      }
      context.read<AnalyticsService>().logSummarySectionViewed(sectionName, index);
    }
  }

  void _openShare(ShareSection section, SummaryLoaded state) {
    final analytics = context.read<AnalyticsService>();
    analytics.logShareTapped(section.analyticsName);
    ShareCardSheet.show(
      context,
      section: section,
      data: ShareCardData(
        birthDate: widget.birthDate,
        now: DateTime.now(),
        moonPhase: state.moonPhase,
        curiosity: state.brazilCuriosity?.fact,
        curiosityImageUrl: state.curiosityImage,
      ),
      onShared: (section) => analytics.logShareCompleted(section.analyticsName),
    );
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

    return BlocProvider(
      create: (context) => SummaryBloc(context.read<BrazilCuriositiesRepository>())..add(GetSummary(birthDate: widget.birthDate)),
      child: Scaffold(
        appBar: AppBar(
          title: PrimaryH4(
            l10n.summaryPageTitle(dateFormat.format(widget.birthDate)),
            textAlign: TextAlign.center,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<SummaryBloc, SummaryState>(
              builder: (context, state) => state is SummaryLoaded
                  ? IconButton(
                      tooltip: l10n.shareSummaryTitle,
                      icon: Icon(Icons.ios_share_rounded, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => _openShare(ShareSection.summary, state),
                    )
                  : const SizedBox.shrink(),
            ),
            ThemeButton(),
          ],
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: BlocBuilder<SummaryBloc, SummaryState>(
          builder: (context, state) {
            if (state is SummaryLoading) {
              return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurfaceVariant));
            }
            if (state is SummaryLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _logSectionIfNeeded(0);
              });
              final showsConception = shouldShowConception(widget.birthDate, DateTime.now());
              // Cada página junto com a sua seção compartilhável (`null` nas páginas sem conteúdo para compartilhar), numa lista só:
              // uma página nova entra aqui e nunca fica sem par.
              final List<_SummaryPage> pages = [
                (section: YearsOfLifeSection(birthDate: widget.birthDate, birthTime: widget.birthTime), share: ShareSection.yearsOfLife),
                (
                  section: showsConception ? ConceptionSection(birthDate: widget.birthDate) : Container(),
                  share: showsConception ? ShareSection.conception : null,
                ),
                (section: MoonPhaseSection(moonPhase: state.moonPhase), share: ShareSection.moonPhase),
                (
                  section: BrazilCuriositySection(
                    imageUrl: state.curiosityImage,
                    curiosity: state.brazilCuriosity?.fact,
                    loadFailed: state.brazilCuriosityFailed,
                  ),
                  share: state.brazilCuriosity != null ? ShareSection.brazilCuriosity : null,
                ),
              ];
              final pageShareSection = pages[_currentPage].share;
              return Stack(
                children: [
                  PageView(
                    controller: _controller,
                    scrollBehavior: ScrollBehavior(),
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _logSectionIfNeeded(index);
                    },
                    children: [for (final page in pages) page.section],
                  ),
                  Positioned(
                    bottom: 50,
                    right: MediaQuery.of(context).size.width / 2 - 25,
                    child: CustomIconButton(
                      icon: Icons.arrow_downward,
                      iconColor: Theme.of(context).colorScheme.surface,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      onPressed: () => _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease),
                    ),
                  ),
                  if (pageShareSection != null)
                    Positioned(
                      bottom: 50,
                      left: 20,
                      child: CustomIconButton(
                        icon: Icons.ios_share_rounded,
                        iconColor: Theme.of(context).colorScheme.surface,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        tooltip: l10n.shareButtonLabel,
                        onPressed: () => _openShare(pageShareSection, state),
                      ),
                    ),
                  Positioned(
                    top: MediaQuery.of(context).size.height / 2 - 100,
                    right: 10,
                    child: SmoothPageIndicator(
                      controller: _controller,
                      axisDirection: Axis.vertical,
                      count: pages.length,
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
            return Container();
          },
        ),
      ),
    );
  }
}
