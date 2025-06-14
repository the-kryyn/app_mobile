import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../services/api_service.dart';
import '../widgets/salinity_display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? _salinity;
  String? _error;
  bool _isLoading = true;
  bool _hasFilledOnce = false;

  final RefreshController _refreshController = RefreshController();

  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _checkWifiAndFetch();
  }

  Future<void> _saveSalinityToLocalStorage() async {
    if (_salinity == null) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();

    final entry = jsonEncode({'value': _salinity, 'timestamp': now});

    final history = prefs.getStringList('salinity_history') ?? [];
    history.add(entry);

    await prefs.setStringList('salinity_history', history);

    // Optional: Snackbar confirmation
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Valeur enregistrée.')));
  }

  Future<void> _checkWifiAndFetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final value = await ApiService.fetchSalinity();
      setState(() {
        _salinity = value;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _salinity = null;
      });
    }

    setState(() {
      _isLoading = false;
    });

    _refreshController.refreshCompleted();
  }

  Widget _buildErrorCard() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: _checkWifiAndFetch,
      child: Card(
        key: const ValueKey('error_card'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        margin: const EdgeInsets.all(16),
        color: scheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: scheme.onErrorContainer,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? "Erreur inconnue",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Appuyez pour réessayer',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onErrorContainer.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Loading animation widget
  Widget _buildLoadingDots(Color color) {
    return SpinKitThreeBounce(
      key: const ValueKey('loading'),
      color: color,
      size: 30,
    );
  }

  Future<void> _triggerAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    setState(() => _isActionInProgress = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salinité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            color: theme.appBarTheme.foregroundColor,
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _checkWifiAndFetch,
        header: MaterialClassicHeader(color: scheme.primary),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: _isLoading
                ? _buildLoadingDots(scheme.primary)
                : (_error != null
                      ? _buildErrorCard()
                      : SalinityDisplay(
                          key: const ValueKey('salinity_display'),
                          value: _salinity!,
                          onRefresh: _checkWifiAndFetch,
                        )),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 180,
            child: FloatingActionButton.extended(
              heroTag: 'fill_button',
              onPressed: (_isActionInProgress || _hasFilledOnce)
                  ? null
                  : () async {
                      await _triggerAction(
                        () => ApiService.fillTank(),
                        'Remplissage effectué avec succès.',
                      );
                      if (mounted) {
                        setState(() => _hasFilledOnce = true);
                      }
                    },
              label: const Text('Remplir'),
              icon: const Icon(Icons.water_drop),
              backgroundColor: (_isActionInProgress || _hasFilledOnce)
                  ? Colors.grey
                  : scheme.primary,
              foregroundColor: (_isActionInProgress || _hasFilledOnce)
                  ? Colors.black45
                  : scheme.onPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 180,
            child: FloatingActionButton.extended(
              heroTag: 'drain_button',
              onPressed: _isActionInProgress
                  ? null
                  : () => _triggerAction(
                      () => ApiService.drainTank(),
                      'Vidange effectuée avec succès.',
                    ),
              label: const Text('Vidanger'),
              icon: const Icon(Icons.opacity),
              backgroundColor: _isActionInProgress
                  ? Colors.grey
                  : scheme.secondary,
              foregroundColor: _isActionInProgress
                  ? Colors.black45
                  : scheme.onSecondary,
            ),
          ),
          if (_salinity != null && !_isLoading && _error == null) ...[
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'save_button',
              onPressed: _saveSalinityToLocalStorage,
              tooltip: 'Enregistrer',
              child: const Icon(Icons.save),
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
            ),
          ],
        ],
      ),
    );
  }
}
