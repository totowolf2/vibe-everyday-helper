# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application for Android that serves as an everyday helper app. The app is designed with menus separated by problem type and will be developed incrementally as new needs arise.

**Current Status**: The repository contains only a README.md file. The Flutter project structure has not been initialized yet.

## Development Commands

Since this is a Flutter project that hasn't been initialized, these are the expected commands once the Flutter project is set up:

```bash
# Install dependencies
flutter pub get

# Run the application (requires Android device/emulator)
flutter run

# Build for Android
flutter build apk

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

## Project Architecture

**Current Features to Implement:**
- Price Comparison Tool: Calculate price per unit for products with different quantities to help users find better value

**Planned Features:**
- To-Do List functionality
- Specialized calculators
- Additional everyday helper tools

## Development Setup

1. Ensure Flutter SDK is installed
2. Initialize Flutter project structure (not yet done)
3. Set up Android development environment
4. Connect Android device or start emulator

## Key Notes

- Target platform: Android
- Framework: Flutter with Dart
- Architecture: Will be menu-driven with problem-type separation
- Development approach: Incremental feature additions