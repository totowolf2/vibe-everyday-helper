import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../domain/models/help_content.dart';

class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({super.key});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: theme.scaffoldBackgroundColor,
      pages: _buildTutorialPages(context),
      onDone: () => _onTutorialComplete(context),
      onSkip: () => _onTutorialSkipped(context),
      showSkipButton: true,
      skip: Text(
        'Skip',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
        ),
      ),
      next: Icon(Icons.arrow_forward, color: theme.primaryColor),
      done: Text(
        'Done',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: theme.dividerColor,
        activeSize: const Size(22.0, 10.0),
        activeColor: theme.primaryColor,
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  List<PageViewModel> _buildTutorialPages(BuildContext context) {
    final theme = Theme.of(context);

    return [
      // Welcome page
      PageViewModel(
        title: "Welcome to Price Comparison!",
        body: MilkComparisonExample.getTutorialStep(1),
        image: _buildTutorialImage(
          context,
          Icons.shopping_cart_outlined,
          theme.primaryColor,
        ),
        decoration: _getPageDecoration(theme),
      ),

      // Scenario introduction
      PageViewModel(
        title: "Real Example: Milk Shopping",
        body: MilkComparisonExample.getTutorialStep(2),
        image: _buildTutorialImage(
          context,
          Icons.local_drink_outlined,
          Colors.blue[300]!,
        ),
        decoration: _getPageDecoration(theme),
      ),

      // Step 1: Calculate totals
      PageViewModel(
        title: "Step 1: Calculate Total Quantities",
        body: MilkComparisonExample.getTutorialStep(3),
        image: _buildCalculationExample(context),
        decoration: _getPageDecoration(theme),
      ),

      // Step 2: Add first product
      PageViewModel(
        title: "Step 2: Add First Product",
        body: MilkComparisonExample.getTutorialStep(4),
        image: _buildFormExample(context, "Milk A", "57", "1200", "ml"),
        decoration: _getPageDecoration(theme),
      ),

      // Step 3: Add second product
      PageViewModel(
        title: "Step 3: Add Second Product",
        body: MilkComparisonExample.getTutorialStep(5),
        image: _buildFormExample(context, "Milk B", "48", "900", "ml"),
        decoration: _getPageDecoration(theme),
      ),

      // Step 4: View results
      PageViewModel(
        title: "Step 4: Compare Results",
        body: MilkComparisonExample.getTutorialStep(6),
        image: _buildResultsExample(context),
        decoration: _getPageDecoration(theme),
      ),

      // Completion
      PageViewModel(
        title: "You're Ready!",
        body: MilkComparisonExample.getTutorialStep(7),
        image: _buildTutorialImage(
          context,
          Icons.check_circle_outline,
          Colors.green,
        ),
        decoration: _getPageDecoration(theme),
        footer: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () => _loadExampleAndStart(context),
            child: const Text('Load Example & Start'),
          ),
        ),
      ),
    ];
  }

  Widget _buildTutorialImage(BuildContext context, IconData icon, Color color) {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 100, color: color),
    );
  }

  Widget _buildCalculationExample(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCalculationRow("Milk A:", "6 × 200ml", "= 1,200ml"),
          const SizedBox(height: 16),
          _buildCalculationRow("Milk B:", "3 × 300ml", "= 900ml"),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(String label, String calculation, String result) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(calculation),
        Text(result, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFormExample(
    BuildContext context,
    String name,
    String price,
    String quantity,
    String unit,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormField("Product Name", name),
          const SizedBox(height: 12),
          _buildFormField("Price (baht)", price),
          const SizedBox(height: 12),
          _buildFormField("Quantity", quantity),
          const SizedBox(height: 12),
          _buildFormField("Unit", unit),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildResultsExample(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildResultRow("Milk A", "0.048 baht/ml", true),
          const SizedBox(height: 8),
          _buildResultRow("Milk B", "0.053 baht/ml", false),
        ],
      ),
    );
  }

  Widget _buildResultRow(String name, String pricePerUnit, bool isBest) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBest
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBest ? Colors.green : Colors.grey,
          width: isBest ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isBest) const Icon(Icons.star, color: Colors.green, size: 20),
              if (isBest) const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          Text(
            pricePerUnit,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isBest ? Colors.green[700] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  PageDecoration _getPageDecoration(ThemeData theme) {
    return PageDecoration(
      titleTextStyle: theme.textTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
      ),
      bodyTextStyle: theme.textTheme.bodyLarge!.copyWith(height: 1.4),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: theme.scaffoldBackgroundColor,
      imagePadding: const EdgeInsets.only(top: 40),
    );
  }

  void _onTutorialComplete(BuildContext context) {
    _setTutorialCompleted();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tutorial completed! You can now start comparing prices.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _onTutorialSkipped(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _loadExampleAndStart(BuildContext context) {
    _setTutorialCompleted();
    Navigator.of(context).pop();
    Navigator.of(context).pop(); // Go back to price comparison screen

    // The example loading will be handled in the help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tutorial completed! Use the help button to load the milk example.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _setTutorialCompleted() {
    // TODO: Store tutorial completion in SharedPreferences
    // This will be implemented when we add tutorial state management
  }
}
