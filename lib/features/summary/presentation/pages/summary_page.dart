import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:knowhen/core/functions/calculate_age.dart';
import 'package:knowhen/core/services/life_profile_service.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/milestones/presentation/widgets/next_milestone_section.dart';
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
import 'package:knowhen/features/summary/presentation/widgets/native_ad_slot.dart';
import 'package:knowhen/features/summary/presentation/widgets/summary_reveal.dart';
import 'package:knowhen/features/summary/presentation/widgets/summary_shell.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/ad_service.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

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
  late AdService adService;
  final Set<String> _loggedSections = {};
  bool _saveOfferShown = false;

  // Política de anúncios (DXF-9, 4.11): nada antes do primeiro cartão; o nativo fica no último e o intersticial só
  // sai ao deixar o resumo depois de chegar a ele. Os dois são pedidos quando a pessoa está perto do fim, não ao
  // abrir, para não pedir anúncio que não chega a ser visto.
  bool _adsRequested = false;
  bool _reachedLastCard = false;
  bool _interstitialOffered = false;
  NativeAd? _nativeAd;

  // O ScaffoldMessenger é o do app, e não o desta rota: o que ele mostra sobrevive ao resumo. Guardado aqui porque
  // não se consulta `.of(context)` no dispose.
  late ScaffoldMessengerState _messenger;

  /// O convite de salvar a data é o *atual* do messenger (na tela). É o único SnackBar que este resumo fecha por conta
  /// própria. Não basta guardar o controller: `close` exige que ele seja o primeiro da fila, e o convite pode estar
  /// atrás de outro ("Data apagada") ou já ter saído.
  bool _saveOfferVisible = false;

  /// Posição do card "Próximo marco" no resumo.
  static const milestoneSection = 1;

  // Do resumo e não da casca: o "Ver o que já está pronto" do fato precisa levar a pessoa de volta ao primeiro cartão.
  late final PageController _pageController = PageController(initialPage: widget.openMilestone ? milestoneSection : 0);

  @override
  void initState() {
    super.initState();
    adService = context.read<AdService>();

    final age = calculateAge(widget.birthDate, DateTime.now());
    context.read<AnalyticsService>().logSummaryViewed(age);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _closeSaveOffer();
    _nativeAd?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _seeWhatIsReady() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(0);
    } else {
      _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
    }
  }

  /// Pede o intersticial e o nativo uma vez, quando a pessoa chega ao penúltimo cartão.
  void _requestAds() {
    if (_adsRequested) return;
    _adsRequested = true;
    unawaited(adService.loadAd());
    unawaited(_loadNativeAd());
  }

  Future<void> _loadNativeAd() async {
    final style = nativeAdStyle(context.kn);
    final ad = await adService.loadNativeAd(style);
    if (ad == null) return;
    // O anúncio chegou depois de a pessoa sair: quem o carregou é quem o descarta.
    if (!mounted) {
      ad.dispose();
      return;
    }
    setState(() => _nativeAd = ad);
  }

  /// Intersticial só na pausa natural de deixar o resumo, e só depois de ver o último cartão. O serviço cuida de
  /// quantas vezes (intervalo mínimo entre dois); aqui, no máximo uma tentativa por visita.
  void _offerInterstitial() {
    if (!_reachedLastCard || _interstitialOffered) return;
    _interstitialOffered = true;
    unawaited(adService.showInterstitialIfDue());
  }

  void _onCardViewed(List<SummaryCard> cards, int index) {
    _logSectionIfNeeded(cards, index);
    if (index >= cards.length - 2) _requestAds();
    if (index == cards.length - 1) _reachedLastCard = true;
  }

  void _logSectionIfNeeded(List<SummaryCard> cards, int index) {
    final name = cards[index].analyticsName;
    if (_loggedSections.add(name)) {
      context.read<AnalyticsService>().logSummarySectionViewed(name, index);
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
    _messenger
        .showSnackBar(
          SnackBar(
            content: Text(l10n.saveBirthdateOffer),
            duration: const Duration(seconds: 10),
            // Flutuante e acima do rodapé, para não cobrir o "Próximo" enquanto o convite está na tela.
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(KnSpace.lg, 0, KnSpace.lg, 96),
            onVisible: _onSaveOfferVisible,
            action: SnackBarAction(label: l10n.saveBirthdateShort, onPressed: _saveBirthdate),
          ),
        )
        .closed
        .whenComplete(() => _saveOfferVisible = false);
  }

  void _onSaveOfferVisible() {
    // A pessoa saiu do resumo antes de o convite chegar à tela (esperava na fila ou ainda animava a entrada).
    if (!mounted) {
      _messenger.hideCurrentSnackBar();
      return;
    }
    _saveOfferVisible = true;
  }

  /// Fecha só o convite de salvar a data, sem mexer em "Data salva", "Data apagada" ou SnackBars de outras telas.
  /// Remove na hora, sem animação: serve também ao `dispose`, onde não há mais o que animar.
  void _closeSaveOffer() {
    if (!_saveOfferVisible) return;
    _saveOfferVisible = false;
    _messenger.removeCurrentSnackBar();
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
    // Sem isto o convite de salvar a data (10 s) seguiria cobrindo a tela da data.
    _closeSaveOffer();
    _offerInterstitial();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => BirthdatePage(initialBirthDate: widget.birthDate)),
      (route) => false,
    );
  }

  Widget _menu(AppLocalizations l10n, SummaryLoaded? state) {
    final saved = context.watch<LifeProfileService>().saved;
    final isSaved = saved?.date == DateUtils.dateOnly(widget.birthDate);
    return PopupMenuButton<VoidCallback>(
      key: const Key('summary_menu'),
      tooltip: l10n.summaryMenu,
      icon: Icon(Icons.more_vert_rounded, color: context.kn.ink),
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        if (state != null) PopupMenuItem(value: () => _openShare(ShareSection.summary, state), child: Text(l10n.endShare)),
        if (!isSaved) PopupMenuItem(value: _saveBirthdate, child: Text(l10n.saveBirthdateAction)),
        if (saved != null) PopupMenuItem(value: _deleteSavedBirthdate, child: Text(l10n.deleteSavedBirthdate)),
        PopupMenuItem(value: _chooseAnotherDate, child: Text(l10n.chooseAnotherDate)),
      ],
    );
  }

  /// Os cartões do resumo, na ordem em que aparecem. Cada um leva a seção que oferece para compartilhar (`null`
  /// quando não há o que compartilhar), numa lista só: um cartão novo entra aqui e nunca fica sem par.
  List<SummaryCard> _cards(BuildContext context, SummaryLoaded state) {
    final showsConception = shouldShowConception(widget.birthDate, DateTime.now());
    return [
      (
        analyticsName: 'years_of_life',
        section: YearsOfLifeSection(birthDate: widget.birthDate, birthTime: widget.birthTime),
        share: ShareSection.yearsOfLife,
      ),
      (
        analyticsName: 'next_milestone',
        section: NextMilestoneSection(birthDate: widget.birthDate, birthTime: widget.birthTime),
        share: null,
      ),
      // Quem tem até 18 anos completos não vê o cartão da concepção (`shouldShowConception` exige mais de 18): ele sai da
      // sequência, em vez de virar uma página em branco.
      if (showsConception)
        (analyticsName: 'conception', section: ConceptionSection(birthDate: widget.birthDate), share: ShareSection.conception),
      (analyticsName: 'moon_phase', section: MoonPhaseSection(moonPhase: state.moonPhase, birthDate: widget.birthDate), share: ShareSection.moonPhase),
      (
        analyticsName: 'brazil_curiosity',
        section: BrazilCuriositySection(
          birthDate: widget.birthDate,
          imageUrl: state.curiosityImage,
          curiosity: state.brazilCuriosity?.fact,
          loadFailed: state.brazilCuriosityFailed,
          retrying: state.brazilCuriosityRetrying,
          onRetry: () => context.read<SummaryBloc>().add(RetryBrazilCuriosity(birthDate: widget.birthDate)),
          onSeeReady: _seeWhatIsReady,
        ),
        share: state.brazilCuriosity != null ? ShareSection.brazilCuriosity : null,
      ),
      // Sem música para o mês, a página nem existe (sem placeholder vazio).
      if (state.birthSong != null) (analyticsName: 'birth_song', section: BirthSongSection(song: state.birthSong!), share: null),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Voltar pelo botão ou gesto do sistema faz `pop` sem passar por `_chooseAnotherDate`: sem fechar o convite aqui ele
    // reapareceria por cima da tela anterior.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        _closeSaveOffer();
        _offerInterstitial();
      },
      child: BlocProvider(
        create: (context) => SummaryBloc(context.read<BrazilCuriositiesRepository>(), context.read<BirthSongRepository>())..add(GetSummary(birthDate: widget.birthDate)),
        child: BlocBuilder<SummaryBloc, SummaryState>(
          builder: (context, state) {
            if (state is! SummaryLoaded) return SummaryReveal(birthDate: widget.birthDate);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _offerToSaveBirthdate();
            });
            final cards = _cards(context, state);
            return SummaryShell(
              birthDate: widget.birthDate,
              cards: cards,
              controller: _pageController,
              menu: _menu(l10n, state),
              onClose: _chooseAnotherDate,
              onChooseAnotherDate: _chooseAnotherDate,
              onShare: (section) => _openShare(section, state),
              onPageViewed: (index) => _onCardViewed(cards, index),
              endSlot: _nativeAd == null ? null : NativeAdSlot(ad: _nativeAd!),
            );
          },
        ),
      ),
    );
  }
}
