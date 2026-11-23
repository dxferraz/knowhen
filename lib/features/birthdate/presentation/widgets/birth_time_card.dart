import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/components/kn_card.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

String _two(int value) => value.toString().padLeft(2, '0');

/// `07:32`, sempre em 24 h.
String formatBirthTime(TimeOfDay time) =>
    '${_two(time.hour)}:${_two(time.minute)}';

/// Cartão da hora de nascimento: opcional, com um interruptor. Ligado, abre um seletor rolável de HH:MM na
/// própria tela, sem diálogo (DXF-9, 4.2).
class BirthTimeCard extends StatelessWidget {
  const BirthTimeCard({
    super.key,
    required this.enabled,
    required this.time,
    required this.onToggle,
    required this.onTimeChanged,
  });

  final bool enabled;
  final TimeOfDay time;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.kn;
    final text = context.knText;

    return KnCard(
      padding: const EdgeInsets.symmetric(
        horizontal: KnSpace.lg,
        vertical: KnSpace.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(Icons.schedule_rounded, color: c.accentText),
              ),
              const SizedBox(width: KnSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.birthdateTimeTitle, style: text.label),
                    Text(
                      enabled
                          ? l10n.birthdateTimeHelpOn(formatBirthTime(time))
                          : l10n.birthdateTimeHelpOff,
                      style: text.caption,
                    ),
                  ],
                ),
              ),
              Semantics(
                label: l10n.birthdateTimeToggle,
                child: Switch(
                  value: enabled,
                  onChanged: onToggle,
                  activeTrackColor: c.lavender,
                  activeThumbColor: c.isDark ? c.bg : Colors.white,
                  inactiveTrackColor: c.outline,
                  inactiveThumbColor: Colors.white,
                  trackOutlineColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.transparent
                        : c.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: KnSpace.md),
            Row(
              children: [
                Expanded(
                  child: _Wheel(
                    label: l10n.birthdateTimeHour,
                    count: 24,
                    value: time.hour,
                    onChanged: (hour) => onTimeChanged(
                      TimeOfDay(hour: hour, minute: time.minute),
                    ),
                  ),
                ),
                ExcludeSemantics(child: Text(':', style: text.stat)),
                Expanded(
                  child: _Wheel(
                    label: l10n.birthdateTimeMinute,
                    count: 60,
                    value: time.minute,
                    onChanged: (minute) => onTimeChanged(
                      TimeOfDay(hour: time.hour, minute: minute),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Uma coluna rolável (horas ou minutos). Para leitor de tela é um ajustável: deslizar para cima ou para
/// baixo muda o valor, já que girar a roda não é um gesto acessível.
class _Wheel extends StatefulWidget {
  const _Wheel({
    required this.label,
    required this.count,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int count;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.value);

  @override
  void didUpdateWidget(_Wheel old) {
    super.didUpdateWidget(old);
    // Mudança vinda de fora da roda (ex.: leitor de tela): leva a roda até o novo valor.
    if (widget.value != old.value &&
        _controller.hasClients &&
        _controller.selectedItem % widget.count != widget.value) {
      _controller.jumpToItem(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(int delta) =>
      widget.onChanged((widget.value + delta) % widget.count);

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    final style = context.knText.stat;
    // A altura de cada linha acompanha a fonte do sistema, para o número nunca ser cortado.
    final extent = MediaQuery.textScalerOf(
      context,
    ).scale(style.fontSize! * 1.4);

    return Semantics(
      label: widget.label,
      value: _two(widget.value),
      increasedValue: _two((widget.value + 1) % widget.count),
      decreasedValue: _two((widget.value - 1) % widget.count),
      onIncrease: () => _step(1),
      onDecrease: () => _step(-1),
      child: ExcludeSemantics(
        child: SizedBox(
          height: extent * 3,
          child: CupertinoPicker(
            scrollController: _controller,
            itemExtent: extent,
            looping: true,
            selectionOverlay: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: c.outline),
                ),
              ),
            ),
            onSelectedItemChanged: (index) {
              // A roda também avisa ao ser montada e ao ser reposicionada por fora, sem o usuário ter rolado.
              if (index % widget.count != widget.value) {
                widget.onChanged(index % widget.count);
              }
            },
            children: [
              for (var i = 0; i < widget.count; i++)
                Center(child: Text(_two(i), style: style)),
            ],
          ),
        ),
      ),
    );
  }
}
