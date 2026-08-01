import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/ad_service.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/theme/theme.dart';
import 'package:knowhen/features/brazil_curiosity/data/repositories/brazil_curiosity_repository_impl.dart';
import 'package:knowhen/features/brazil_curiosity/presentation/widgets/brazil_curiosity_section.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';
import 'package:knowhen/features/moon_phase/presentation/widgets/moon_phase_section.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_events.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_state.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';

/// Uma página do resumo, com o nome usado no analytics.
class _SummarySection {
  const _SummarySection({required this.name, required this.builder});

  final String name;
  final WidgetBuilder builder;
}

@RoutePage()
class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key, required this.birthDate, this.birthTime});

  final DateTime birthDate;
  final TimeOfDay? birthTime;

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late final PageController _controller;
  late final AdService adService;
  final Set<int> _loggedSections = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    adService = AdService();

    AnalyticsService.instance.logSummaryViewed(_age);

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

  int get _age => DateTime.now().difference(widget.birthDate).inDays ~/ 365;

  List<_SummarySection> _buildSections(SummaryLoaded state) {
    return [
      _SummarySection(
        name: 'years_of_life',
        builder: (_) => YearsOfLifeSection(
          birthDate: widget.birthDate,
          birthTime: widget.birthTime,
        ),
      ),
      // A seção de concepção é sensível: só entra no fluxo para maiores de 18.
      // Antes ela virava uma página em branco — agora simplesmente não existe.
      if (_age > 18)
        _SummarySection(
          name: 'conception',
          builder: (_) => ConceptionSection(birthDate: widget.birthDate),
        ),
      _SummarySection(
        name: 'moon_phase',
        builder: (_) => MoonPhaseSection(moonPhase: state.moonPhase),
      ),
      _SummarySection(
        name: 'brazil_curiosity',
        builder: (_) => BrazilCuriositySection(
          imageUrl: state.curiosityImage,
          curiosity: state.brazilCuriosity.fact,
        ),
      ),
    ];
  }

  void _logSectionIfNeeded(List<_SummarySection> sections, int index) {
    if (index < 0 || index >= sections.length) return;
    if (!_loggedSections.add(index)) return;
    AnalyticsService.instance
        .logSummarySectionViewed(sections[index].name, index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return GlassScaffold(
      appBar: GlassAppBar(
        title: l10n.summaryPageTitle(dateFormat.format(widget.birthDate)),
        actions: const [ThemeButton()],
      ),
      padBodyForAppBar: false,
      body: BlocProvider(
        create: (context) => SummaryBloc(
          HistoricalFactsRepositoryImpl(firestore: FirebaseFirestore.instance),
        )..add(GetSummary(birthDate: widget.birthDate)),
        child: BlocBuilder<SummaryBloc, SummaryState>(
          builder: (context, state) {
            if (state is SummaryError) {
              return _SummaryMessage(message: state.message);
            }
            if (state is! SummaryLoaded) {
              return const _SummaryLoading();
            }

            final sections = _buildSections(state);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _logSectionIfNeeded(sections, 0);
            });

            final bool isLast = _currentPage >= sections.length - 1;

            return Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  itemCount: sections.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    _logSectionIfNeeded(sections, index);
                  },
                  itemBuilder: (context, index) => Padding(
                    // Compensa a app bar transparente que cobre o topo (o
                    // recorte do status bar já foi aplicado pelo SafeArea).
                    padding: const EdgeInsets.only(top: kToolbarHeight),
                    child: sections[index].builder(context),
                  ),
                ),

                // Trilha de progresso vertical: mostra quantas revelações
                // ainda faltam sem competir com o conteúdo.
                Positioned(
                  right: AppSpacing.sMedium,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: AppPageIndicator(
                      controller: _controller,
                      count: sections.length,
                      axis: Axis.vertical,
                      dotSize: 7,
                    ),
                  ),
                ),

                Positioned(
                  bottom: AppSpacing.xLarge,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: isLast,
                    child: AnimatedOpacity(
                      duration: AppMotion.normal,
                      opacity: isLast ? 0 : 1,
                      child: Center(
                        child: GlassIconButton(
                          icon: Icons.keyboard_arrow_down_rounded,
                          iconSize: 28,
                          size: 56,
                          gradient: context.glass.brandGradient,
                          tooltip: 'Próxima seção',
                          onPressed: () => _controller.nextPage(
                            duration: AppMotion.page,
                            curve: AppMotion.standard,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryLoading extends StatelessWidget {
  const _SummaryLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        level: GlassLevel.regular,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xLarge,
          vertical: AppSpacing.large,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            const AppText.caption('Revelando sua data…'),
          ],
        ),
      ),
    );
  }
}

class _SummaryMessage extends StatelessWidget {
  const _SummaryMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        child: GlassCard(
          eyebrow: 'Ops',
          accent: context.colors.danger,
          child: AppText.body(message, align: TextAlign.center),
        ),
      ),
    );
  }
}
