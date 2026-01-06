/// Page references are *PDF page numbers* for the DH2e core rulebook PDF you attached.
/// This project does not ship the PDF; the user supplies it.
///
/// Key character-creation stages:
/// - Creating an Acolyte: p. 28
/// - Stage 1 (Home World): p. 29
/// - Stage 2 (Background): p. 44
/// - Stage 3 (Role): p. 60
/// - Stage 4 (Spend XP / Equip): p. 78
/// - Stage 5 (Give the Character Life): p. 82
///
/// Key play sections:
/// - Core rules / tests: p. 21–27
/// - Combat: p. 215+
/// - Skills chapter: p. 95+
/// - Talents & Traits: p. 120+
/// - Armoury: p. 144+
///
/// Source: DH2e Core Rulebook PDF (user-supplied).
class RuleRef {
  final String title;
  final int page;
  final String? subtitle;
  const RuleRef({required this.title, required this.page, this.subtitle});
}

class RuleRefs {
  static const creatingAnAcolyte =
      RuleRef(title: 'Creating an Acolyte', page: 28);
  static const stage1HomeWorld =
      RuleRef(title: 'Stage 1: Choose Home World', page: 29);
  static const stage2Background =
      RuleRef(title: 'Stage 2: Choose Background', page: 44);
  static const stage3Role = RuleRef(title: 'Stage 3: Choose Role', page: 60);
  static const stage4XpEquip =
      RuleRef(title: 'Stage 4: Spend XP & Equip', page: 78);
  static const stage5Life =
      RuleRef(title: 'Stage 5: Give the Character Life', page: 82);

  static const coreRules = RuleRef(title: 'Core Rules / Tests', page: 21);
  static const combat = RuleRef(title: 'Combat', page: 215);
  static const skills = RuleRef(title: 'Skills', page: 95);
  static const talentsTraits = RuleRef(title: 'Talents & Traits', page: 120);
  static const armoury = RuleRef(title: 'Armoury', page: 144);
}
