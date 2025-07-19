import 'dart:developer' as developer;

/// Tracks and reports app startup performance metrics
class StartupMetrics {
  static final Stopwatch _appStartup = Stopwatch();
  static final Stopwatch _firstFrame = Stopwatch();
  static final Map<String, int> _milestones = {};
  static bool _isTracking = false;

  /// Start tracking app startup time
  static void startTracking() {
    if (_isTracking) return;

    _isTracking = true;
    _appStartup.start();
    _firstFrame.start();

    developer.Timeline.startSync('app_startup_tracking');
    developer.log('Startup metrics tracking started');

    _recordMilestone('startup_begin');
  }

  /// Record a milestone during startup
  static void recordMilestone(String name) {
    if (!_isTracking) return;

    _recordMilestone(name);
  }

  static void _recordMilestone(String name) {
    final elapsed = _appStartup.elapsedMilliseconds;
    _milestones[name] = elapsed;

    developer.Timeline.instantSync(name, arguments: {'elapsed_ms': elapsed});

    developer.log('Milestone [$name]: ${elapsed}ms');
  }

  /// Mark that first frame has been rendered
  static void markFirstFrame() {
    if (!_isTracking) return;

    _firstFrame.stop();
    _recordMilestone('first_frame_rendered');

    developer.log(
      'First frame rendered in ${_firstFrame.elapsedMilliseconds}ms',
    );
  }

  /// Mark that app is ready for user interaction
  static void markAppReady() {
    if (!_isTracking) return;

    _recordMilestone('app_ready');
    _finishTracking();
  }

  /// Finish tracking and generate report
  static void _finishTracking() {
    _appStartup.stop();
    _isTracking = false;

    developer.Timeline.finishSync();

    final report = generateReport();
    developer.log('Startup completed: ${report['total_startup_time']}ms');

    _logDetailedReport(report);
  }

  /// Generate startup performance report
  static Map<String, dynamic> generateReport() {
    return {
      'total_startup_time': _appStartup.elapsedMilliseconds,
      'first_frame_time': _firstFrame.elapsedMilliseconds,
      'milestones': Map<String, int>.from(_milestones),
      'performance_summary': _generatePerformanceSummary(),
    };
  }

  static Map<String, dynamic> _generatePerformanceSummary() {
    final totalTime = _appStartup.elapsedMilliseconds;
    final firstFrameTime = _firstFrame.elapsedMilliseconds;

    return {
      'startup_category': _categorizeStartupPerformance(totalTime),
      'first_frame_category': _categorizeFirstFramePerformance(firstFrameTime),
      'recommendations': _generateRecommendations(totalTime, firstFrameTime),
    };
  }

  static String _categorizeStartupPerformance(int milliseconds) {
    if (milliseconds < 1000) return 'excellent';
    if (milliseconds < 2000) return 'good';
    if (milliseconds < 3000) return 'average';
    return 'needs_improvement';
  }

  static String _categorizeFirstFramePerformance(int milliseconds) {
    if (milliseconds < 100) return 'excellent';
    if (milliseconds < 300) return 'good';
    if (milliseconds < 500) return 'average';
    return 'needs_improvement';
  }

  static List<String> _generateRecommendations(
    int totalTime,
    int firstFrameTime,
  ) {
    final recommendations = <String>[];

    if (totalTime > 3000) {
      recommendations.add(
        'Consider reducing synchronous operations during startup',
      );
      recommendations.add('Implement more aggressive lazy loading');
    }

    if (firstFrameTime > 500) {
      recommendations.add('Optimize widget build methods');
      recommendations.add('Consider reducing initial widget tree complexity');
    }

    if (_milestones.isEmpty) {
      recommendations.add('Add more milestone tracking for better insights');
    }

    return recommendations;
  }

  static void _logDetailedReport(Map<String, dynamic> report) {
    developer.log('=== Startup Performance Report ===');
    developer.log('Total startup time: ${report['total_startup_time']}ms');
    developer.log('First frame time: ${report['first_frame_time']}ms');

    final milestones = report['milestones'] as Map<String, int>;
    if (milestones.isNotEmpty) {
      developer.log('Milestones:');
      milestones.forEach((name, time) {
        developer.log('  - $name: ${time}ms');
      });
    }

    final summary = report['performance_summary'] as Map<String, dynamic>;
    developer.log(
      'Performance: ${summary['startup_category']} startup, ${summary['first_frame_category']} first frame',
    );

    final recommendations = summary['recommendations'] as List<String>;
    if (recommendations.isNotEmpty) {
      developer.log('Recommendations:');
      for (final rec in recommendations) {
        developer.log('  - $rec');
      }
    }

    developer.log('=== End Report ===');
  }

  /// Reset all metrics for new tracking session
  static void reset() {
    _appStartup.reset();
    _firstFrame.reset();
    _milestones.clear();
    _isTracking = false;

    developer.log('Startup metrics reset');
  }

  /// Get current tracking status
  static bool get isTracking => _isTracking;

  /// Get elapsed time since startup began
  static int get elapsedTime => _appStartup.elapsedMilliseconds;

  /// Get all recorded milestones
  static Map<String, int> get milestones => Map<String, int>.from(_milestones);
}
