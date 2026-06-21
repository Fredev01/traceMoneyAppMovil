import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final bool fullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = true,
    this.icon,
  });

  Color get _backgroundColor => switch (variant) {
        AppButtonVariant.primary => AppColors.primary,
        AppButtonVariant.secondary => AppColors.surfaceVariant,
        AppButtonVariant.danger => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
              )
            : Text(label);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: _backgroundColor),
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}
