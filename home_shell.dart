import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_state.dart';
import 'tabs/sheet_tab.dart';
import 'tabs/manage_tab.dart';
import 'tabs/combat_tab.dart';
import 'tabs/dice_tab.dart';
import 'tabs/notes_tab.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(characterProvider);
    if (character == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tabs = [
      SheetTab(character: character),
      ManageTab(character: character),
      CombatTab(character: character),
      const DiceTab(),
      NotesTab(character: character),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) async {
              switch (v) {
                case 'edit':
                  context.push('/builder');
                  break;
                case 'pdf':
                  context.push('/pdf?page=28&title=Rulebook');
                  break;
                case 'clear':
                  await ref.read(characterProvider.notifier).clear();
                  if (context.mounted) context.go('/');
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit character')),
              PopupMenuItem(value: 'pdf', child: Text('Open rulebook')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'clear', child: Text('Clear saved character')),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Sheet'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Manage'),
          NavigationDestination(icon: Icon(Icons.sports_martial_arts), label: 'Combat'),
          NavigationDestination(icon: Icon(Icons.casino_outlined), label: 'Dice'),
          NavigationDestination(icon: Icon(Icons.note_alt_outlined), label: 'Notes'),
        ],
      ),
    );
  }
}
