import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Clinical risk level badge supporting all 5 tiers from the MedAssist AI V2 Risk Engine:
/// LOW (Benign), MODERATE, HIGH, CRITICAL (Melanoma), and INCONCLUSIVE (Borderline/Atypical).
class RiskLevelBadge extends StatelessWidget {
  final String riskLevel;
  final bool showExplanation;
  final String? customExplanation;

  const RiskLevelBadge({
    super.key,
    required this.riskLevel,
    this.showExplanation = false,
    this.customExplanation,
  });

  @override
  Widget build(BuildContext context) {
    final level = riskLevel.toUpperCase().trim();
    final Color badgeColor = _getBadgeColor(level);
    final IconData badgeIcon = _getBadgeIcon(level);
    final String labelText = _getLocalizedRiskLabel(level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: badgeColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(badgeIcon, color: badgeColor, size: 20),
              const SizedBox(width: 8),
              Text(
                labelText,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        if (showExplanation && customExplanation != null && customExplanation!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            customExplanation!,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  static Color _getBadgeColor(String level) {
    switch (level) {
      case 'BENIGN':
      case 'FAIBLE':
      case 'LOW':
        return const Color(0xFF22C55E); // Green
      case 'MODÉRÉ':
      case 'MODERATE':
        return const Color(0xFFF59E0B); // Amber
      case 'ÉLEVÉ':
      case 'HIGH':
        return const Color(0xFFEF4444); // Red
      case 'CRITICAL':
        return const Color(0xFF7C3AED); // Purple
      case 'INCONCLUSIVE':
      case 'INCONCLUANT':
      default:
        return const Color(0xFF64748B); // Slate Grey
    }
  }

  static IconData _getBadgeIcon(String level) {
    switch (level) {
      case 'BENIGN':
      case 'FAIBLE':
      case 'LOW':
        return Icons.check_circle_rounded;
      case 'MODÉRÉ':
      case 'MODERATE':
        return Icons.warning_amber_rounded;
      case 'ÉLEVÉ':
      case 'HIGH':
        return Icons.report_problem_rounded;
      case 'CRITICAL':
        return Icons.dangerous_rounded;
      case 'INCONCLUSIVE':
      case 'INCONCLUANT':
      default:
        return Icons.help_outline_rounded;
    }
  }

  static String _getLocalizedRiskLabel(String level) {
    switch (level) {
      case 'BENIGN':
      case 'FAIBLE':
      case 'LOW':
        return 'risk_low'.tr;
      case 'MODÉRÉ':
      case 'MODERATE':
        return 'risk_moderate'.tr;
      case 'ÉLEVÉ':
      case 'HIGH':
        return 'risk_high'.tr;
      case 'CRITICAL':
        return 'risk_critical'.tr;
      case 'INCONCLUSIVE':
      case 'INCONCLUANT':
      default:
        return 'risk_inconclusive'.tr;
    }
  }
}
