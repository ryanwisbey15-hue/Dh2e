import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/character.dart';
import '../../../rules/damage.dart';
import '../../../rules/dice.dart';
import '../../../rules/rule_refs.dart';
import '../../../state/app_state.dart';
import '../../../widgets/rule_ref_card.dart';

class CombatTab extends ConsumerStatefulWidget {
  final CharacterSheet character;
  const CombatTab({super.key, required this.character});

  @override
  ConsumerState<CombatTab> createState() => _CombatTabState();
}

class _CombatTabState extends ConsumerState<CombatTab> {
  ItemEntry? _selectedWeapon;
  int _modifier = 0;
  D100Result? _lastAttack;
  String _damageExpr = '1d10';
  DamageRollResult? _lastDamage;

  @override
  void initState() {
    super.initState();
    _selectedWeapon = widget.character.equipment.where((e) => e.category == ItemCategory.weapon).isNotEmpty
        ? widget.character.equipment.where((e) => e.category == ItemCategory.weapon).first
        : null;
  }

  Future<void> _save(CharacterSheet next) =>
      ref.read(characterProvider.notifier).setCharacter(next);

  int _defaultTarget(CharacterSheet c) {
    // MVP heuristic: ranged weapon -> BS; melee -> WS. Unknown -> WS.
    final w = _selectedWeapon;
    if (w == null) return c.characteristics.ws;

    final name = w.name.toLowerCase();
    final rangedHints = ['gun', 'las', 'auto', 'pistol', 'rifle', 'bolter', 'shot'];
    final isRanged = rangedHints.any((h) => name.contains(h));
    return isRanged ? c.characteristics.bs : c.characteristics.ws;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    final weapons = c.equipment.where((e) => e.category == ItemCategory.weapon).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RuleRefCard(refData: RuleRefs.combat),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('In-combat quick controls', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _Tracker(
                  label: 'Wounds',
                  current: c.woundsCurrent,
                  max: c.woundsMax,
                  onChanged: (cur) => _save(c.copyWith(woundsCurrent: cur.clamp(0, 999))),
                ),
                const SizedBox(height: 8),
                _Tracker(
                  label: 'Fate',
                  current: c.fateCurrent,
                  max: c.fateMax,
                  onChanged: (cur) => _save(c.copyWith(fateCurrent: cur.clamp(0, 999))),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Attack test', style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    if (weapons.isNotEmpty)
                      DropdownButton<ItemEntry>(
                        value: _selectedWeapon,
                        hint: const Text('Weapon'),
                        items: weapons
                            .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedWeapon = v),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text('Target: ${_defaultTarget(c)}  •  Modifier: $_modifier'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setState(() => _modifier = (_modifier - 10).clamp(-120, 120)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _modifier = (_modifier + 10).clamp(-120, 120)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    final res = Dice.test(target: _defaultTarget(c), modifier: _modifier);
                    setState(() => _lastAttack = res);
                  },
                  icon: const Icon(Icons.casino),
                  label: const Text('Roll d100'),
                ),
                if (_lastAttack != null) ...[
                  const SizedBox(height: 12),
                  _AttackResultCard(result: _lastAttack!),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Damage roller', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Damage expression (e.g. 1d10+3)',
                    prefixIcon: Icon(Icons.bolt),
                  ),
                  controller: TextEditingController(text: _damageExpr),
                  onChanged: (v) => _damageExpr = v,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    final res = DamageRoller.roll(_damageExpr);
                    setState(() => _lastDamage = res);
                    if (res == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not parse expression. Try 1d10+3')),
                      );
                    }
                  },
                  icon: const Icon(Icons.casino_outlined),
                  label: const Text('Roll damage'),
                ),
                if (_lastDamage != null) ...[
                  const SizedBox(height: 12),
                  Text('Result: ${_lastDamage!.total}  (dice: ${_lastDamage!.dice.join(', ')}  mod: ${_lastDamage!.modifier})'),
                ],
                const SizedBox(height: 8),
                const Text(
                  'Next step: We can add armour/Toughness reduction and critical tracking with hit locations.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Tracker extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final ValueChanged<int> onChanged;

  const _Tracker({
    required this.label,
    required this.current,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('$label: $current / $max')),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => onChanged((current - 1).clamp(0, 999)),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged((current + 1).clamp(0, 999)),
        ),
      ],
    );
  }
}

class _AttackResultCard extends StatelessWidget {
  final D100Result result;
  const _AttackResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final effective = result.target + result.modifier;
    final label = result.success ? 'SUCCESS' : 'FAILURE';
    final deg = result.degrees;
    final degLabel = deg >= 0 ? '${deg} DoS' : '${deg.abs()} DoF';

    return Card(
      child: ListTile(
        leading: Icon(result.success ? Icons.check_circle : Icons.cancel),
        title: Text('$label • Roll ${result.roll} vs $effective'),
        subtitle: Text(degLabel),
      ),
    );
  }
}
