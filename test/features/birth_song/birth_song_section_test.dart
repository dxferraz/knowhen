import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/birth_song/domain/birth_song_links.dart';
import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';
import 'package:knowhen/features/birth_song/presentation/widgets/birth_song_section.dart';

import '../../helpers/pump_app.dart';

void main() {
  const song = BirthSongEntity(artist: 'Tom Jobim', songName: 'Garota de Ipanema', month: '3', year: '1995');

  /// The section lives inside the summary's Scaffold; the snack bar for a failed link needs one.
  Future<void> pumpSection(WidgetTester tester, UrlOpener openUrl) =>
      tester.pumpApp(Scaffold(body: BirthSongSection(song: song, openUrl: openUrl)), TestDependencies());

  testWidgets('mostra título, período, música e artista', (tester) async {
    await pumpSection(tester, (_) async => true);

    expect(find.text(l10n.birthSongTitle), findsOneWidget);
    expect(find.text(l10n.birthSongIntro('03/1995')), findsOneWidget);
    expect(find.text('Garota de Ipanema'), findsOneWidget);
    expect(find.text('Tom Jobim'), findsOneWidget);
    expect(find.text(l10n.listenOnSpotify), findsOneWidget);
    expect(find.text(l10n.listenOnYoutube), findsOneWidget);
  });

  testWidgets('"Ouvir no Spotify" e "Ouvir no YouTube" abrem os links de busca', (tester) async {
    final opened = <Uri>[];
    await pumpSection(tester, (url) async {
      opened.add(url);
      return true;
    });

    await tester.tap(find.text(l10n.listenOnSpotify));
    await tester.tap(find.text(l10n.listenOnYoutube));

    expect(opened, [BirthSongLinks.spotify(song), BirthSongLinks.youtube(song)]);
    expect(find.text(l10n.birthSongOpenError), findsNothing);
  });

  testWidgets('avisa o usuário quando o link não abre', (tester) async {
    await pumpSection(tester, (_) async => false);

    await tester.tap(find.text(l10n.listenOnSpotify));
    await tester.pump();

    expect(find.text(l10n.birthSongOpenError), findsOneWidget);
  });

  testWidgets('avisa o usuário quando abrir o link lança erro', (tester) async {
    await pumpSection(tester, (_) async => throw Exception('sem app para abrir'));

    await tester.tap(find.text(l10n.listenOnYoutube));
    await tester.pump();

    expect(find.text(l10n.birthSongOpenError), findsOneWidget);
  });
}
