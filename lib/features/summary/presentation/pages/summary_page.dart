import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knowhen/core/functions/calculate_age.dart';
import 'package:knowhen/core/services/life_profile_service.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/milestones/presentation/widgets/next_milestone_section.dart';
import 'package:knowhen/core/theme/widgets/custom_icon_button.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/brazil_curiosity/data/repositories/brazil_curiosity_repository_impl.dart';
import 'package:knowhen/features/brazil_curiosity/presentation/widgets/brazil_curiosity_section.dart';
import 'package:knowhen/features/moon_phase/presentation/widgets/moon_phase_section.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_events.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_state.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/ad_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:knowhen/core/services/analytics_service.dart';

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
  bool _saveOfferShown = false;

  /// Posição do card "Próximo marco" no resumo.
  static const milestoneSection = 1;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.openMilestone ? milestoneSection : 0);
    adService = AdService();

    final age = calculateAge(widget.birthDate, DateTime.now());
    AnalyticsService.instance.logSummaryViewed(age);

    adService.loadAd().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        adService.showAd();
      });
    });
  }

  void _logSectionIfNeeded(int index) {
    if (!_loggedSections.contains(index)) {
      _loggedSections.add(index);
      final age = calculateAge(widget.birthDate, DateTime.now());
      final isOver18 = age > 18;
      final String sectionName;
      switch (index) {
        case 0:
          sectionName = 'years_of_life';
          break;
        case milestoneSection:
          sectionName = 'next_milestone';
          break;
        case 2:
          sectionName = isOver18 ? 'conception' : 'conception_hidden';
          break;
        case 3:
          sectionName = 'moon_phase';
          break;
        case 4:
          sectionName = 'brazil_curiosity';
          break;
        default:
          sectionName = 'unknown';
      }
      AnalyticsService.instance.logSummarySectionViewed(sectionName, index);
    }
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
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: PrimaryH4(
          l10n.summaryPageTitle(dateFormat.format(widget.birthDate)),
          textAlign: TextAlign.center,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        centerTitle: true,
        actions: [
          ThemeButton(),
          _menu(l10n),
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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _logSectionIfNeeded(_controller.initialPage);
                if (mounted) _offerToSaveBirthdate();
              });
              final List<Widget> sections = [
                YearsOfLifeSection(birthDate: widget.birthDate, birthTime: widget.birthTime),
                NextMilestoneSection(birthDate: widget.birthDate, birthTime: widget.birthTime),
                calculateAge(widget.birthDate, DateTime.now()) > 18 ? ConceptionSection(birthDate: widget.birthDate) : Container(),
                MoonPhaseSection(moonPhase: state.moonPhase),
                BrazilCuriositySection(
                  imageUrl: state.curiosityImage,
                  curiosity: state.brazilCuriosity?.fact,
                  loadFailed: state.brazilCuriosityFailed,
                ),
              ];
              return Stack(
                children: [
                  PageView(
                    controller: _controller,
                    scrollBehavior: ScrollBehavior(),
                    scrollDirection: Axis.vertical,
                    onPageChanged: _logSectionIfNeeded,
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
            return Container();
          },
        ),
      ),
    );
  }
}
