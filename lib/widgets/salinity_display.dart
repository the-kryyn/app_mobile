import 'package:flutter/material.dart';

class SalinityDisplay extends StatelessWidget {
  final double value;
  final VoidCallback onRefresh;

  const SalinityDisplay({
    super.key,
    required this.value,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = colorScheme.onPrimary;

    return GestureDetector(
      onTap: onRefresh,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        margin: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorScheme.primary,
          ),
          child: DefaultTextStyle(
            style: TextStyle(color: textColor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Valeur de salinité :',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  '${value.toStringAsFixed(4)} g/L',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Appuyez pour rafraîchir',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
