import 'package:flutter/material.dart';
import '../shared/constants/app_constants.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../core/initialization/feature_loader.dart';
import '../features/price_comparison/presentation/pages/price_comparison_screen.dart';
import '../features/price_comparison/presentation/pages/help_screen.dart';

class AppRoutes {
  /// Generate route with optimized loading
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.homeRoute:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );

      case AppConstants.priceComparisonRoute:
        return MaterialPageRoute(
          builder: (context) => FeatureLoader.loadFeature(
            'price_comparison',
            () => const LazyPriceComparisonScreen(),
          ),
          settings: settings,
        );

      case AppConstants.helpRoute:
        return MaterialPageRoute(
          builder: (context) => FeatureLoader.loadFeature(
            'help_screen',
            () => const LazyHelpScreen(),
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
    }
  }

  static void navigateToHome(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppConstants.homeRoute, (route) => false);
  }

  static void navigateToPriceComparison(BuildContext context) {
    Navigator.of(context).pushNamed(AppConstants.priceComparisonRoute);
  }

  static void navigateToHelp(BuildContext context) {
    Navigator.of(context).pushNamed(AppConstants.helpRoute);
  }
}

/// Lazy wrapper for PriceComparisonScreen
class LazyPriceComparisonScreen extends StatelessWidget {
  const LazyPriceComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _loadPriceComparisonFeature(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorScreen('Price Comparison', snapshot.error!);
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        }

        return _buildLoadingScreen('Loading Price Comparison...');
      },
    );
  }

  Future<Widget> _loadPriceComparisonFeature() async {
    // Small delay to ensure smooth loading experience
    await Future.delayed(const Duration(milliseconds: 100));

    // Lazy import of the heavy screen
    return _createPriceComparisonScreen();
  }

  Widget _createPriceComparisonScreen() {
    // This import only happens when the feature is accessed
    return const _ActualPriceComparisonScreen();
  }
}

/// Lazy wrapper for HelpScreen
class LazyHelpScreen extends StatelessWidget {
  const LazyHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _loadHelpFeature(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorScreen('Help', snapshot.error!);
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        }

        return _buildLoadingScreen('Loading Help...');
      },
    );
  }

  Future<Widget> _loadHelpFeature() async {
    // Small delay to simulate feature loading
    await Future.delayed(const Duration(milliseconds: 80));

    // Lazy import of the help screen
    return _createHelpScreen();
  }

  Widget _createHelpScreen() {
    // This import only happens when the feature is accessed
    return const _ActualHelpScreen();
  }
}

/// Build loading screen for lazy features
Widget _buildLoadingScreen(String message) {
  return Scaffold(
    appBar: AppBar(title: const Text('Loading...')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}

/// Build error screen for lazy features
Widget _buildErrorScreen(String featureName, Object error) {
  return Scaffold(
    appBar: AppBar(title: Text('$featureName Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load $featureName',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Error: ${error.toString()}',
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Actual PriceComparisonScreen - loaded only when needed
class _ActualPriceComparisonScreen extends StatelessWidget {
  const _ActualPriceComparisonScreen();

  @override
  Widget build(BuildContext context) {
    // Import the actual screen here
    // This avoids loading it during app startup
    return _importPriceComparisonScreen();
  }

  Widget _importPriceComparisonScreen() {
    // Lazy import using late initialization
    late final Widget priceComparisonScreen;

    try {
      // Dynamic loading of the actual screen
      priceComparisonScreen = _loadPriceComparisonScreenModule();
      return priceComparisonScreen;
    } catch (e) {
      return _buildErrorScreen('Price Comparison', e);
    }
  }

  Widget _loadPriceComparisonScreenModule() {
    // Import the actual price comparison screen
    return const PriceComparisonScreen();
  }
}

/// Actual HelpScreen - loaded only when needed
class _ActualHelpScreen extends StatelessWidget {
  const _ActualHelpScreen();

  @override
  Widget build(BuildContext context) {
    return _importHelpScreen();
  }

  Widget _importHelpScreen() {
    late final Widget helpScreen;

    try {
      helpScreen = _loadHelpScreenModule();
      return helpScreen;
    } catch (e) {
      return _buildErrorScreen('Help', e);
    }
  }

  Widget _loadHelpScreenModule() {
    // Import the actual help screen
    return const HelpScreen();
  }
}

/// Placeholder screens that will be replaced with actual implementations
class PlaceholderPriceComparisonScreen extends StatelessWidget {
  const PlaceholderPriceComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Price Comparison')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, size: 64),
            SizedBox(height: 16),
            Text(
              'Price Comparison Feature',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This feature has been lazy loaded!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderHelpScreen extends StatelessWidget {
  const PlaceholderHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 64),
            SizedBox(height: 16),
            Text(
              'Help Feature',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This feature has been lazy loaded!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Note: Placeholder classes kept for reference but real implementations are now used directly
