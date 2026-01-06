import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/character.dart';
import '../../../rules/rule_refs.dart';
import '../../../state/app_state.dart';
import '../../../state/data_catalog.dart';
import '../../../widgets/rule_ref_card.dart';

class ManageTab extends ConsumerWidget {
  final CharacterSheet character;
  const ManageTab({super.key, required this.character});

  Future<void> _save(WidgetRef ref, CharacterSheet next) =>
      ref.read(characterProvider.notifier).setCharacter(next);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Skills'),
              Tab(text: 'Talents'),
              Tab(text: 'Equipment'),
              Tab(text: 'XP'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _SkillsPane(character: character, onSave: (c) => _save(ref, c)),
                _TalentsPane(character: character, onSave: (c) => _save(ref, c)),
                _EquipmentPane(character: character, onSave: (c) => _save(ref, c)),
                _XpPane(character: character, onSave: (c) => _save(ref, c)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsPane extends ConsumerWidget {
  final CharacterSheet character;
  final ValueChanged<CharacterSheet> onSave;
  const _SkillsPane({required this.character, required this.onSave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(skillsCatalogProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RuleRefCard(refData: RuleRefs.skills),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Skills', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            catalog.when(
              data: (items) => IconButton(
                tooltip: 'Add',
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final picked = await _pickFromList(
                    context,
                    title: 'Add skill',
                    options: (items.map((e) => e.name).toList()..sort()),
                  );
                  if (picked == null) return;
                  final next = List<SkillEntry>.from(character.skills)
                    ..add(SkillEntry(name: picked));
                  onSave(character.copyWith(skills: next));
                },
              ),
              loading: () => const SizedBox(width: 28, height: 28, child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (character.skills.isEmpty)
          const Text('No skills yet.')
        else
          ...character.skills.map((s) => Card(
                child: ListTile(
                  title: Text(s.name),
                  subtitle: Text('Advances: ${s.advances}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          final idx = character.skills.indexOf(s);
                          final next = List<SkillEntry>.from(character.skills);
                          next[idx] = SkillEntry(name: s.name, advances: (s.advances - 1).clamp(0, 99));
                          onSave(character.copyWith(skills: next));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final idx = character.skills.indexOf(s);
                          final next = List<SkillEntry>.from(character.skills);
                          next[idx] = SkillEntry(name: s.name, advances: (s.advances + 1).clamp(0, 99));
                          onSave(character.copyWith(skills: next));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          final next = List<SkillEntry>.from(character.skills)..remove(s);
                          onSave(character.copyWith(skills: next));
                        },
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}

class _TalentsPane extends StatelessWidget {
  final CharacterSheet character;
  final ValueChanged<CharacterSheet> onSave;
  const _TalentsPane({required this.character, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RuleRefCard(refData: RuleRefs.talentsTraits),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Talents', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            IconButton(
              tooltip: 'Add',
              icon: const Icon(Icons.add),
              onPressed: () async {
                final name = await _askText(context, 'Talent name');
                if (name == null || name.trim().isEmpty) return;
                final next = List<TalentEntry>.from(character.talents)
                  ..add(TalentEntry(name: name.trim()));
                onSave(character.copyWith(talents: next));
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (character.talents.isEmpty)
          const Text('No talents yet.')
        else
          ...character.talents.map((t) => Card(
                child: ListTile(
                  title: Text(t.name),
                  subtitle: t.notes.isEmpty ? null : Text(t.notes),
                  onTap: () async {
                    final notes = await _askText(context, 'Notes for ${t.name}', initial: t.notes);
                    if (notes == null) return;
                    final idx = character.talents.indexOf(t);
                    final next = List<TalentEntry>.from(character.talents);
                    next[idx] = TalentEntry(name: t.name, notes: notes);
                    onSave(character.copyWith(talents: next));
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      final next = List<TalentEntry>.from(character.talents)..remove(t);
                      onSave(character.copyWith(talents: next));
                    },
                  ),
                ),
              )),
      ],
    );
  }
}

class _EquipmentPane extends ConsumerWidget {
  final CharacterSheet character;
  final ValueChanged<CharacterSheet> onSave;
  const _EquipmentPane({required this.character, required this.onSave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(equipmentCatalogProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RuleRefCard(refData: RuleRefs.armoury),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Equipment', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            catalog.when(
              data: (items) => IconButton(
                tooltip: 'Add',
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final picked = await _pickFromList(
                    context,
                    title: 'Add item',
                    options: (items.map((e) => e.name).toList()..sort()),
                  );
                  if (picked == null) return;

                  final category = await showDialog<ItemCategory>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Text('Category'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, ItemCategory.weapon),
                          child: const Text('Weapon'),
                        ),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, ItemCategory.armour),
                          child: const Text('Armour'),
                        ),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, ItemCategory.gear),
                          child: const Text('Gear'),
                        ),
                      ],
                    ),
                  );

                  final next = List<ItemEntry>.from(character.equipment)
                    ..add(ItemEntry(name: picked, category: category ?? ItemCategory.gear));

                  onSave(character.copyWith(equipment: next));
                },
              ),
              loading: () => const SizedBox(width: 28, height: 28, child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (character.equipment.isEmpty)
          const Text('No equipment yet.')
        else
          ...character.equipment.map((e) => Card(
                child: ListTile(
                  title: Text(e.name),
                  subtitle: Text(e.category.name),
                  onTap: () async {
                    if (e.category != ItemCategory.weapon) return;
                    final dmg = await _askText(context, 'Damage for ${e.name}', initial: e.damage ?? '');
                    if (dmg == null) return;
                    final pen = await _askInt(context, 'Penetration for ${e.name}', initial: e.penetration ?? 0);
                    if (pen == null) return;
                    final qual = await _askText(context, 'Qualities for ${e.name}', initial: e.qualities ?? '');
                    if (qual == null) return;

                    final idx = character.equipment.indexOf(e);
                    final next = List<ItemEntry>.from(character.equipment);
                    next[idx] = ItemEntry(
                      name: e.name,
                      category: e.category,
                      damage: dmg.trim().isEmpty ? null : dmg.trim(),
                      penetration: pen,
                      qualities: qual.trim().isEmpty ? null : qual.trim(),
                    );
                    onSave(character.copyWith(equipment: next));
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      final next = List<ItemEntry>.from(character.equipment)..remove(e);
                      onSave(character.copyWith(equipment: next));
                    },
                  ),
                ),
              )),
      ],
    );
  }
}

class _XpPane extends StatelessWidget {
  final CharacterSheet character;
  final ValueChanged<CharacterSheet> onSave;
  const _XpPane({required this.character, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final remaining = (character.xpTotal - character.xpSpent).clamp(0, 1 << 31);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RuleRefCard(refData: RuleRefs.stage4XpEquip),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Experience', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Total XP: ${character.xpTotal}'),
                Text('Spent XP: ${character.xpSpent}'),
                Text('Remaining XP: $remaining'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          final v = await _askInt(context, 'Set total XP', initial: character.xpTotal);
                          if (v == null) return;
                          onSave(character.copyWith(xpTotal: v));
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Set total'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final v = await _askInt(context, 'Set spent XP', initial: character.xpSpent);
                          if (v == null) return;
                          onSave(character.copyWith(xpSpent: v));
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Set spent'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Next step: We can add an aptitude-aware XP calculator once you tell me whether you want strict validation '
          '(enforces the rules) or “assist mode” (helps but allows overrides).',
        ),
      ],
    );
  }
}

Future<String?> _askText(BuildContext context, String title, {String initial = ''}) {
  final ctrl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(labelText: 'Text'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Save')),
      ],
    ),
  );
}

Future<int?> _askInt(BuildContext context, String title, {int initial = 0}) {
  final ctrl = TextEditingController(text: initial.toString());
  return showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Number'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)), child: const Text('Save')),
      ],
    ),
  );
}

Future<String?> _pickFromList(
  BuildContext context, {
  required String title,
  required List<String> options,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _PickDialog(title: title, options: options),
  );
}

class _PickDialog extends StatefulWidget {
  final String title;
  final List<String> options;
  const _PickDialog({required this.title, required this.options});

  @override
  State<_PickDialog> createState() => _PickDialogState();
}

class _PickDialogState extends State<_PickDialog> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where((o) => o.toLowerCase().contains(q.toLowerCase()))
        .take(120)
        .toList();

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => q = v),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(filtered[i]),
                  onTap: () => Navigator.pop(context, filtered[i]),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ],
    );
  }
}
