import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

const _kCharKey = 'active_character_v1';
const _kPdfPathKey = 'rulebook_pdf_path_v1';

/// Overridden in main().
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPrefsProvider must be overridden in main()');
});

final pdfPathProvider = StateNotifierProvider<PdfPathController, String?>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return PdfPathController(prefs);
});

class PdfPathController extends StateNotifier<String?> {
  final SharedPreferences _prefs;
  PdfPathController(this._prefs) : super(_prefs.getString(_kPdfPathKey));

  Future<void> setPath(String? path) async {
    state = path;
    if (path == null) {
      await _prefs.remove(_kPdfPathKey);
    } else {
      await _prefs.setString(_kPdfPathKey, path);
    }
  }
}

final characterProvider =
    StateNotifierProvider<CharacterController, CharacterSheet?>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return CharacterController(prefs);
});

class CharacterController extends StateNotifier<CharacterSheet?> {
  final SharedPreferences _prefs;
  CharacterController(this._prefs) : super(null) {
    final raw = _prefs.getString(_kCharKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        state = CharacterSheet.fromJsonString(raw);
      } catch (_) {
        state = null;
      }
    }
  }

  Future<void> setCharacter(CharacterSheet c) async {
    state = c;
    await _prefs.setString(_kCharKey, c.toJsonString());
  }

  Future<void> clear() async {
    state = null;
    await _prefs.remove(_kCharKey);
  }
}
