import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shared/theme/app_theme.dart';
import 'shared/constants/app_constants.dart';
import 'routes/app_routes.dart';
import 'core/initialization/app_initializer.dart';
import 'core/initialization/splash_handler.dart';
import 'core/performance/startup_metrics.dart';
import 'features/home/presentation/pages/home_screen.dart';

void main() async {
  // Start performance tracking
  StartupMetrics.startTracking();
  StartupMetrics.recordMilestone('main_begin');

  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  StartupMetrics.recordMilestone('binding_initialized');

  // Initialize essential services
  await AppInitializer.initializeEssentialServices();
  StartupMetrics.recordMilestone('essential_services_ready');

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  StartupMetrics.recordMilestone('orientations_set');

  // Launch app
  runApp(const MyApp());
  StartupMetrics.recordMilestone('run_app_called');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Record first frame milestone
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StartupMetrics.markFirstFrame();
    });

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.cachedLightTheme,
      debugShowCheckedModeBanner: false,
      home: SplashWrapper(
        splashDuration: const Duration(milliseconds: 1200),
        child: const HomeScreen(),
      ),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) {
        // Mark app as ready when navigation is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          StartupMetrics.markAppReady();
        });
        return child!;
      },
    );
  }
}
