import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_events.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_state.dart';

import '../../helpers/fakes.dart';

void main() {
  final birthDate = DateTime(1990, 5, 20);

  test('starts in SummaryInitial', () {
    final bloc = SummaryBloc(FakeBrazilCuriositiesRepository());
    addTearDown(bloc.close);

    expect(bloc.state, isA<SummaryInitial>());
  });

  test('GetSummary emits loading and then the moon phase, curiosity and image', () async {
    final repository = FakeBrazilCuriositiesRepository(imageUrl: 'https://example.com/1990/5.png');
    final bloc = SummaryBloc(repository);
    addTearDown(bloc.close);

    bloc.add(GetSummary(birthDate: birthDate));

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<SummaryLoading>(),
        isA<SummaryLoaded>()
            .having((s) => s.moonPhase, 'moonPhase', getMoonPhase(birthDate))
            .having((s) => s.brazilCuriosity.fact, 'fact', 'Um fato curioso de 5/1990')
            .having((s) => s.brazilCuriosity.year, 'year', '1990')
            .having((s) => s.curiosityImage, 'curiosityImage', 'https://example.com/1990/5.png'),
      ]),
    );
    expect(repository.requestedDates, [birthDate]);
  });

  test('GetSummary emits SummaryError when the repository fails', () async {
    final bloc = SummaryBloc(FakeBrazilCuriositiesRepository(error: StateError('No element')));
    addTearDown(bloc.close);

    bloc.add(GetSummary(birthDate: birthDate));

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<SummaryLoading>(),
        isA<SummaryError>().having((s) => s.message, 'message', contains('No element')),
      ]),
    );
  });
}
