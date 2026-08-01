import 'package:flutter/material.dart';

import '../context_extensions.dart';
import '../glass_theme.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'glass_container.dart';

/// Hierarquia de ação.
enum AppButtonVariant {
  /// Ação principal da tela. Gradiente sólido — só uma por tela.
  primary,

  /// Ação secundária. Vidro translúcido.
  glass,

  /// Ação terciária/descartável. Sem fundo.
  ghost,
}

enum AppButtonSize { small, medium, large }

/// Botão padrão do app.
///
/// O primário é o único elemento sólido do sistema: ele precisa "furar" o
/// vidro para ser inequivocamente a ação principal.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.expand = false,
    this.loading = false,
    this.foregroundColor,
    this.gradient,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;

  /// Ocupa toda a largura disponível.
  final bool expand;

  final bool loading;

  /// Sobrescreve a cor do conteúdo (use apenas em casos de marca).
  final Color? foregroundColor;

  /// Sobrescreve o gradiente do variante primário.
  final Gradient? gradient;

  double get _height => switch (size) {
        AppButtonSize.small => 40,
        AppButtonSize.medium => 48,
        AppButtonSize.large => 56,
      };

  double get _horizontalPadding => switch (size) {
        AppButtonSize.small => AppSpacing.medium,
        AppButtonSize.medium => AppSpacing.large,
        AppButtonSize.large => AppSpacing.xLarge,
      };

  TextStyle get _textStyle => switch (size) {
        AppButtonSize.small => AppTypography.labelMedium,
        AppButtonSize.medium => AppTypography.labelLarge,
        AppButtonSize.large => AppTypography.titleMedium,
      };

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final bool enabled = onPressed != null && !loading;

    final Color foreground = foregroundColor ??
        switch (variant) {
          AppButtonVariant.primary => glass.onGradient,
          AppButtonVariant.glass => context.colors.textPrimary,
          AppButtonVariant.ghost => context.colors.textSecondary,
        };

    final Widget content = _ButtonContent(
      label: label,
      icon: icon,
      trailingIcon: trailingIcon,
      loading: loading,
      foreground: foreground,
      textStyle: _textStyle.copyWith(color: foreground),
      iconSize: size == AppButtonSize.small ? 16 : 20,
    );

    final BorderRadius radius = BorderRadius.circular(AppRadius.pill);

    Widget button = switch (variant) {
      AppButtonVariant.primary => _PrimaryShell(
          height: _height,
          horizontalPadding: _horizontalPadding,
          radius: radius,
          gradient: gradient ?? glass.brandGradient,
          shadowColor: context.colors.primary,
          child: content,
        ),
      AppButtonVariant.glass => GlassContainer(
          level: GlassLevel.subtle,
          height: _height,
          borderRadius: radius,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: content,
        ),
      AppButtonVariant.ghost => SizedBox(
          height: _height,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Center(child: content),
          ),
        ),
    };

    if (expand) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: AnimatedOpacity(
        duration: AppMotion.fast,
        opacity: enabled ? 1 : 0.45,
        child: _Pressable(
          onTap: enabled ? onPressed : null,
          borderRadius: radius,
          child: button,
        ),
      ),
    );
  }
}

class _PrimaryShell extends StatelessWidget {
  const _PrimaryShell({
    required this.height,
    required this.horizontalPadding,
    required this.radius,
    required this.gradient,
    required this.shadowColor,
    required this.child,
  });

  final double height;
  final double horizontalPadding;
  final BorderRadius radius;
  final Gradient gradient;
  final Color shadowColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: context.isDark ? 0.42 : 0.32),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -6,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.trailingIcon,
    required this.loading,
    required this.foreground,
    required this.textStyle,
    required this.iconSize,
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final Color foreground;
  final TextStyle textStyle;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        height: iconSize,
        width: iconSize,
        child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: foreground),
          const SizedBox(width: AppSpacing.small),
        ],
        Flexible(
          child: Text(
            label,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.small),
          Icon(trailingIcon, size: iconSize, color: foreground),
        ],
      ],
    );
  }
}

class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.onTap,
    required this.borderRadius,
    required this.child,
  });

  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
