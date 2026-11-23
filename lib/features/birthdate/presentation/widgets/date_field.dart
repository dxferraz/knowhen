import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Um dos campos numéricos da data (Dia, Mês ou Ano). O foco avança sozinho ao completar [maxLength]
/// dígitos e volta para [previous] ao apagar um campo já vazio.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.maxLength,
    required this.onChanged,
    this.next,
    this.previous,
    this.hasError = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int maxLength;
  final FocusNode? next;
  final FocusNode? previous;
  final bool hasError;
  final VoidCallback onChanged;

  static const double _maxTextScale = 1.3;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    final text = context.knText;

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(KnRadius.sm),
      borderSide: BorderSide(color: color, width: width),
    );

    final idle = border(hasError ? c.danger : c.outline, 1);
    final focused = border(hasError ? c.danger : c.lavender, 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Text(label, style: text.caption)),
        const SizedBox(height: KnSpace.xs),
        MergeSemantics(
          child: Semantics(
            label: label,
            child: Focus(
              skipTraversal: true,
              onKeyEvent: (_, event) {
                final backspace =
                    event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace;
                if (backspace && controller.text.isEmpty && previous != null) {
                  previous!.requestFocus();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              // Campo de largura fixa: a 200% os dígitos não caberiam. O rótulo e o resto da tela seguem a fonte do sistema.
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: _maxTextScale,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: next == null
                      ? TextInputAction.done
                      : TextInputAction.next,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(maxLength),
                  ],
                  style: text.title,
                  cursorColor: c.accentText,
                  onChanged: (value) {
                    if (value.length == maxLength) next?.requestFocus();
                    onChanged();
                  },
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: text.title.copyWith(color: c.inkMuted),
                    filled: true,
                    fillColor: c.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: KnSpace.sm,
                      vertical: KnSpace.lg,
                    ),
                    enabledBorder: idle,
                    focusedBorder: focused,
                    border: idle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
