/// SoulTune Home Screen
///
/// Main app screen with bottom navigation.
/// Provides access to Library, Playlists, and Now Playing screens.
///
/// ## Features
///
/// - Bottom navigation bar (Library, Playlists, Now Playing)
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
import 'package:soultune/features/playlist/presentation/screens/playlists_screen.dart';
import 'package:soultune/shared/widgets/mini_player.dart';

/// Home screen with bottom navigation.
///
/// Main entry point of the app, providing navigation between
/// Library, Playlists, and Now Playing screens.
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
    final currentFile = ref.watch(currentAudioFileProvider);
    final hasAudio = currentFile != null;

    // Show mini player only on Library and Playlists tabs
    final showMiniPlayer = hasAudio && _selectedIndex != 2;

    return Scaffold(
      body: Stack(
        children: [
          // Main content (PageView)
          PageView(
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

              // Playlists tab
              PlaylistsScreen(
                onNavigateToPlayer: _showNowPlayingModal,
              ),

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

          // Mini Player overlay (above Library/Playlists, below nav bar)
          Positioned(
            left: 0,
            right: 0,
            bottom: 80, // Height of NavigationBar
            child: AnimatedSlide(
              offset: showMiniPlayer ? Offset.zero : const Offset(0, 2),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: showMiniPlayer ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: MiniPlayer(
                  onTap: _showNowPlayingModal,
                ),
              ),
            ),
          ),
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

          // Playlists destination
          const NavigationDestination(
            icon: Icon(Icons.queue_music_outlined),
            selectedIcon: Icon(Icons.queue_music),
            label: 'Playlists',
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
