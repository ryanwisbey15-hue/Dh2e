import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogItem {
  final String name;
  final String? characteristic;
  final String? type;
  final String? category;

  const CatalogItem({
    required this.name,
    this.characteristic,
    this.type,
    this.category,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) => CatalogItem(
        name: (json['name'] ?? '') as String,
        characteristic: json['characteristic'] as String?,
        type: json['type'] as String?,
        category: json['category'] as String?,
      );
}

final skillsCatalogProvider = FutureProvider<List<CatalogItem>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/skills.json');
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return list.map(CatalogItem.fromJson).where((e) => e.name.isNotEmpty).toList();
});

final equipmentCatalogProvider = FutureProvider<List<CatalogItem>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/equipment.json');
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return list.map(CatalogItem.fromJson).where((e) => e.name.isNotEmpty).toList();
});
