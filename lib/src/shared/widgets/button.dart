// lib/src/shared/widgets/custom_button.dart

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;  // Icon before text
  final IconData? trailingIcon; // Icon after text
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height = 55,
    this.borderRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colors.primary,
          foregroundColor: textColor ?? colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          disabledBackgroundColor: colors.primary.withAlpha((0.6 * 255).toInt()),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(textColor ?? colors.onPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Leading icon
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 22),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor ?? colors.onPrimary,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 4),
                    Icon(trailingIcon, size: 24),
                  ],
                ],
              ),
      ),
    );
  }
}