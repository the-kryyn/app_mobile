import 'package:flutter/material.dart';
import 'package:salinite_mobile/widgets/salinity_history_widget.dart';
import '../services/base_url_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = BaseUrlService.getBaseUrl();
  }

  void _saveUrl() async {
    await BaseUrlService.setBaseUrl(_controller.text.trim());
    if (mounted) {
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Base URL mise à jour'),
          backgroundColor: colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Changer l\'URL de base de l\'API'),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
              ),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Base URL',
                labelStyle: TextStyle(color: colorScheme.primary),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveUrl,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 30),
            // Make the widget take nearly all space but leave a bottom margin
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SalinityHistoryWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
