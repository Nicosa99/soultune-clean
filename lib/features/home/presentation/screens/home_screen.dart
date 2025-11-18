/// SoulTune Home Screen
///
/// Main app screen with bottom navigation.
/// Provides access to Library, Playlists, and Now Playing screens.
///
/// ## Features
///
/// - Bottom navigation bar (Library, Generator, Now Playing)
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
import 'package:soultune/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:soultune/features/generator/presentation/screens/generator_screen.dart';
import 'package:soultune/features/library/presentation/screens/library_screen.dart';
import 'package:soultune/features/player/presentation/providers/player_providers.dart';
import 'package:soultune/features/player/presentation/screens/now_playing_screen.dart';
import 'package:soultune/shared/widgets/mini_player.dart';

/// Home screen with bottom navigation.
///
/// Main entry point of the app, providing navigation between
/// Library, Generator, and Now Playing screens.
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
    final hasAudio = currentFileAsync.valueOrNull != null;

    // Show mini player on Library, Generator and Discovery tabs (not Now Playing)
    final showMiniPlayer = hasAudio && _selectedIndex != 3;

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
            onNavigateToPlayer: _showNowPlayingModal,
          ),

          // Generator tab
          const GeneratorScreen(),

          // Discovery tab
          const DiscoveryScreen(),

          // Now Playing tab
          NowPlayingScreen(
            onNavigateBack: () {
              // Navigate back to Library tab
              setState(() {
                _selectedIndex = 0;
              });
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini Player (directly above navigation bar)
            if (showMiniPlayer)
              AnimatedSlide(
                offset: Offset.zero,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: MiniPlayer(
                  onTap: _showNowPlayingModal,
                ),
              ),

            // Navigation Bar
            NavigationBar(
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

                // Generator destination
                const NavigationDestination(
                  icon: Icon(Icons.waves_outlined),
                  selectedIcon: Icon(Icons.waves),
                  label: 'Generator',
                ),

                // Discovery destination
                const NavigationDestination(
                  icon: Icon(Icons.science_outlined),
                  selectedIcon: Icon(Icons.science),
                  label: 'Discovery',
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
          ],
        ),
      ),
    );
  }

  /// Shows Now Playing screen as modal bottom sheet.
  ///
  /// Can be triggered from:
  /// - Mini player tap
  /// - Library/Playlist track tap
  void _showNowPlayingModal() {
    // Use post-frame callback to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 1.0,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder: (context, scrollController) => NowPlayingScreen(
            onNavigateBack: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    });
  }
}
