import 'dart:math';

class DamageRollResult {
  final int total;
  final List<int> dice;
  final int modifier;
  final int sides;
  final int count;

  const DamageRollResult({
    required this.total,
    required this.dice,
    required this.modifier,
    required this.sides,
    required this.count,
  });
}

class DamageRoller {
  static final _rng = Random();

  /// Parses strings like:
  /// - "1d10+3"
  /// - "2d5"
  /// - "1d10-1"
  ///
  /// Anything else returns null.
  static DamageRollResult? roll(String expr) {
    final cleaned = expr.trim().toLowerCase().replaceAll(' ', '');
    final re = RegExp(r'^(\d+)d(\d+)([+-]\d+)?');
    final m = re.firstMatch(cleaned);
    if (m == null) return null;

    final count = int.tryParse(m.group(1)!) ?? 0;
    final sides = int.tryParse(m.group(2)!) ?? 0;
    final mod = int.tryParse(m.group(3) ?? '0') ?? 0;
    if (count <= 0 || sides <= 1) return null;

    final dice = List<int>.generate(count, (_) => _rng.nextInt(sides) + 1);
    final total = dice.fold<int>(0, (a, b) => a + b) + mod;
    return DamageRollResult(total: total, dice: dice, modifier: mod, sides: sides, count: count);
  }
}
