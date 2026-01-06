import 'dart:math';

class D100Result {
  final int roll; // 1..100
  final int target;
  final int modifier;
  final bool success;
  /// Degrees of Success (positive) or Degrees of Failure (negative)
  final int degrees;

  const D100Result({
    required this.roll,
    required this.target,
    required this.modifier,
    required this.success,
    required this.degrees,
  });
}

class Dice {
  static final _rng = Random();

  static int d(int sides) => _rng.nextInt(sides) + 1;

  static int d100() => d(100);

  /// Dark Heresy 2e uses a d100 roll-under test:
  /// - success if roll <= (target + modifier)
  /// - Degrees are derived from the tens difference.
  ///
  /// This function intentionally stays mechanical; the app can label
  /// results as "DoS/DoF" without quoting rulebook text.
  static D100Result test({
    required int target,
    int modifier = 0,
  }) {
    final roll = d100();
    final effective = target + modifier;
    final success = roll <= effective;

    if (success) {
      final degrees = 1 + ((effective - roll) ~/ 10);
      return D100Result(
        roll: roll,
        target: target,
        modifier: modifier,
        success: true,
        degrees: degrees,
      );
    } else {
      final degrees = -(1 + ((roll - effective) ~/ 10));
      return D100Result(
        roll: roll,
        target: target,
        modifier: modifier,
        success: false,
        degrees: degrees,
      );
    }
  }
}
