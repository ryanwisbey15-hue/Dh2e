import 'package:flutter/material.dart';

import '../../../rules/dice.dart';

class DiceTab extends StatefulWidget {
  const DiceTab({super.key});

  @override
  State<DiceTab> createState() => _DiceTabState();
}

class _DiceTabState extends State<DiceTab> {
  int _target = 30;
  int _modifier = 0;
  D100Result? _last;
  int? _lastGeneric;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('d100 Test', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Target'),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: _target.toString()),
                        onChanged: (v) => _target = int.tryParse(v) ?? _target,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Modifier'),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: _modifier.toString()),
                        onChanged: (v) => _modifier = int.tryParse(v) ?? _modifier,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => setState(() => _last = Dice.test(target: _target, modifier: _modifier)),
                  icon: const Icon(Icons.casino),
                  label: const Text('Roll'),
                ),
                if (_last != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${_last!.success ? 'SUCCESS' : 'FAIL'} • Roll ${_last!.roll} vs ${_last!.target + _last!.modifier} • '
                    '${_last!.degrees >= 0 ? '${_last!.degrees} DoS' : '${_last!.degrees.abs()} DoF'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick dice', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _dieButton(context, 5),
                    _dieButton(context, 10),
                    _dieButton(context, 100),
                  ],
                ),
                if (_lastGeneric != null) ...[
                  const SizedBox(height: 12),
                  Text('Result: $_lastGeneric', style: Theme.of(context).textTheme.titleMedium),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dieButton(BuildContext context, int sides) {
    return OutlinedButton(
      onPressed: () => setState(() => _lastGeneric = Dice.d(sides)),
      child: Text('d$sides'),
    );
  }
}
