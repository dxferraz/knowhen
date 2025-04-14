import 'dart:async';
import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/l10n/generated/app_localizations.dart';

class LifeClock extends StatefulWidget {
  final DateTime birthDateTime;
  final TimeOfDay birthTime;

  const LifeClock({super.key, required this.birthDateTime, required this.birthTime});

  @override
  State<LifeClock> createState() => _LifeClockState();
}

class _LifeClockState extends State<LifeClock> {
  late Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<DateTime>(
      stream: _timeStream,
      builder: (context, snapshot) {
        

        if (!snapshot.hasData) {
          return CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurfaceVariant);
        }

        final now = snapshot.data!;
        final duration = now.difference(DateTime(widget.birthDateTime.year, widget.birthDateTime.month, widget.birthDateTime.day, widget.birthTime.hour, widget.birthTime.minute));

        final hours = duration.inHours;
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds;

        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrimaryH3(
                text: l10n.hoursOfLife(hours),
                textAlign: TextAlign.center,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              PrimaryH3(
                text: l10n.minutesOfLife(minutes),
                textAlign: TextAlign.center,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              PrimaryH3(
                text: l10n.secondsOfLife(seconds),
                textAlign: TextAlign.center,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ],
          ),
        );
      },
    );
  }
}
