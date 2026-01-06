# DH2e Acolyte (Flutter)

Fan-made character builder and play assistant for Dark Heresy 2nd Edition.

## What this project is (and isn’t)
- Implements *mechanics and tooling* (dice, degrees, character sheet management, combat helper).
- Lets the user load their own legally obtained PDF and jump to page references.
- Does **not** ship any copyrighted rulebook text or the PDF.

## Run
1) Install Flutter (stable).
2) From this folder:
   - `flutter pub get`
   - `flutter run`

## PDF references
In-app: Settings → Attach Rulebook PDF → pick your DH2e Core Rulebook PDF.
Then any “Open to page …” buttons will jump there.

## Notes
This is an MVP scaffold: it’s designed so we can iteratively add data packs (skills, talents, weapons)
without changing UI structure.
