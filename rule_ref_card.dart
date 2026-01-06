import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../rules/rule_refs.dart';
import '../state/app_state.dart';

class RuleRefCard extends ConsumerWidget {
  final RuleRef refData;
  const RuleRefCard({super.key, required this.refData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfPath = ref.watch(pdfPathProvider);
    return Card(
      child: ListTile(
        title: Text(refData.title),
        subtitle: Text('Open rulebook to page ${refData.page}'
            '${refData.subtitle == null ? '' : ' • ${refData.subtitle}'}'),
        trailing: IconButton(
          tooltip: pdfPath == null ? 'Attach PDF in Settings first' : 'Open PDF',
          icon: const Icon(Icons.picture_as_pdf),
          onPressed: pdfPath == null
              ? null
              : () {
                  context.push('/pdf?page=${refData.page}&title=${Uri.encodeComponent(refData.title)}');
                },
        ),
      ),
    );
  }
}
