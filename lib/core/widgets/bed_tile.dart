import 'package:flutter/material.dart';
import '../theme.dart';
import '../../models/bed_inventory.dart';

class BedTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final BedCount bedCount;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onToggleFull;

  const BedTile({
    super.key,
    required this.title,
    required this.icon,
    required this.bedCount,
    required this.onCountChanged,
    required this.onToggleFull,
  });

  @override
  Widget build(BuildContext context) {
    final available = bedCount.available;
    final total = bedCount.total;

    Color borderColor;
    Color bgColor;
    Color textColor;
    String statusPillText;
    Color statusPillBg;
    Color statusPillTextColor;

    if (available == 0) {
      borderColor = AppColors.danger;
      bgColor = AppColors.dangerTint;
      textColor = AppColors.danger;
      statusPillText = 'FULL';
      statusPillBg = AppColors.danger;
      statusPillTextColor = Colors.white;
    } else if (available <= 2) {
      borderColor = AppColors.warning;
      bgColor = AppColors.warningTint;
      textColor = AppColors.warningText;
      statusPillText = 'LOW ($available LEFT)';
      statusPillBg = AppColors.warning;
      statusPillTextColor = Colors.white;
    } else {
      borderColor = AppColors.success;
      bgColor = AppColors.successTint;
      textColor = AppColors.success;
      statusPillText = 'AVAILABLE';
      statusPillBg = AppColors.success;
      statusPillTextColor = Colors.white;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggleFull,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Icon, Title & Status Pill
                Row(
                  children: [
                    Icon(icon, color: AppColors.primaryDark, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusPillBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusPillText,
                        style: TextStyle(
                          color: statusPillTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Middle row: Count display & tap to toggle hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$available',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        Text(
                          ' / $total total',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    // Large + and - controls
                    Row(
                      children: [
                        // Decrement Button
                        IconButton.filledTonal(
                          onPressed: available > 0
                              ? () => onCountChanged(available - 1)
                              : null,
                          icon: const Icon(Icons.remove_rounded, size: 28),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(56, 56),
                            backgroundColor: available > 0
                                ? AppColors.surface
                                : AppColors.divider.withValues(alpha: 0.5),
                            foregroundColor: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Increment Button
                        IconButton.filled(
                          onPressed: available < total
                              ? () => onCountChanged(available + 1)
                              : null,
                          icon: const Icon(Icons.add_rounded, size: 28),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(56, 56),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
