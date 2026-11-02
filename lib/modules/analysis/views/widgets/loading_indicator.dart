import 'package:flutter/material.dart';
import '../../../../app/config/theme/app_colores.dart';

class AnalysisLoadingIndicator extends StatelessWidget {
  final double progress;
  final String status;

  const AnalysisLoadingIndicator({
    super.key,
    required this.progress,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: progress > 0 ? progress : null,
            strokeWidth: 6,
            backgroundColor: AppColors.grey200,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          status,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
