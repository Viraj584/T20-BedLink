import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/time_ago.dart';

class FreshnessBadge extends StatelessWidget {
  final DateTime? lastUpdated;
  final bool compact;

  const FreshnessBadge({
    super.key,
    required this.lastUpdated,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final freshness = TimeAgoUtil.getFreshnessLevel(lastUpdated);
    final text = TimeAgoUtil.formatTimeAgo(lastUpdated);

    Color bgColor;
    Color textColor;
    Color borderColor;
    IconData iconData;

    switch (freshness) {
      case FreshnessLevel.fresh:
        bgColor = AppColors.successTint;
        textColor = AppColors.success;
        borderColor = AppColors.success.withValues(alpha: 0.3);
        iconData = Icons.check_circle_outline;
        break;
      case FreshnessLevel.aging:
        bgColor = AppColors.warningTint;
        textColor = AppColors.warningText;
        borderColor = AppColors.warning.withValues(alpha: 0.3);
        iconData = Icons.access_time;
        break;
      case FreshnessLevel.stale:
        bgColor = AppColors.dangerTint;
        textColor = AppColors.danger;
        borderColor = AppColors.danger.withValues(alpha: 0.3);
        iconData = Icons.warning_amber_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: compact ? 14 : 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            freshness == FreshnessLevel.stale && !compact
                ? 'Stale data ($text)'
                : text,
            style: TextStyle(
              color: textColor,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
