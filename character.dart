import 'dart:convert';

import 'package:collection/collection.dart';

class CharacteristicBlock {
  final int ws;
  final int bs;
  final int s;
  final int t;
  final int agi;
  final int intl;
  final int per;
  final int wp;
  final int fel;

  const CharacteristicBlock({
    required this.ws,
    required this.bs,
    required this.s,
    required this.t,
    required this.agi,
    required this.intl,
    required this.per,
    required this.wp,
    required this.fel,
  });

  factory CharacteristicBlock.blank() => const CharacteristicBlock(
        ws: 0,
        bs: 0,
        s: 0,
        t: 0,
        agi: 0,
        intl: 0,
        per: 0,
        wp: 0,
        fel: 0,
      );

  Map<String, dynamic> toJson() => {
        'ws': ws,
        'bs': bs,
        's': s,
        't': t,
        'agi': agi,
        'intl': intl,
        'per': per,
        'wp': wp,
        'fel': fel,
      };

  factory CharacteristicBlock.fromJson(Map<String, dynamic> json) =>
      CharacteristicBlock(
        ws: (json['ws'] ?? 0) as int,
        bs: (json['bs'] ?? 0) as int,
        s: (json['s'] ?? 0) as int,
        t: (json['t'] ?? 0) as int,
        agi: (json['agi'] ?? 0) as int,
        intl: (json['intl'] ?? 0) as int,
        per: (json['per'] ?? 0) as int,
        wp: (json['wp'] ?? 0) as int,
        fel: (json['fel'] ?? 0) as int,
      );
}

class SkillEntry {
  final String name;
  final int advances; // 0..4 typically (MVP doesn't enforce)
  const SkillEntry({required this.name, this.advances = 0});

  Map<String, dynamic> toJson() => {'name': name, 'advances': advances};
  factory SkillEntry.fromJson(Map<String, dynamic> json) => SkillEntry(
        name: (json['name'] ?? '') as String,
        advances: (json['advances'] ?? 0) as int,
      );
}

class TalentEntry {
  final String name;
  final String notes;
  const TalentEntry({required this.name, this.notes = ''});

  Map<String, dynamic> toJson() => {'name': name, 'notes': notes};
  factory TalentEntry.fromJson(Map<String, dynamic> json) => TalentEntry(
        name: (json['name'] ?? '') as String,
        notes: (json['notes'] ?? '') as String,
      );
}

enum ItemCategory { weapon, armour, gear }

class ItemEntry {
  final String name;
  final ItemCategory category;

  // Optional weapon-ish bits for quick combat (MVP)
  final String? damage; // e.g. "1d10+3 E"
  final int? penetration;
  final String? qualities; // e.g. "Reliable; Accurate"

  const ItemEntry({
    required this.name,
    required this.category,
    this.damage,
    this.penetration,
    this.qualities,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category.name,
        'damage': damage,
        'penetration': penetration,
        'qualities': qualities,
      };

  factory ItemEntry.fromJson(Map<String, dynamic> json) => ItemEntry(
        name: (json['name'] ?? '') as String,
        category: ItemCategory.values
                .firstWhereOrNull((e) => e.name == json['category']) ??
            ItemCategory.gear,
        damage: json['damage'] as String?,
        penetration: json['penetration'] as int?,
        qualities: json['qualities'] as String?,
      );
}

class CharacterSheet {
  final String id;
  final String name;
  final String homeWorld;
  final String background;
  final String role;

  final CharacteristicBlock characteristics;

  final int woundsMax;
  final int woundsCurrent;
  final int fateMax;
  final int fateCurrent;

  final int corruption;
  final int insanity;

  final int influence;
  final int subtlety;

  final List<SkillEntry> skills;
  final List<TalentEntry> talents;
  final List<ItemEntry> equipment;

  final int xpTotal;
  final int xpSpent;

  final String notes;

  const CharacterSheet({
    required this.id,
    required this.name,
    required this.homeWorld,
    required this.background,
    required this.role,
    required this.characteristics,
    required this.woundsMax,
    required this.woundsCurrent,
    required this.fateMax,
    required this.fateCurrent,
    required this.corruption,
    required this.insanity,
    required this.influence,
    required this.subtlety,
    required this.skills,
    required this.talents,
    required this.equipment,
    required this.xpTotal,
    required this.xpSpent,
    required this.notes,
  });

  factory CharacterSheet.blank() => CharacterSheet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'New Acolyte',
        homeWorld: '',
        background: '',
        role: '',
        characteristics: CharacteristicBlock.blank(),
        woundsMax: 0,
        woundsCurrent: 0,
        fateMax: 0,
        fateCurrent: 0,
        corruption: 0,
        insanity: 0,
        influence: 0,
        subtlety: 0,
        skills: const [],
        talents: const [],
        equipment: const [],
        xpTotal: 0,
        xpSpent: 0,
        notes: '',
      );

  CharacterSheet copyWith({
    String? name,
    String? homeWorld,
    String? background,
    String? role,
    CharacteristicBlock? characteristics,
    int? woundsMax,
    int? woundsCurrent,
    int? fateMax,
    int? fateCurrent,
    int? corruption,
    int? insanity,
    int? influence,
    int? subtlety,
    List<SkillEntry>? skills,
    List<TalentEntry>? talents,
    List<ItemEntry>? equipment,
    int? xpTotal,
    int? xpSpent,
    String? notes,
  }) =>
      CharacterSheet(
        id: id,
        name: name ?? this.name,
        homeWorld: homeWorld ?? this.homeWorld,
        background: background ?? this.background,
        role: role ?? this.role,
        characteristics: characteristics ?? this.characteristics,
        woundsMax: woundsMax ?? this.woundsMax,
        woundsCurrent: woundsCurrent ?? this.woundsCurrent,
        fateMax: fateMax ?? this.fateMax,
        fateCurrent: fateCurrent ?? this.fateCurrent,
        corruption: corruption ?? this.corruption,
        insanity: insanity ?? this.insanity,
        influence: influence ?? this.influence,
        subtlety: subtlety ?? this.subtlety,
        skills: skills ?? this.skills,
        talents: talents ?? this.talents,
        equipment: equipment ?? this.equipment,
        xpTotal: xpTotal ?? this.xpTotal,
        xpSpent: xpSpent ?? this.xpSpent,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'homeWorld': homeWorld,
        'background': background,
        'role': role,
        'characteristics': characteristics.toJson(),
        'woundsMax': woundsMax,
        'woundsCurrent': woundsCurrent,
        'fateMax': fateMax,
        'fateCurrent': fateCurrent,
        'corruption': corruption,
        'insanity': insanity,
        'influence': influence,
        'subtlety': subtlety,
        'skills': skills.map((s) => s.toJson()).toList(),
        'talents': talents.map((t) => t.toJson()).toList(),
        'equipment': equipment.map((e) => e.toJson()).toList(),
        'xpTotal': xpTotal,
        'xpSpent': xpSpent,
        'notes': notes,
      };

  static CharacterSheet fromJsonString(String s) =>
      CharacterSheet.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());

  factory CharacterSheet.fromJson(Map<String, dynamic> json) => CharacterSheet(
        id: (json['id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        homeWorld: (json['homeWorld'] ?? '') as String,
        background: (json['background'] ?? '') as String,
        role: (json['role'] ?? '') as String,
        characteristics:
            CharacteristicBlock.fromJson((json['characteristics'] ?? {}) as Map<String, dynamic>),
        woundsMax: (json['woundsMax'] ?? 0) as int,
        woundsCurrent: (json['woundsCurrent'] ?? 0) as int,
        fateMax: (json['fateMax'] ?? 0) as int,
        fateCurrent: (json['fateCurrent'] ?? 0) as int,
        corruption: (json['corruption'] ?? 0) as int,
        insanity: (json['insanity'] ?? 0) as int,
        influence: (json['influence'] ?? 0) as int,
        subtlety: (json['subtlety'] ?? 0) as int,
        skills: ((json['skills'] ?? []) as List)
            .map((e) => SkillEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        talents: ((json['talents'] ?? []) as List)
            .map((e) => TalentEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        equipment: ((json['equipment'] ?? []) as List)
            .map((e) => ItemEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        xpTotal: (json['xpTotal'] ?? 0) as int,
        xpSpent: (json['xpSpent'] ?? 0) as int,
        notes: (json['notes'] ?? '') as String,
      );
}
