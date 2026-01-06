import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/character.dart';
import '../../rules/rule_refs.dart';
import '../../state/app_state.dart';
import '../../state/data_catalog.dart';
import '../../widgets/rule_ref_card.dart';

class BuilderScreen extends ConsumerStatefulWidget {
  const BuilderScreen({super.key});

  @override
  ConsumerState<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends ConsumerState<BuilderScreen> {
  int _step = 0;
  CharacterSheet _draft = CharacterSheet.blank();

  final _nameCtrl = TextEditingController();

  // Static option lists (names only). Mechanics are referenced by page, not reproduced.
  static const homeWorlds = <String>[
    'Feral World',
    'Forge World',
    'Highborn',
    'Hive World',
    'Shrine World',
    'Voidborn',
  ];

  static const backgrounds = <String>[
    'Adeptus Administratum',
    'Adeptus Arbites',
    'Adeptus Astra Telepathica',
    'Adeptus Mechanicus',
    'Adeptus Ministorum',
    'Imperial Guard',
    'Outcast',
    'Adepta Sororitas',
  ];

  static const roles = <String>[
    'Assassin',
    'Chirurgeon',
    'Desperado',
    'Hierophant',
    'Mystic',
    'Sage',
    'Seeker',
    'Warrior',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = _draft.name;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    setState(() => _step = (_step + 1).clamp(0, 6));
  }

  void _back() {
    setState(() => _step = (_step - 1).clamp(0, 6));
  }

  Future<void> _save() async {
    final finalChar = _draft.copyWith(name: _nameCtrl.text.trim().isEmpty ? 'Acolyte' : _nameCtrl.text.trim());
    await ref.read(characterProvider.notifier).setCharacter(finalChar);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final skillsCatalog = ref.watch(skillsCatalogProvider);
    final equipCatalog = ref.watch(equipmentCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Rulebook (attach PDF in viewer)',
            onPressed: () => context.push('/pdf?page=28&title=Creating%20an%20Acolyte'),
          ),
        ],
      ),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _step == 6 ? _save : _next,
        onStepCancel: _step == 0 ? null : _back,
        controlsBuilder: (context, details) {
          final isLast = _step == 6;
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLast ? 'Save character' : 'Next'),
                ),
                const SizedBox(width: 12),
                if (_step != 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Identity'),
            subtitle: const Text('Basics and concept'),
            isActive: _step >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const RuleRefCard(refData: RuleRefs.creatingAnAcolyte),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Character name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tip: You can keep mechanics light here and use Stage 5 (p.82) later to flesh out motivations, ties, and beliefs.',
                ),
                const RuleRefCard(refData: RuleRefs.stage5Life),
              ],
            ),
          ),
          Step(
            title: const Text('Home World'),
            subtitle: const Text('Stage 1'),
            isActive: _step >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const RuleRefCard(refData: RuleRefs.stage1HomeWorld),
                DropdownButtonFormField<String>(
                  value: _draft.homeWorld.isEmpty ? null : _draft.homeWorld,
                  items: homeWorlds
                      .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                      .toList(),
                  onChanged: (v) => setState(() => _draft = _draft.copyWith(homeWorld: v ?? '')),
                  decoration: const InputDecoration(
                    labelText: 'Choose Home World',
                    prefixIcon: Icon(Icons.public),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Record the mechanical details from the rulebook for your chosen Home World '
                  '(Aptitudes, Characteristic modifiers, Wounds, Fate, and any special traits). '
                  'This app links you to the right page; it does not reproduce the table text.',
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Background'),
            subtitle: const Text('Stage 2'),
            isActive: _step >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const RuleRefCard(refData: RuleRefs.stage2Background),
                DropdownButtonFormField<String>(
                  value: _draft.background.isEmpty ? null : _draft.background,
                  items: backgrounds
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) => setState(() => _draft = _draft.copyWith(background: v ?? '')),
                  decoration: const InputDecoration(
                    labelText: 'Choose Background',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Background influences starting skills/talents, gear, and roleplay hooks. Use the PDF page link for specifics.',
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Role'),
            subtitle: const Text('Stage 3'),
            isActive: _step >= 3,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const RuleRefCard(refData: RuleRefs.stage3Role),
                DropdownButtonFormField<String>(
                  value: _draft.role.isEmpty ? null : _draft.role,
                  items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setState(() => _draft = _draft.copyWith(role: v ?? '')),
                  decoration: const InputDecoration(
                    labelText: 'Choose Role',
                    prefixIcon: Icon(Icons.assignment_ind_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Roles help define your advancement and party niche.'),
              ],
            ),
          ),
          Step(
            title: const Text('Stats'),
            subtitle: const Text('Characteristics & trackers'),
            isActive: _step >= 4,
            content: _StatsEditor(
              sheet: _draft,
              onChanged: (s) => setState(() => _draft = s),
            ),
          ),
          Step(
            title: const Text('Skills & Gear'),
            subtitle: const Text('Start playing'),
            isActive: _step >= 5,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const RuleRefCard(refData: RuleRefs.stage4XpEquip),
                skillsCatalog.when(
                  data: (skills) => _SkillPicker(
                    available: skills.map((e) => e.name).toList()..sort(),
                    sheet: _draft,
                    onChanged: (s) => setState(() => _draft = s),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Could not load skills list: $e'),
                ),
                const SizedBox(height: 12),
                equipCatalog.when(
                  data: (items) => _EquipmentPicker(
                    available: items.map((e) => e.name).toList()..sort(),
                    sheet: _draft,
                    onChanged: (s) => setState(() => _draft = s),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Could not load equipment list: $e'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Review'),
            subtitle: const Text('Save and go to sheet'),
            isActive: _step >= 6,
            content: _ReviewCard(sheet: _draft.copyWith(name: _nameCtrl.text)),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final CharacterSheet sheet;
  const _ReviewCard({required this.sheet});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sheet.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Home World: ${sheet.homeWorld.isEmpty ? '—' : sheet.homeWorld}'),
            Text('Background: ${sheet.background.isEmpty ? '—' : sheet.background}'),
            Text('Role: ${sheet.role.isEmpty ? '—' : sheet.role}'),
            const Divider(height: 24),
            Text('Wounds: ${sheet.woundsCurrent}/${sheet.woundsMax}'),
            Text('Fate: ${sheet.fateCurrent}/${sheet.fateMax}'),
            Text('Influence: ${sheet.influence} • Subtlety: ${sheet.subtlety}'),
            Text('Corruption: ${sheet.corruption} • Insanity: ${sheet.insanity}'),
            const Divider(height: 24),
            Text('Skills: ${sheet.skills.length} • Talents: ${sheet.talents.length} • Equipment: ${sheet.equipment.length}'),
            const SizedBox(height: 8),
            const Text('Hit "Save character" to finish.'),
          ],
        ),
      ),
    );
  }
}

class _StatsEditor extends StatelessWidget {
  final CharacterSheet sheet;
  final ValueChanged<CharacterSheet> onChanged;
  const _StatsEditor({required this.sheet, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = sheet.characteristics;

    Widget statField(String label, int value, ValueChanged<int> set) {
      final ctrl = TextEditingController(text: value.toString());
      return TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        onChanged: (v) => set(int.tryParse(v) ?? 0),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RuleRefCard(refData: RuleRefs.coreRules),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: 110, child: statField('WS', c.ws, (v) => onChanged(sheet.copyWith(characteristics: cCopy(c, ws: v))))),
            SizedBox(width: 110, child: statField('BS', c.bs, (v) => onChanged(sheet.copyWith(characteristics: cCopy(c, bs: v))))),
            SizedBox(width: 110, child: statField('S', c.s, (v) => onChanged(sheet.copyWith(characteristics: cCopy(c, s: v))))),
            SizedBox(width: 110, child: statField('T', c.t, (v) => onChanged(sheet.copyWith(characteristics: cCopy(c, t: v))))),
            SizedBox(width: 110, child: statField('Agi', c.agi, (v) => onChanged(sheet.copyWith(characteristics: cCopy(c, agi: v))))),
            SizedBox(width: 110, child: statField('Int', c.intl, (v) => onChanged(sheet.copyWith(characteristics: cCopy(c, intl: v))))),
            SizedBox(width: 110, child: statField('Per', c.per, (v) => onChanged(sheet.copyWith(characteristics: cCopy(c, per: v))))),
            SizedBox(width: 110, child: statField('WP', c.wp, (v) => onChanged(sheet.copyWith(characteristics: cCopy(c, wp: v))))),
            SizedBox(width: 110, child: statField('Fel', c.fel, (v) => onChanged(sheet.copyWith(characteristics: cCopy(c, fel: v))))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _NumField(
                label: 'Wounds (max)',
                value: sheet.woundsMax,
                onChanged: (v) => onChanged(sheet.copyWith(woundsMax: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NumField(
                label: 'Wounds (current)',
                value: sheet.woundsCurrent,
                onChanged: (v) => onChanged(sheet.copyWith(woundsCurrent: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _NumField(
                label: 'Fate (max)',
                value: sheet.fateMax,
                onChanged: (v) => onChanged(sheet.copyWith(fateMax: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NumField(
                label: 'Fate (current)',
                value: sheet.fateCurrent,
                onChanged: (v) => onChanged(sheet.copyWith(fateCurrent: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _NumField(
                label: 'Influence',
                value: sheet.influence,
                onChanged: (v) => onChanged(sheet.copyWith(influence: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NumField(
                label: 'Subtlety',
                value: sheet.subtlety,
                onChanged: (v) => onChanged(sheet.copyWith(subtlety: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _NumField(
                label: 'Corruption',
                value: sheet.corruption,
                onChanged: (v) => onChanged(sheet.copyWith(corruption: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NumField(
                label: 'Insanity',
                value: sheet.insanity,
                onChanged: (v) => onChanged(sheet.copyWith(insanity: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  CharacteristicBlock cCopy(
    CharacteristicBlock c, {
    int? ws,
    int? bs,
    int? s,
    int? t,
    int? agi,
    int? intl,
    int? per,
    int? wp,
    int? fel,
  }) =>
      CharacteristicBlock(
        ws: ws ?? c.ws,
        bs: bs ?? c.bs,
        s: s ?? c.s,
        t: t ?? c.t,
        agi: agi ?? c.agi,
        intl: intl ?? c.intl,
        per: per ?? c.per,
        wp: wp ?? c.wp,
        fel: fel ?? c.fel,
      );
}

class _NumField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: value.toString());
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
    );
  }
}

class _SkillPicker extends StatelessWidget {
  final List<String> available;
  final CharacterSheet sheet;
  final ValueChanged<CharacterSheet> onChanged;

  const _SkillPicker({
    required this.available,
    required this.sheet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.school_outlined),
                const SizedBox(width: 8),
                Text('Skills', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                _AddFromCatalogButton(
                  label: 'Add skill',
                  options: available,
                  onPick: (name) {
                    final next = List<SkillEntry>.from(sheet.skills)
                      ..add(SkillEntry(name: name));
                    onChanged(sheet.copyWith(skills: next));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (sheet.skills.isEmpty)
              const Text('No skills added yet.')
            else
              ...sheet.skills.map((s) => ListTile(
                    title: Text(s.name),
                    subtitle: Text('Advances: ${s.advances}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        final next = List<SkillEntry>.from(sheet.skills)
                          ..remove(s);
                        onChanged(sheet.copyWith(skills: next));
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _EquipmentPicker extends StatelessWidget {
  final List<String> available;
  final CharacterSheet sheet;
  final ValueChanged<CharacterSheet> onChanged;

  const _EquipmentPicker({
    required this.available,
    required this.sheet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined),
                const SizedBox(width: 8),
                Text('Equipment', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                _AddFromCatalogButton(
                  label: 'Add item',
                  options: available,
                  onPick: (name) {
                    final next = List<ItemEntry>.from(sheet.equipment)
                      ..add(ItemEntry(name: name, category: ItemCategory.gear));
                    onChanged(sheet.copyWith(equipment: next));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (sheet.equipment.isEmpty)
              const Text('No equipment added yet.')
            else
              ...sheet.equipment.map((e) => ListTile(
                    title: Text(e.name),
                    subtitle: Text('Category: ${e.category.name}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        final next = List<ItemEntry>.from(sheet.equipment)
                          ..remove(e);
                        onChanged(sheet.copyWith(equipment: next));
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _AddFromCatalogButton extends StatelessWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onPick;

  const _AddFromCatalogButton({
    required this.label,
    required this.options,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      icon: const Icon(Icons.add),
      onPressed: () async {
        final picked = await showDialog<String>(
          context: context,
          builder: (context) => _CatalogDialog(title: label, options: options),
        );
        if (picked != null) onPick(picked);
      },
    );
  }
}

class _CatalogDialog extends StatefulWidget {
  final String title;
  final List<String> options;

  const _CatalogDialog({required this.title, required this.options});

  @override
  State<_CatalogDialog> createState() => _CatalogDialogState();
}

class _CatalogDialogState extends State<_CatalogDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where((o) => o.toLowerCase().contains(_query.toLowerCase()))
        .take(100)
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
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final item = filtered[i];
                  return ListTile(
                    title: Text(item),
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
