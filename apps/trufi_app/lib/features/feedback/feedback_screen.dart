import 'package:flutter/material.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'l10n/feedback_localizations.dart';

/// Feedback screen module
class FeedbackTrufiScreen extends TrufiScreen {
  @override
  String get id => 'feedback';

  @override
  String get path => '/feedback';

  @override
  Widget Function(BuildContext context) get builder => (_) => const _FeedbackScreen();

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
        FeedbackLocalizations.delegate,
      ];

  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(
        icon: Icons.feedback,
        order: 200,
      );

  @override
  String getLocalizedTitle(BuildContext context) {
    return FeedbackLocalizations.of(context).feedbackTitle;
  }
}

/// Feedback screen widget
class _FeedbackScreen extends StatefulWidget {
  const _FeedbackScreen();

  @override
  State<_FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<_FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _feedbackType = 'general';
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSubmitting = false);
      final l10n = FeedbackLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.feedbackSuccess),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _messageController.clear();
      setState(() {
        _rating = 0;
        _feedbackType = 'general';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = FeedbackLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.feedback,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.feedbackTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.feedbackSubtitle,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Feedback type selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.feedbackType,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _FeedbackTypeChip(
                          label: l10n.feedbackTypeGeneral,
                          icon: Icons.chat_bubble,
                          isSelected: _feedbackType == 'general',
                          onSelected: () =>
                              setState(() => _feedbackType = 'general'),
                        ),
                        _FeedbackTypeChip(
                          label: l10n.feedbackTypeBug,
                          icon: Icons.bug_report,
                          isSelected: _feedbackType == 'bug',
                          onSelected: () =>
                              setState(() => _feedbackType = 'bug'),
                        ),
                        _FeedbackTypeChip(
                          label: l10n.feedbackTypeFeature,
                          icon: Icons.lightbulb,
                          isSelected: _feedbackType == 'feature',
                          onSelected: () =>
                              setState(() => _feedbackType = 'feature'),
                        ),
                        _FeedbackTypeChip(
                          label: l10n.feedbackTypeRoute,
                          icon: Icons.route,
                          isSelected: _feedbackType == 'route',
                          onSelected: () =>
                              setState(() => _feedbackType = 'route'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Rating section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.feedbackRating,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () => setState(() => _rating = index + 1),
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 36,
                          ),
                        );
                      }),
                    ),
                    if (_rating > 0)
                      Center(
                        child: Text(
                          _getRatingText(l10n, _rating),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Message input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.feedbackMessage,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: l10n.feedbackMessageHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your feedback';
                        }
                        if (value.trim().length < 10) {
                          return 'Please provide more details (min 10 characters)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(l10n.feedbackSubmit),
            ),

            const SizedBox(height: 16),

            // Info text
            Text(
              'This is a demo feedback form. In a real app, this would send your feedback to the development team.',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(FeedbackLocalizations l10n, int rating) {
    switch (rating) {
      case 1:
        return l10n.feedbackRatingPoor;
      case 2:
        return l10n.feedbackRatingFair;
      case 3:
        return l10n.feedbackRatingGood;
      case 4:
        return l10n.feedbackRatingVeryGood;
      case 5:
        return l10n.feedbackRatingExcellent;
      default:
        return '';
    }
  }
}

class _FeedbackTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FeedbackTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onSelected(),
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : Colors.green,
      ),
      label: Text(label),
      selectedColor: Colors.green,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
      ),
    );
  }
}
