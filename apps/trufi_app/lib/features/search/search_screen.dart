import 'package:flutter/material.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../../core/l10n/core_localizations.dart';
import '../home/l10n/home_localizations.dart';
import 'l10n/search_localizations.dart';

/// Search screen module
class SearchTrufiScreen extends TrufiScreen {
  @override
  String get id => 'search';

  @override
  String get path => '/search';

  @override
  Widget Function(BuildContext context) get builder => (_) => const _SearchScreen();

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
        SearchLocalizations.delegate,
      ];

  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(
        icon: Icons.search,
        order: 100,
      );

  @override
  String getLocalizedTitle(BuildContext context) {
    return SearchLocalizations.of(context).searchTitle;
  }
}

/// Search screen widget
class _SearchScreen extends StatefulWidget {
  const _SearchScreen();

  @override
  State<_SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<_SearchScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _originFocus = FocusNode();
  final _destinationFocus = FocusNode();

  List<_SearchResult> _searchResults = [];
  bool _isSearching = false;
  String? _activeField;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _originFocus.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  void _onSearch(String query, String field) {
    setState(() {
      _activeField = field;
      _isSearching = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && query.isNotEmpty) {
        setState(() {
          _searchResults = _getMockResults(query);
          _isSearching = false;
        });
      } else if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  List<_SearchResult> _getMockResults(String query) {
    final mockLocations = [
      _SearchResult(name: 'Central Station', address: '123 Main Street', icon: Icons.train),
      _SearchResult(name: 'City Center', address: '456 Downtown Ave', icon: Icons.location_city),
      _SearchResult(name: 'Airport', address: '789 Airport Road', icon: Icons.flight),
      _SearchResult(name: 'University', address: '321 Campus Drive', icon: Icons.school),
      _SearchResult(name: 'Shopping Mall', address: '654 Commerce Blvd', icon: Icons.shopping_bag),
    ];

    return mockLocations
        .where((loc) => loc.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _selectResult(_SearchResult result) {
    if (_activeField == 'origin') {
      _originController.text = result.name;
      _destinationFocus.requestFocus();
    } else {
      _destinationController.text = result.name;
    }
    setState(() {
      _searchResults = [];
      _activeField = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final coreL10n = CoreLocalizations.of(context);
    final l10n = SearchLocalizations.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _SearchInputField(
                controller: _originController,
                focusNode: _originFocus,
                icon: Icons.my_location,
                iconColor: Colors.green,
                hint: l10n.searchOrigin,
                onChanged: (value) => _onSearch(value, 'origin'),
                onFocusChange: (focused) {
                  if (focused) setState(() => _activeField = 'origin');
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  IconButton(
                    onPressed: () {
                      final temp = _originController.text;
                      _originController.text = _destinationController.text;
                      _destinationController.text = temp;
                    },
                    icon: const Icon(Icons.swap_vert),
                    tooltip: l10n.searchSwap,
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 8),
              _SearchInputField(
                controller: _destinationController,
                focusNode: _destinationFocus,
                icon: Icons.location_on,
                iconColor: Colors.red,
                hint: l10n.searchDestination,
                onChanged: (value) => _onSearch(value, 'destination'),
                onFocusChange: (focused) {
                  if (focused) setState(() => _activeField = 'destination');
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.gps_fixed),
                      label: Text(l10n.searchMyLocation),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.map),
                      label: Text(l10n.searchChooseOnMap),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? _buildEmptyState(context)
                  : _buildResultsList(),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _originController.text.isNotEmpty &&
                      _destinationController.text.isNotEmpty
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Searching route from ${_originController.text} to ${_destinationController.text}',
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(coreL10n.navSearch),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final homeL10n = HomeLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            homeL10n.homeSearchPlaceholder,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green[100],
            child: Icon(result.icon, color: Colors.green),
          ),
          title: Text(result.name),
          subtitle: Text(result.address),
          onTap: () => _selectResult(result),
        );
      },
    );
  }
}

class _SearchInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData icon;
  final Color iconColor;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<bool> onFocusChange;

  const _SearchInputField({
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.iconColor,
    required this.hint,
    required this.onChanged,
    required this.onFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: iconColor),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class _SearchResult {
  final String name;
  final String address;
  final IconData icon;

  const _SearchResult({required this.name, required this.address, required this.icon});
}
