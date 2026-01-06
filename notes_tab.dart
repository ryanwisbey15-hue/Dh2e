import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/character.dart';
import '../../../state/app_state.dart';
import '../../../rules/rule_refs.dart';
import '../../../widgets/rule_ref_card.dart';

class NotesTab extends ConsumerStatefulWidget {
  final CharacterSheet character;
  const NotesTab({super.key, required this.character});

  @override
  ConsumerState<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<NotesTab> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.character.notes);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final next = widget.character.copyWith(notes: _ctrl.text);
    await ref.read(characterProvider.notifier).setCharacter(next);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RuleRefCard(refData: RuleRefs.stage5Life),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Notes', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: _ctrl,
                  minLines: 10,
                  maxLines: 30,
                  decoration: const InputDecoration(
                    hintText: 'Contacts, clues, session recap, NPC names, goals…',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
