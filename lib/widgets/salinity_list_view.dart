import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalinityListView extends StatefulWidget {
  final List<Map<String, dynamic>> history;

  const SalinityListView({super.key, required this.history});

  @override
  State<SalinityListView> createState() => _SalinityListViewState();
}

class _SalinityListViewState extends State<SalinityListView> {
  late List<Map<String, dynamic>> _localHistory;

  @override
  void initState() {
    super.initState();
    // Create a copy of the list to allow stateful changes
    _localHistory = List<Map<String, dynamic>>.from(widget.history);
  }

  Future<void> _deleteItem(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // Adjust index because we're reversing the list in display
    final reversedIndex = _localHistory.length - 1 - index;

    setState(() {
      _localHistory.removeAt(reversedIndex);
    });

    // Convert back to JSON string list for storage
    final newHistoryJson = _localHistory.map((entry) {
      return jsonEncode({
        'value': entry['value'],
        'timestamp': (entry['timestamp'] as DateTime).toIso8601String(),
      });
    }).toList();

    await prefs.setStringList('salinity_history', newHistoryJson);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Valeur supprimée.')));
  }

  void _confirmDelete(int index) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ?', style: titleStyle),
        content: const Text('Voulez-vous vraiment supprimer cette valeur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              overlayColor: Colors.red.withOpacity(0.1),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteItem(index);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      itemCount: _localHistory.length,
      itemBuilder: (context, index) {
        // Reverse to show latest first
        final item = _localHistory[_localHistory.length - 1 - index];
        final value = item['value'] as double;
        final timestamp = item['timestamp'] as DateTime;

        return ListTile(
          title: Text(
            '${value.toStringAsFixed(4)} g/L',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp),
            style: TextStyle(
              color: colorScheme.onPrimaryContainer.withOpacity(0.85),
            ),
          ),
          onLongPress: () => _confirmDelete(index),
        );
      },
    );
  }
}
