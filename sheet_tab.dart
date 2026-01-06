import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/character.dart';
import '../../../rules/rule_refs.dart';
import '../../../state/app_state.dart';
import '../../../widgets/rule_ref_card.dart';

class SheetTab extends ConsumerWidget {
  final CharacterSheet character;
  const SheetTab({super.key, required this.character});

  Future<void> _update(WidgetRef ref, CharacterSheet next) async {
    await ref.read(characterProvider.notifier).setCharacter(next);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = character.characteristics;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Home World: ${character.homeWorld.isEmpty ? '—' : character.homeWorld}'),
                Text('Background: ${character.background.isEmpty ? '—' : character.background}'),
                Text('Role: ${character.role.isEmpty ? '—' : character.role}'),
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
                Text('Characteristics', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ChipStat('WS', c.ws),
                    _ChipStat('BS', c.bs),
                    _ChipStat('S', c.s),
                    _ChipStat('T', c.t),
                    _ChipStat('Agi', c.agi),
                    _ChipStat('Int', c.intl),
                    _ChipStat('Per', c.per),
                    _ChipStat('WP', c.wp),
                    _ChipStat('Fel', c.fel),
                  ],
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
                Text('Trackers', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _TrackerRow(
                  label: 'Wounds',
                  left: character.woundsCurrent,
                  right: character.woundsMax,
                  onChanged: (cur, max) => _update(ref, character.copyWith(woundsCurrent: cur, woundsMax: max)),
                ),
                const SizedBox(height: 8),
                _TrackerRow(
                  label: 'Fate',
                  left: character.fateCurrent,
                  right: character.fateMax,
                  onChanged: (cur, max) => _update(ref, character.copyWith(fateCurrent: cur, fateMax: max)),
                ),
                const Divider(height: 24),
                _SingleTracker(
                  label: 'Influence',
                  value: character.influence,
                  onChanged: (v) => _update(ref, character.copyWith(influence: v)),
                ),
                const SizedBox(height: 8),
                _SingleTracker(
                  label: 'Subtlety',
                  value: character.subtlety,
                  onChanged: (v) => _update(ref, character.copyWith(subtlety: v)),
                ),
                const Divider(height: 24),
                _SingleTracker(
                  label: 'Corruption',
                  value: character.corruption,
                  onChanged: (v) => _update(ref, character.copyWith(corruption: v)),
                ),
                const SizedBox(height: 8),
                _SingleTracker(
                  label: 'Insanity',
                  value: character.insanity,
                  onChanged: (v) => _update(ref, character.copyWith(insanity: v)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const RuleRefCard(refData: RuleRefs.coreRules),
      ],
    );
  }
}

class _ChipStat extends StatelessWidget {
  final String label;
  final int value;
  const _ChipStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label $value'),
      avatar: const Icon(Icons.bar_chart, size: 18),
    );
  }
}

class _TrackerRow extends StatelessWidget {
  final String label;
  final int left;
  final int right;
  final void Function(int cur, int max) onChanged;

  const _TrackerRow({
    required this.label,
    required this.left,
    required this.right,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => onChanged((left - 1).clamp(0, 999), right),
        ),
        Text('$left / $right'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged((left + 1).clamp(0, 999), right),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Set max',
          onPressed: () async {
            final max = await _askInt(context, '$label max', right);
            if (max != null) onChanged(left.clamp(0, max), max);
          },
        ),
      ],
    );
  }

  Future<int?> _askInt(BuildContext context, String title, int initial) async {
    final ctrl = TextEditingController(text: initial.toString());
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Value'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SingleTracker extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _SingleTracker({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => onChanged((value - 1).clamp(0, 999)),
        ),
        Text('$value'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged((value + 1).clamp(0, 999)),
        ),
      ],
    );
  }
}
