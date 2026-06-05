import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// First-launch disclaimer dialog. Call [DisclaimerDialog.show] on app start
/// when SharedPreferences flag [kFirstLaunchKey] is not set.
class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key, required this.onAccept});

  final VoidCallback onAccept;

  static Future<void> show(BuildContext context, VoidCallback onAccept) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DisclaimerDialog(onAccept: onAccept),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Educational Use Only',
              style: AppTypography.title,
            ),
          ),
        ],
      ),
      content: Text(
        'This app is for educational and language learning purposes only. '
        'It does not provide medical diagnosis, treatment advice, or professional '
        'medical opinion. Always consult a qualified healthcare professional for '
        'any medical concerns.',
        style: AppTypography.body,
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onAccept();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text('I Understand',
              style: AppTypography.button.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
