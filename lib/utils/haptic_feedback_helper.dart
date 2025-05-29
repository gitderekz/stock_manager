import 'package:flutter_vibrate/flutter_vibrate.dart';

class HapticFeedbackHelper {
  static Future<void> lightImpact() async {
    if (await Vibrate.canVibrate) {
      Vibrate.feedback(FeedbackType.light);
    }
  }

  static Future<void> selectionClick() async {
    if (await Vibrate.canVibrate) {
      Vibrate.feedback(FeedbackType.selection);
    }
  }

  static Future<void> errorVibration() async {
    if (await Vibrate.canVibrate) {
      Vibrate.vibrate();
      await Future.delayed(const Duration(milliseconds: 100));
      Vibrate.vibrate();
    }
  }
}