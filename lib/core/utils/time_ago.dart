import '../constants.dart';

enum FreshnessLevel {
  fresh, // < 15 min (Green)
  aging, // 15 - 45 min (Amber)
  stale, // > 45 min (Red)
}

/// Helper functions for formatting lastUpdated server timestamps and computing freshness level.
class TimeAgoUtil {
  static FreshnessLevel getFreshnessLevel(DateTime? lastUpdated) {
    if (lastUpdated == null) return FreshnessLevel.stale;
    final int minutes = DateTime.now().difference(lastUpdated).inMinutes;
    if (minutes < AppConstants.freshMinutesThreshold) {
      return FreshnessLevel.fresh;
    } else if (minutes <= AppConstants.agingMinutesThreshold) {
      return FreshnessLevel.aging;
    } else {
      return FreshnessLevel.stale;
    }
  }

  static int getMinutesAgo(DateTime? lastUpdated) {
    if (lastUpdated == null) return 999;
    final int minutes = DateTime.now().difference(lastUpdated).inMinutes;
    return minutes < 0 ? 0 : minutes;
  }

  static String formatTimeAgo(DateTime? lastUpdated) {
    if (lastUpdated == null) return 'Never updated';
    final int minutes = getMinutesAgo(lastUpdated);
    if (minutes == 0) return 'Updated just now';
    if (minutes == 1) return 'Updated 1 min ago';
    if (minutes < 60) return 'Updated $minutes min ago';
    final int hours = minutes ~/ 60;
    if (hours == 1) return 'Updated 1 hr ago';
    return 'Updated $hours hrs ago';
  }
}
