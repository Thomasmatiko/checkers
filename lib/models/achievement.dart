
/// Represents one achievement in the Drafts game.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int target;

  int progress;
  bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    this.progress = 0,
    this.unlocked = false,
  });

  double get progressPercent {
    if (target <= 0) {
      return unlocked ? 1.0 : 0.0;
    }

    final value = progress / target;

    if (value > 1) {
      return 1.0;
    }

    return value;
  }

  String get progressText {
    if (unlocked) {
      return 'Completed';
    }

    return '$progress / $target';
  }

  void updateProgress(int value) {
    progress = value;

    if (progress >= target) {
      progress = target;
      unlocked = true;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progress': progress,
      'unlocked': unlocked,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    final savedProgress = json['progress'];

    if (savedProgress is int) {
      progress = savedProgress;
    } else if (savedProgress is double) {
      progress = savedProgress.toInt();
    }

    final savedUnlocked = json['unlocked'];

    if (savedUnlocked is bool) {
      unlocked = savedUnlocked;
    }

    if (progress >= target) {
      progress = target;
      unlocked = true;
    }
  }
}

