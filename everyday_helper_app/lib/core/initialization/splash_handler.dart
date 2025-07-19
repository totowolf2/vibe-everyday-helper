import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'app_initializer.dart';

/// Handles splash screen and app initialization flow
class SplashHandler extends StatefulWidget {
  final Widget child;
  final Duration? minimumSplashDuration;

  const SplashHandler({
    super.key,
    required this.child,
    this.minimumSplashDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<SplashHandler> createState() => _SplashHandlerState();
}

class _SplashHandlerState extends State<SplashHandler>
    with TickerProviderStateMixin {
  bool _isInitialized = false;
  String _currentStep = 'Initializing...';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  Future<void> _initializeApp() async {
    developer.Timeline.startSync('splash_initialization');

    try {
      final stopwatch = Stopwatch()..start();

      // Step 1: Initialize essential services
      setState(() => _currentStep = 'Loading core services...');
      await AppInitializer.initializeEssentialServices();

      // Step 2: Initialize app services in background
      setState(() => _currentStep = 'Setting up features...');

      // Run service initialization in background without blocking UI
      AppInitializer.initializeServices();

      // Step 3: Ensure minimum splash duration for smooth UX
      final elapsed = stopwatch.elapsedMilliseconds;
      final minimumDuration =
          widget.minimumSplashDuration?.inMilliseconds ?? 1000;

      if (elapsed < minimumDuration) {
        setState(() => _currentStep = 'Ready!');
        await Future.delayed(Duration(milliseconds: minimumDuration - elapsed));
      }

      stopwatch.stop();
      developer.log(
        'Splash initialization completed in ${stopwatch.elapsedMilliseconds}ms',
      );

      // Fade out splash and show main app
      await _fadeController.reverse();

      if (mounted) {
        setState(() => _isInitialized = true);
        _fadeController.forward();
      }
    } catch (e) {
      developer.log('Splash initialization error: $e', error: e);
      // On error, still proceed to main app
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _currentStep = 'Error occurred, continuing...';
        });
      }
    } finally {
      developer.Timeline.finishSync();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        if (_isInitialized) {
          return FadeTransition(opacity: _fadeAnimation, child: widget.child);
        }

        return _buildSplashScreen();
      },
    );
  }

  Widget _buildSplashScreen() {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: theme.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: theme.primaryColor,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App icon/logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.help_outline,
                            size: 60,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App name
                  Text(
                    'Everyday Helper',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // App tagline
                  Text(
                    'Your daily problem solver',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Loading indicator
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Current step
                  Text(
                    _currentStep,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget to easily add splash functionality to any widget
class SplashWrapper extends StatelessWidget {
  final Widget child;
  final Duration? splashDuration;

  const SplashWrapper({super.key, required this.child, this.splashDuration});

  @override
  Widget build(BuildContext context) {
    return SplashHandler(minimumSplashDuration: splashDuration, child: child);
  }
}
