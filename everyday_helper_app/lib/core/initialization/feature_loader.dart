import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// Handles lazy loading of feature modules to improve startup performance
class FeatureLoader {
  static final Map<String, Widget Function()> _featureCache = {};
  static final Map<String, bool> _loadingStates = {};

  /// Lazy load a feature by name
  static Widget loadFeature(String featureName, Widget Function() builder) {
    return FutureBuilder<Widget>(
      future: _loadFeatureAsync(featureName, builder),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error!, featureName);
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        }

        return _buildLoadingWidget();
      },
    );
  }

  /// Load feature asynchronously with caching
  static Future<Widget> _loadFeatureAsync(
    String featureName,
    Widget Function() builder,
  ) async {
    // Return cached version if available
    if (_featureCache.containsKey(featureName)) {
      return _featureCache[featureName]!();
    }

    // Check if already loading to prevent duplicate loads
    if (_loadingStates[featureName] == true) {
      // Wait for existing load to complete
      while (_loadingStates[featureName] == true) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _featureCache[featureName]!();
    }

    developer.Timeline.startSync('feature_load_$featureName');
    _loadingStates[featureName] = true;

    try {
      // Simulate feature loading delay for heavy features
      if (_isHeavyFeature(featureName)) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Build and cache the feature
      final widget = builder();
      _featureCache[featureName] = builder;

      developer.log('Feature loaded: $featureName');
      return widget;
    } catch (e) {
      developer.log('Feature load error for $featureName: $e', error: e);
      rethrow;
    } finally {
      _loadingStates[featureName] = false;
      developer.Timeline.finishSync();
    }
  }

  /// Check if a feature is considered heavy and needs loading optimization
  static bool _isHeavyFeature(String featureName) {
    const heavyFeatures = [
      'price_comparison',
      'tutorial_overlay',
      'help_system',
    ];
    return heavyFeatures.contains(featureName);
  }

  /// Build loading widget
  static Widget _buildLoadingWidget() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading feature...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  /// Build error widget
  static Widget _buildErrorWidget(Object error, String featureName) {
    return Scaffold(
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
            ElevatedButton(
              onPressed: () {
                // Clear cache and retry
                _featureCache.remove(featureName);
                _loadingStates.remove(featureName);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Pre-load features in background
  static Future<void> preloadFeatures(List<String> featureNames) async {
    developer.Timeline.startSync('features_preload');

    try {
      developer.log('Pre-loading ${featureNames.length} features');

      // Pre-load features concurrently but with lower priority
      for (final featureName in featureNames) {
        // Only preload if not already cached
        if (!_featureCache.containsKey(featureName)) {
          // Schedule for background loading
          Future.microtask(() async {
            try {
              // This would need specific builder functions for each feature
              developer.log('Background preload for: $featureName');
            } catch (e) {
              developer.log('Preload failed for $featureName: $e');
            }
          });
        }
      }
    } finally {
      developer.Timeline.finishSync();
    }
  }

  /// Clear feature cache to free memory
  static void clearCache() {
    _featureCache.clear();
    _loadingStates.clear();
    developer.log('Feature cache cleared');
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cached_features': _featureCache.keys.toList(),
      'loading_features': _loadingStates.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList(),
      'cache_size': _featureCache.length,
    };
  }
}
