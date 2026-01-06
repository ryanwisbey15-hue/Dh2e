import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/character.dart';
import '../state/app_state.dart';
import '../screens/character_gate_screen.dart';
import '../screens/builder/builder_screen.dart';
import '../screens/home/home_shell.dart';
import '../rules/pdf_viewer_screen.dart';

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  late final ProviderSubscription<CharacterSheet?> _sub;

  RouterNotifier(this._ref) {
    _sub = _ref.listen<CharacterSheet?>(characterProvider, (prev, next) {
      if (prev?.id != next?.id) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  final character = ref.watch(characterProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CharacterGateScreen(),
      ),
      GoRoute(
        path: '/builder',
        builder: (context, state) => const BuilderScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: '/pdf',
        builder: (context, state) {
          final page = int.tryParse(state.uri.queryParameters['page'] ?? '') ?? 1;
          final title = state.uri.queryParameters['title'] ?? 'Rulebook';
          return PdfViewerScreen(initialPage: page, title: title);
        },
      ),
    ],
    redirect: (context, state) {
      final loc = state.uri.path;
      final hasChar = character != null;

      if (!hasChar && loc == '/home') return '/';
      if (hasChar && loc == '/') return '/home';
      return null;
    },
  );
});
