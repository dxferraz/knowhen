import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/functions/calculate_age.dart';
import 'package:knowhen/core/services/life_profile_service.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/milestones/presentation/widgets/next_milestone_section.dart';
import 'package:knowhen/core/theme/widgets/custom_icon_button.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/birth_song/domain/repositories/birth_song_repository.dart';
import 'package:knowhen/features/birth_song/presentation/widgets/birth_song_section.dart';
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

  /// Abre direto no card "Próximo marco" (toque na notificação).
  final bool openMilestone;
  const SummaryPage({super.key, required this.birthDate, this.birthTime, this.openMilestone = false});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late PageController _controller;
  late AdService adService;
  final Set<int> _loggedSections = {};
  late int _currentPage = widget.openMilestone ? milestoneSection : 0;
  bool _saveOfferShown = false;

  /// Posição do card "Próximo marco" no resumo.
  static const milestoneSection = 1;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.openMilestone ? milestoneSection : 0);
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
      final String sectionName;
      switch (index) {
        case 0:
          sectionName = 'years_of_life';
          break;
        case milestoneSection:
          sectionName = 'next_milestone';
          break;
        case 2:
          sectionName = showsConception ? 'conception' : 'conception_hidden';
          break;
        case 3:
          sectionName = 'moon_phase';
          break;
        case 4:
          sectionName = 'brazil_curiosity';
          break;
        case 5:
          sectionName = 'birth_song';
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

  /// Depois do primeiro resumo, oferece guardar a data neste aparelho.
  void _offerToSaveBirthdate() {
    final profile = context.read<LifeProfileService>();
    if (_saveOfferShown || profile.saved?.date == DateUtils.dateOnly(widget.birthDate)) {
      return;
    }
    _saveOfferShown = true;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.saveBirthdateOffer),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(label: l10n.saveBirthdateShort, onPressed: _saveBirthdate),
      ),
    );
  }

  Future<void> _saveBirthdate() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    await context.read<LifeProfileService>().save(widget.birthDate, widget.birthTime);
    messenger.showSnackBar(SnackBar(content: Text(l10n.birthdateSaved)));
  }

  Future<void> _deleteSavedBirthdate() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    await context.read<LifeProfileService>().clear();
    messenger.showSnackBar(SnackBar(content: Text(l10n.birthdateDeleted)));
  }

  void _chooseAnotherDate() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => BirthdatePage(initialBirthDate: widget.birthDate)),
      (route) => false,
    );
  }

  Widget _menu(AppLocalizations l10n) {
    final saved = context.watch<LifeProfileService>().saved;
    final isSaved = saved?.date == DateUtils.dateOnly(widget.birthDate);
    return PopupMenuButton<VoidCallback>(
      key: const Key('summary_menu'),
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        if (!isSaved) PopupMenuItem(value: _saveBirthdate, child: Text(l10n.saveBirthdateAction)),
        if (saved != null) PopupMenuItem(value: _deleteSavedBirthdate, child: Text(l10n.deleteSavedBirthdate)),
        PopupMenuItem(value: _chooseAnotherDate, child: Text(l10n.chooseAnotherDate)),
      ],
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

    return BlocProvider(
      create: (context) => SummaryBloc(context.read<BrazilCuriositiesRepository>(), context.read<BirthSongRepository>())..add(GetSummary(birthDate: widget.birthDate)),
      child: Scaffold(
        appBar: AppBar(
          title: PrimaryH4(
            l10n.summaryPageTitle(DateText.numeric(widget.birthDate)),
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
            _menu(l10n),
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
                _logSectionIfNeeded(_controller.initialPage);
                if (mounted) _offerToSaveBirthdate();
              });
              final showsConception = shouldShowConception(widget.birthDate, DateTime.now());
              // Cada página junto com a sua seção compartilhável (`null` nas páginas sem conteúdo para compartilhar), numa lista só:
              // uma página nova entra aqui e nunca fica sem par.
              final List<_SummaryPage> pages = [
                (section: YearsOfLifeSection(birthDate: widget.birthDate, birthTime: widget.birthTime), share: ShareSection.yearsOfLife),
                (section: NextMilestoneSection(birthDate: widget.birthDate, birthTime: widget.birthTime), share: null),
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
                // Sem música para o mês, a página nem existe (sem placeholder vazio).
                if (state.birthSong != null) (section: BirthSongSection(song: state.birthSong!), share: null),
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
