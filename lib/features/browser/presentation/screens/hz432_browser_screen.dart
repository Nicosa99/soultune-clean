/// 432 Hz Web Browser Screen
///
/// Embedded WebView browser that injects healing frequencies into
/// any website's audio using Web Audio API JavaScript injection.
///
/// Features:
/// - Mix 432 Hz or Solfeggio frequencies with website audio
/// - Works with YouTube, Spotify, SoundCloud, etc.
/// - Volume control for frequency layer
/// - Quick site bookmarks
/// - Standard browser navigation
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 432 Hz Browser screen with frequency injection.
///
/// Allows users to browse any website while mixing healing frequencies
/// into the audio stream using Web Audio API JavaScript injection.
class Hz432BrowserScreen extends ConsumerStatefulWidget {
  /// Creates a [Hz432BrowserScreen].
  const Hz432BrowserScreen({super.key});

  @override
  ConsumerState<Hz432BrowserScreen> createState() =>
      _Hz432BrowserScreenState();
}

class _Hz432BrowserScreenState extends ConsumerState<Hz432BrowserScreen> {
  /// WebView controller.
  late WebViewController _controller;

  /// Logger instance.
  final _logger = Logger();

  /// Whether 432 Hz frequency is enabled.
  bool _isHz432Enabled = false;

  /// Volume of injected frequency (0.0 to 1.0).
  double _hz432Volume = 0.3;

  /// Selected frequency (Hz).
  double _selectedFrequency = 432.0;

  /// Current URL being viewed.
  String _currentUrl = 'https://www.youtube.com';

  /// Whether the page is loading.
  bool _isLoading = true;

  /// Loading progress (0.0 to 1.0).
  double _loadingProgress = 0.0;

  /// Whether control bar is expanded.
  bool _isControlBarExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadBrowserState();
    _initializeWebView();
  }

  /// Loads saved browser state from Hive.
  Future<void> _loadBrowserState() async {
    try {
      final box = await Hive.openBox<dynamic>('browser_state');
      final savedUrl = box.get('last_url') as String?;
      final savedFrequency = box.get('selected_frequency') as double?;
      final savedVolume = box.get('volume') as double?;
      final savedEnabled = box.get('enabled') as bool?;

      if (savedUrl != null) {
        _currentUrl = savedUrl;
      }
      if (savedFrequency != null) {
        _selectedFrequency = savedFrequency;
      }
      if (savedVolume != null) {
        _hz432Volume = savedVolume;
      }
      if (savedEnabled != null) {
        _isHz432Enabled = savedEnabled;
      }

      _logger.i('Loaded browser state: $_currentUrl');
    } catch (e) {
      _logger.e('Failed to load browser state: $e');
    }
  }

  /// Saves browser state to Hive.
  Future<void> _saveBrowserState() async {
    try {
      final box = await Hive.openBox<dynamic>('browser_state');
      await box.put('last_url', _currentUrl);
      await box.put('selected_frequency', _selectedFrequency);
      await box.put('volume', _hz432Volume);
      await box.put('enabled', _isHz432Enabled);
    } catch (e) {
      _logger.e('Failed to save browser state: $e');
    }
  }

  /// Initializes the WebView controller.
  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _currentUrl = url;
              _isLoading = true;
              _loadingProgress = 0.0;
            });
          },
          onProgress: (progress) {
            setState(() {
              _loadingProgress = progress / 100.0;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
              _loadingProgress = 1.0;
            });

            // Save state
            _saveBrowserState();

            // Inject frequency if enabled
            if (_isHz432Enabled) {
              _injectFrequency();
            }
          },
          onWebResourceError: (error) {
            _logger.e('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  /// Injects frequency mixing JavaScript into the page.
  ///
  /// Creates an oscillator with the selected frequency and mixes it
  /// with the page's audio using Web Audio API.
  Future<void> _injectFrequency() async {
    final script = '''
(function() {
  // Only inject once per page
  if (window.hz432Injected) {
    console.log('432 Hz already injected');
    return;
  }

  try {
    // Create Audio Context
    const audioCtx = new (window.AudioContext || window.webkitAudioContext)();

    // Create Oscillator (Solfeggio Frequency)
    const osc = audioCtx.createOscillator();
    osc.frequency.value = $_selectedFrequency;
    osc.type = 'sine';

    // Create Gain Node (Volume Control)
    const gainNode = audioCtx.createGain();
    gainNode.gain.value = $_hz432Volume;

    // Connect: Oscillator -> Gain -> Output
    osc.connect(gainNode);
    gainNode.connect(audioCtx.destination);

    // Start Oscillator
    osc.start();

    // Store references for control
    window.hz432Oscillator = osc;
    window.hz432GainNode = gainNode;
    window.hz432AudioContext = audioCtx;
    window.hz432Injected = true;

    console.log('$_selectedFrequency Hz Base Frequency Active (Volume: $_hz432Volume)');
  } catch (error) {
    console.error('432 Hz injection failed:', error);
  }
})();
''';

    try {
      await _controller.runJavaScript(script);
      _logger.i('Injected $_selectedFrequency Hz frequency');
    } catch (e) {
      _logger.e('Failed to inject frequency: $e');
    }
  }

  /// Stops the injected frequency.
  Future<void> _stopFrequency() async {
    final script = '''
(function() {
  try {
    if (window.hz432Oscillator) {
      window.hz432Oscillator.stop();
      window.hz432Oscillator.disconnect();
      window.hz432Oscillator = null;
    }
    if (window.hz432GainNode) {
      window.hz432GainNode.disconnect();
      window.hz432GainNode = null;
    }
    if (window.hz432AudioContext) {
      window.hz432AudioContext.close();
      window.hz432AudioContext = null;
    }
    window.hz432Injected = false;
    console.log('432 Hz stopped');
  } catch (error) {
    console.error('Failed to stop 432 Hz:', error);
  }
})();
''';

    try {
      await _controller.runJavaScript(script);
      _logger.i('Stopped frequency');
    } catch (e) {
      _logger.e('Failed to stop frequency: $e');
    }
  }

  /// Updates the volume of the injected frequency.
  Future<void> _updateVolume(double volume) async {
    final script = '''
(function() {
  try {
    if (window.hz432GainNode) {
      window.hz432GainNode.gain.value = $volume;
      console.log('Volume updated to $volume');
    }
  } catch (error) {
    console.error('Failed to update volume:', error);
  }
})();
''';

    try {
      await _controller.runJavaScript(script);
    } catch (e) {
      _logger.e('Failed to update volume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (await _controller.canGoBack()) {
              HapticFeedback.selectionClick();
              await _controller.goBack();
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '432 Hz Browser',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_isHz432Enabled)
              Text(
                '${_selectedFrequency.toInt()} Hz Active',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                ),
              ),
          ],
        ),
        actions: [
          // Forward Button
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                HapticFeedback.selectionClick();
                await _controller.goForward();
              }
            },
          ),

          // Collapse/Expand Controls (when enabled)
          if (_isHz432Enabled)
            IconButton(
              icon: Icon(
                _isControlBarExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _isControlBarExpanded = !_isControlBarExpanded);
              },
              tooltip: _isControlBarExpanded ? 'Hide Controls' : 'Show Controls',
            ),

          // Frequency Toggle
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Text(
                  '432 Hz',
                  style: theme.textTheme.bodySmall,
                ),
                Switch(
                  value: _isHz432Enabled,
                  onChanged: (value) async {
                    HapticFeedback.mediumImpact();
                    setState(() => _isHz432Enabled = value);
                    if (value) {
                      await _injectFrequency();
                    } else {
                      await _stopFrequency();
                    }
                    await _saveBrowserState();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Loading Progress Bar
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress,
              minHeight: 2,
            ),

          // Control Bar (when enabled and expanded)
          if (_isHz432Enabled && _isControlBarExpanded)
            _buildControlBar(theme, colorScheme),

          // Quick Sites
          _buildQuickSites(theme, colorScheme),

          // WebView
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }

  /// Builds the frequency control bar.
  Widget _buildControlBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.primaryContainer.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Frequency Selector
          Row(
            children: [
              Icon(
                Icons.graphic_eq,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<double>(
                  value: _selectedFrequency,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 174,
                      child: Text('174 Hz (Pain Relief)'),
                    ),
                    DropdownMenuItem(
                      value: 285,
                      child: Text('285 Hz (Healing)'),
                    ),
                    DropdownMenuItem(
                      value: 396,
                      child: Text('396 Hz (Liberation)'),
                    ),
                    DropdownMenuItem(
                      value: 417,
                      child: Text('417 Hz (Change)'),
                    ),
                    DropdownMenuItem(
                      value: 432,
                      child: Text('432 Hz (Peace)'),
                    ),
                    DropdownMenuItem(
                      value: 528,
                      child: Text('528 Hz (Love & DNA)'),
                    ),
                    DropdownMenuItem(
                      value: 639,
                      child: Text('639 Hz (Connection)'),
                    ),
                    DropdownMenuItem(
                      value: 741,
                      child: Text('741 Hz (Awakening)'),
                    ),
                    DropdownMenuItem(
                      value: 852,
                      child: Text('852 Hz (Intuition)'),
                    ),
                    DropdownMenuItem(
                      value: 963,
                      child: Text('963 Hz (Enlightenment)'),
                    ),
                  ],
                  onChanged: (freq) async {
                    if (freq == null) return;
                    HapticFeedback.selectionClick();
                    setState(() => _selectedFrequency = freq);
                    await _stopFrequency();
                    await _injectFrequency();
                    await _saveBrowserState();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Volume Control
          Row(
            children: [
              Icon(
                Icons.volume_down,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
              Expanded(
                child: Slider(
                  value: _hz432Volume,
                  min: 0,
                  max: 1,
                  onChanged: (value) {
                    setState(() => _hz432Volume = value);
                    _updateVolume(value);
                  },
                  onChangeEnd: (value) {
                    _saveBrowserState();
                  },
                ),
              ),
              Icon(
                Icons.volume_up,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${(_hz432Volume * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the quick sites bar.
  Widget _buildQuickSites(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _buildQuickSiteChip('▶️ YouTube', 'https://www.youtube.com'),
          _buildQuickSiteChip('🎵 Spotify', 'https://open.spotify.com'),
          _buildQuickSiteChip('☁️ SoundCloud', 'https://soundcloud.com'),
          _buildQuickSiteChip('🍎 Apple Music', 'https://music.apple.com'),
          _buildQuickSiteChip('🎧 Bandcamp', 'https://bandcamp.com'),
        ],
      ),
    );
  }

  /// Builds a quick site chip.
  Widget _buildQuickSiteChip(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        label: Text(label),
        onPressed: () {
          HapticFeedback.selectionClick();
          _controller.loadRequest(Uri.parse(url));
        },
      ),
    );
  }

  @override
  void dispose() {
    // Stop frequency before disposing
    if (_isHz432Enabled) {
      _stopFrequency();
    }
    super.dispose();
  }
}
