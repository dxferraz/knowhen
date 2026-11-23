import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_events.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_state.dart';

import '../../helpers/fakes.dart';

void main() {
  final birthDate = DateTime(2000, 1, 21);

  Future<SummaryLoaded> loadSummary(FakeBrazilCuriositiesRepository repository) async {
    final bloc = SummaryBloc(repository, FakeBirthSongRepository());
    final states = bloc.stream.take(2).toList();
    bloc.add(GetSummary(birthDate: birthDate));

    final emitted = await states;
    await bloc.close();
    expect(emitted.first, isA<SummaryLoading>());
    expect(emitted.last, isA<SummaryLoaded>());
    return emitted.last as SummaryLoaded;
  }

  test('starts in SummaryInitial', () {
    final bloc = SummaryBloc(FakeBrazilCuriositiesRepository(), FakeBirthSongRepository());
    addTearDown(bloc.close);

    expect(bloc.state, isA<SummaryInitial>());
  });

  test('carrega todas as seções quando há curiosidade e imagem', () async {
    final repository = FakeBrazilCuriositiesRepository(imageUrl: 'https://example.com/2000/1.png');
    final state = await loadSummary(repository);

    expect(state.moonPhase, getMoonPhase(birthDate));
    expect(state.brazilCuriosity?.fact, 'Um fato curioso de 1/2000');
    expect(state.brazilCuriosity?.year, '2000');
    expect(state.brazilCuriosityFailed, isFalse);
    expect(state.curiosityImage, 'https://example.com/2000/1.png');
    expect(repository.requestedDates, [birthDate]);
  });

  test('sem curiosidade para o mês/ano o resumo carrega com a seção vazia e não gera imagem', () async {
    final repository = FakeBrazilCuriositiesRepository(hasCuriosity: false);
    final state = await loadSummary(repository);

    expect(state.moonPhase.type, MoonPhaseType.fullMoon);
    expect(state.brazilCuriosity, isNull);
    expect(state.brazilCuriosityFailed, isFalse);
    expect(state.curiosityImage, isEmpty);
    expect(repository.imageRequests, 0);
  });

  test('erro ao buscar a curiosidade não derruba as outras seções', () async {
    final state = await loadSummary(FakeBrazilCuriositiesRepository(curiosityError: Exception('sem rede')));

    expect(state.moonPhase.type, MoonPhaseType.fullMoon);
    expect(state.brazilCuriosity, isNull);
    expect(state.brazilCuriosityFailed, isTrue);
  });

  test('erro ao gerar a imagem mantém a curiosidade, sem imagem', () async {
    final state = await loadSummary(FakeBrazilCuriositiesRepository(imageError: Exception('fal.ai fora do ar')));

    expect(state.brazilCuriosity?.fact, 'Um fato curioso de 1/2000');
    expect(state.brazilCuriosityFailed, isFalse);
    expect(state.curiosityImage, isEmpty);
  });

  group('"Tentar de novo" da curiosidade', () {
    Future<SummaryBloc> loaded(FakeBrazilCuriositiesRepository repository, {Duration? timeout}) async {
      final bloc = SummaryBloc(
        repository,
        FakeBirthSongRepository(song: sampleBirthSong),
        remoteTimeout: timeout ?? const Duration(seconds: 10),
      );
      addTearDown(bloc.close);
      bloc.add(GetSummary(birthDate: birthDate));
      await bloc.stream.firstWhere((s) => s is SummaryLoaded);
      return bloc;
    }

    test('refaz só a parte remota e mantém lua e música', () async {
      final repository = FakeBrazilCuriositiesRepository(failFirstCuriosity: true);
      final bloc = await loaded(repository);
      final first = bloc.state as SummaryLoaded;
      expect(first.brazilCuriosityFailed, isTrue);
      expect(first.birthSong, sampleBirthSong);

      final states = bloc.stream.take(2).toList();
      bloc.add(RetryBrazilCuriosity(birthDate: birthDate));
      final emitted = (await states).cast<SummaryLoaded>();

      expect(emitted.first.brazilCuriosityRetrying, isTrue);
      expect(emitted.first.brazilCuriosityFailed, isTrue);
      expect(emitted.last.brazilCuriosityRetrying, isFalse);
      expect(emitted.last.brazilCuriosityFailed, isFalse);
      expect(emitted.last.brazilCuriosity?.fact, 'Um fato curioso de 1/2000');
      expect(emitted.last.moonPhase, first.moonPhase);
      expect(emitted.last.birthSong, sampleBirthSong);
      expect(repository.requestedDates, [birthDate, birthDate]);
    });

    test('uma nova tentativa que também falha volta ao estado de erro', () async {
      final bloc = await loaded(FakeBrazilCuriositiesRepository(curiosityError: Exception('sem rede')));

      final states = bloc.stream.take(2).toList();
      bloc.add(RetryBrazilCuriosity(birthDate: birthDate));
      final emitted = (await states).cast<SummaryLoaded>();

      expect(emitted.last.brazilCuriosityFailed, isTrue);
      expect(emitted.last.brazilCuriosityRetrying, isFalse);
    });

    test('toques repetidos durante a busca viram uma só', () async {
      final gate = Completer<void>();
      final repository = FakeBrazilCuriositiesRepository(failFirstCuriosity: true, retryGate: gate);
      final bloc = await loaded(repository);

      bloc.add(RetryBrazilCuriosity(birthDate: birthDate));
      await bloc.stream.firstWhere((s) => s is SummaryLoaded && s.brazilCuriosityRetrying);
      bloc.add(RetryBrazilCuriosity(birthDate: birthDate));
      bloc.add(RetryBrazilCuriosity(birthDate: birthDate));
      gate.complete();
      await bloc.stream.firstWhere((s) => s is SummaryLoaded && !s.brazilCuriosityRetrying);
      await Future<void>.delayed(Duration.zero);

      expect(repository.requestedDates, hasLength(2));
    });

    test('sem resumo carregado, o evento é ignorado', () async {
      final repository = FakeBrazilCuriositiesRepository();
      final bloc = SummaryBloc(repository, FakeBirthSongRepository());
      addTearDown(bloc.close);

      bloc.add(RetryBrazilCuriosity(birthDate: birthDate));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, isA<SummaryInitial>());
      expect(repository.requestedDates, isEmpty);
    });
  });

  group('rede lenta', () {
    test('a curiosidade que não responde no prazo vira falha parcial e o resumo abre', () async {
      final repository = FakeBrazilCuriositiesRepository(wait: Completer<void>());
      final bloc = SummaryBloc(repository, FakeBirthSongRepository(song: sampleBirthSong), remoteTimeout: const Duration(milliseconds: 20));
      addTearDown(bloc.close);

      bloc.add(GetSummary(birthDate: birthDate));
      final state = await bloc.stream.firstWhere((s) => s is SummaryLoaded) as SummaryLoaded;

      expect(state.brazilCuriosityFailed, isTrue);
      expect(state.brazilCuriosity, isNull);
      expect(state.moonPhase.type, MoonPhaseType.fullMoon);
      expect(state.birthSong, sampleBirthSong);
    });

    test('a imagem que não responde no prazo mantém o fato, sem imagem', () async {
      final repository = FakeBrazilCuriositiesRepository(imageWait: Completer<void>());
      final bloc = SummaryBloc(repository, FakeBirthSongRepository(), remoteTimeout: const Duration(milliseconds: 20));
      addTearDown(bloc.close);

      bloc.add(GetSummary(birthDate: birthDate));
      final state = await bloc.stream.firstWhere((s) => s is SummaryLoaded) as SummaryLoaded;

      expect(state.brazilCuriosityFailed, isFalse);
      expect(state.brazilCuriosity?.fact, 'Um fato curioso de 1/2000');
      expect(state.curiosityImage, isEmpty);
    });

    test('a música que não responde no prazo só some do resumo', () async {
      final bloc = SummaryBloc(
        FakeBrazilCuriositiesRepository(),
        FakeBirthSongRepository(wait: Completer<void>()),
        remoteTimeout: const Duration(milliseconds: 20),
      );
      addTearDown(bloc.close);

      bloc.add(GetSummary(birthDate: birthDate));
      final state = await bloc.stream.firstWhere((s) => s is SummaryLoaded) as SummaryLoaded;

      expect(state.birthSong, isNull);
      expect(state.brazilCuriosity, isNotNull);
    });
  });
}
