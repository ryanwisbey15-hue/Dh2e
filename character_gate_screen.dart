import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/app_state.dart';

class CharacterGateScreen extends ConsumerWidget {
  const CharacterGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref.watch(characterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('DH2e Acolyte')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Build and play a character.\nAttach your rulebook PDF to jump to referenced pages.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.push('/builder'),
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text('Create new character'),
                    ),
                    const SizedBox(height: 12),
                    if (character != null)
                      OutlinedButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.person),
                        label: Text('Continue: ${character.name}'),
                      ),
                    if (character != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => ref.read(characterProvider.notifier).clear(),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Clear saved character'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => context.push('/pdf?page=28&title=Rulebook'),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Open rulebook (attach PDF first)'),
            ),
          ],
        ),
      ),
    );
  }
}
