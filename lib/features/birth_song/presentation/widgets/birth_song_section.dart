import 'package:flutter/material.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/widgets/custom_button.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/features/birth_song/domain/birth_song_links.dart';
import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';
import 'package:url_launcher/url_launcher.dart';

typedef UrlOpener = Future<bool> Function(Uri url);

Future<bool> _openExternally(Uri url) => launchUrl(url, mode: LaunchMode.externalApplication);

class BirthSongSection extends StatelessWidget {
  final BirthSongEntity song;
  final UrlOpener openUrl;

  const BirthSongSection({super.key, required this.song, this.openUrl = _openExternally});

  Future<void> _open(BuildContext context, Uri url) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context)!.birthSongOpenError;
    var opened = false;
    try {
      opened = await openUrl(url);
    } catch (_) {
      opened = false;
    }
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16.0,
          children: [
            SecondaryH1(l10n.birthSongTitle, textAlign: TextAlign.center, color: colors.onSurface),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: colors.primaryContainer),
              child: Column(
                spacing: 12.0,
                children: [
                  PrimaryParagraphS(l10n.birthSongIntro(song.period), textAlign: TextAlign.center, color: colors.onPrimaryContainer),
                  Icon(Icons.music_note, size: 48, color: colors.onPrimaryContainer),
                  PrimaryH3(song.songName, textAlign: TextAlign.center, color: colors.onPrimaryContainer),
                  PrimaryParagraphM(song.artist, textAlign: TextAlign.center, color: colors.onPrimaryContainer),
                  SecondaryCaption(l10n.birthSongDisclaimer, textAlign: TextAlign.center, color: colors.onPrimaryContainer),
                ],
              ),
            ),
            CustomButton(text: l10n.listenOnSpotify, onPressed: () => _open(context, BirthSongLinks.spotify(song))),
            CustomButton(text: l10n.listenOnYoutube, onPressed: () => _open(context, BirthSongLinks.youtube(song))),
          ],
        ),
      ),
    );
  }
}
