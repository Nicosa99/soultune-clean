/// SoulTune Home Screen
///
/// Main app screen with bottom navigation.
/// Provides access to Library and Now Playing screens.
///
/// ## Features
///
/// - Bottom navigation bar (Library, Now Playing)
/// - Smooth page transitions
/// - Persistent state between tabs
/// - Material 3 navigation bar
/// - Badge on Now Playing when audio is playing
///
/// ## Usage
///
/// ```dart
/// MaterialApp(
///   home: HomeScreen(),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/library/presentation/screens/library_screen.dart';
import 'package:soultune/features/player/presentation/providers/player_providers.dart';
import 'package:soultune/features/player/presentation/screens/now_playing_screen.dart';

/// Home screen with bottom navigation.
///
/// Main entry point of the app, providing navigation between
/// Library and Now Playing screens.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Current selected tab index.
  int _selectedIndex = 0;

  /// Page controller for smooth transitions.
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFileAsync = ref.watch(currentAudioFileProvider);
    final hasAudio = currentFileAsync.value != null;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          // Library tab
          LibraryScreen(
            onNavigateToPlayer: () {
              // Navigate to Now Playing tab when music starts
              setState(() {
                _selectedIndex = 1;
              });
              _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),

          // Now Playing tab
          const NowPlayingScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        destinations: [
          // Library destination
          const NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Library',
          ),

          // Now Playing destination
          NavigationDestination(
            icon: Badge(
              isLabelVisible: hasAudio,
              child: const Icon(Icons.music_note_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: hasAudio,
              child: const Icon(Icons.music_note),
            ),
            label: 'Now Playing',
          ),
        ],
      ),
    );
  }
}
