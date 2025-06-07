import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:salinite_mobile/widgets/salinity_graph_view.dart';
import 'package:salinite_mobile/widgets/salinity_list_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalinityHistoryWidget extends StatefulWidget {
  const SalinityHistoryWidget({super.key});

  @override
  State<SalinityHistoryWidget> createState() => _SalinityHistoryWidgetState();
}

class _SalinityHistoryWidgetState extends State<SalinityHistoryWidget> {
  List<Map<String, dynamic>> _history = [];
  bool _showGraph = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('salinity_history') ?? [];

    final parsed = history.map((entry) {
      final decoded = json.decode(entry);
      return {
        'value': decoded['value'] as double,
        'timestamp':
            DateTime.tryParse(decoded['timestamp']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      };
    }).toList();

    parsed.sort(
      (a, b) =>
          (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
    );

    setState(
      () => _history = parsed.reversed.toList(),
    ); // Oldest to latest for graph
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.primaryContainer,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Historique des salinités',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showGraph ? Icons.list : Icons.show_chart,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  tooltip: _showGraph
                      ? 'Afficher la liste'
                      : 'Afficher le graphique',
                  onPressed: () => setState(() => _showGraph = !_showGraph),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_history.isEmpty)
              Text(
                'Aucune donnée enregistrée.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              )
            else
              Expanded(
                child: _showGraph
                    ? SalinityGraphView(history: _history)
                    : SalinityListView(history: _history),
              ),
          ],
        ),
      ),
    );
  }
}
