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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:soultune/shared/services/file/download_scanner_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Quick site model for browser bookmarks.
class QuickSite {
  /// Creates a [QuickSite].
  const QuickSite({
    required this.name,
    required this.url,
    required this.icon,
    this.isStreaming = false,
    this.isDownloader = false,
  });

  /// Display name of the site.
  final String name;

  /// URL of the site.
  final String url;

  /// Icon/emoji for the site.
  final String icon;

  /// Whether this is a streaming service.
  final bool isStreaming;

  /// Whether this is a downloader service.
  final bool isDownloader;
}

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

  /// Download scanner service.
  final _downloadScanner = DownloadScannerService();

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

  /// Current site being viewed (for showing scan button).
  QuickSite? _currentSite;

  /// URL text editing controller.
  final _urlController = TextEditingController();

  /// All available quick sites.
  static const List<QuickSite> _quickSites = [
    // Streaming Services
    QuickSite(
      name: '▶️ YouTube',
      url: 'https://www.youtube.com',
      icon: '▶️',
      isStreaming: true,
    ),
    QuickSite(
      name: '🎵 Spotify',
      url: 'https://open.spotify.com',
      icon: '🎵',
      isStreaming: true,
    ),
    QuickSite(
      name: '☁️ SoundCloud',
      url: 'https://soundcloud.com',
      icon: '☁️',
      isStreaming: true,
    ),
    QuickSite(
      name: '🍎 Apple Music',
      url: 'https://music.apple.com',
      icon: '🍎',
      isStreaming: true,
    ),
    QuickSite(
      name: '🎧 Bandcamp',
      url: 'https://bandcamp.com',
      icon: '🎧',
      isStreaming: true,
    ),
    // Downloader Services
    QuickSite(
      name: '🎧 Loader.to',
      url: 'https://loader.to/',
      icon: '🎧',
      isDownloader: true,
    ),
  ];

  /// Whether to show scan downloads button.
  bool get _showScanButton => _currentSite?.isDownloader ?? false;

  @override
  void initState() {
    super.initState();
    _urlController.text = _currentUrl;
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
        _urlController.text = savedUrl;
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

  /// Updates current site based on URL.
  void _updateCurrentSite(String? url) {
    if (url == null) return;

    try {
      final uri = Uri.parse(url);
      final site = _quickSites.firstWhere(
        (site) {
          final siteUri = Uri.parse(site.url);
          return uri.host.contains(siteUri.host) ||
              siteUri.host.contains(uri.host);
        },
        orElse: () => const QuickSite(
          name: 'Unknown',
          url: '',
          icon: '🌐',
        ),
      );

      setState(() {
        _currentSite = site;
      });

      _logger.i('Current site: ${site.name} (downloader: ${site.isDownloader})');
    } catch (e) {
      _logger.e('Failed to update current site: $e');
    }
  }

  /// Ad blocker domain list.
  static const _adDomains = [
    'doubleclick.net',
    'googlesyndication.com',
    'googleadservices.com',
    'google-analytics.com',
    'googletagmanager.com',
    'facebook.net',
    'ads.youtube.com',
    'ad.doubleclick.net',
    'adservice.google.com',
    'pagead2.googlesyndication.com',
  ];

  /// Checks if domain is an ad domain.
  bool _isAdDomain(String host) {
    return _adDomains.any((adDomain) => host.contains(adDomain));
  }

  /// Handles file downloads from WebView.
  Future<void> _handleDownload(String url, String? suggestedFilename) async {
    try {
      _logger.i('Download started: $url');

      // Show download starting notification
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⬇️ Downloading ${suggestedFilename ?? 'file'}...'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Download file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Download failed: ${response.statusCode}');
      }

      // Get Downloads directory
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Generate filename
      final filename = suggestedFilename ??
          path.basename(Uri.parse(url).path) ??
          'download_${DateTime.now().millisecondsSinceEpoch}';

      final filePath = path.join(downloadsDir.path, filename);

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      _logger.i('Download completed: $filePath');

      // Show success notification
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Download complete: $filename'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Scan',
            textColor: Colors.white,
            onPressed: () => _scanAndImportDownloads(),
          ),
        ),
      );
    } catch (e) {
      _logger.e('Download failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Initializes the WebView controller.
  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setOnDownloadStartRequest((request) async {
        await _handleDownload(request.url, request.suggestedFilename);
      })
      ..addJavaScriptChannel(
        'UrlChangeHandler',
        onMessageReceived: (message) {
          final newUrl = message.message;
          if (newUrl != _currentUrl) {
            setState(() {
              _currentUrl = newUrl;
              _urlController.text = newUrl;
            });
            _updateCurrentSite(newUrl);
            _saveBrowserState();
            _logger.i('URL changed via JS: $newUrl');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);

            // Ad blocker - block known ad domains
            if (_isAdDomain(uri.host)) {
              _logger.i('🚫 Blocked ad: ${uri.host}');
              return NavigationDecision.prevent;
            }

            // Block non-http(s) URLs (intent://, blob://, etc.)
            if (uri.scheme != 'http' && uri.scheme != 'https') {
              _logger.w('Blocked non-http(s) URL: ${uri.scheme}://${uri.host}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '⚠️ Download ready! Check your Downloads folder, '
                    'then tap "Scan Downloads"',
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            setState(() {
              _currentUrl = url;
              _urlController.text = url;
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

            // Update current site (for scan button visibility)
            _updateCurrentSite(url);

            // Save state
            _saveBrowserState();

            // Inject URL change listener for SPAs (YouTube, etc.)
            _injectUrlChangeListener();

            // Inject frequency if enabled
            if (_isHz432Enabled) {
              _injectFrequency();
            }
          },
          onWebResourceError: (error) {
            // Ignore ERR_UNKNOWN_URL_SCHEME (downloads)
            if (error.description?.contains('ERR_UNKNOWN_URL_SCHEME') ?? false) {
              _logger.i('Download URL detected (ignored)');
              return;
            }
            _logger.e('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  /// Injects URL change listener for Single Page Apps.
  ///
  /// Detects URL changes in SPAs like YouTube that use History API.
  /// Also blocks popups.
  Future<void> _injectUrlChangeListener() async {
    final script = '''
(function() {
  // Only inject once
  if (window.urlChangeListenerInjected) return;
  window.urlChangeListenerInjected = true;

  // === URL Change Listener ===

  // Store original pushState and replaceState
  const originalPushState = history.pushState;
  const originalReplaceState = history.replaceState;

  // Override pushState
  history.pushState = function() {
    originalPushState.apply(history, arguments);
    UrlChangeHandler.postMessage(window.location.href);
  };

  // Override replaceState
  history.replaceState = function() {
    originalReplaceState.apply(history, arguments);
    UrlChangeHandler.postMessage(window.location.href);
  };

  // Listen for popstate (back/forward buttons)
  window.addEventListener('popstate', function() {
    UrlChangeHandler.postMessage(window.location.href);
  });

  // === Popup Blocker ===

  // Block window.open
  window.open = function() {
    console.log('🚫 Popup blocked');
    return null;
  };

  // Block target="_blank" links
  document.addEventListener('click', function(e) {
    const target = e.target.closest('a');
    if (target && target.target === '_blank') {
      e.preventDefault();
      e.stopPropagation();
      console.log('🚫 Blocked _blank link:', target.href);
      return false;
    }
  }, true);

  console.log('URL change listener & popup blocker active');
})();
''';

    try {
      await _controller.runJavaScript(script);
      _logger.i('URL change listener & popup blocker injected');
    } catch (e) {
      _logger.e('Failed to inject URL change listener: $e');
    }
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Editable URL field
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter URL...',
                        hintStyle: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      textInputAction: TextInputAction.go,
                      keyboardType: TextInputType.url,
                      onSubmitted: (url) {
                        if (url.isEmpty) return;

                        // Add https:// if no scheme
                        var finalUrl = url;
                        if (!url.startsWith('http://') &&
                            !url.startsWith('https://')) {
                          finalUrl = 'https://$url';
                        }

                        _controller.loadRequest(Uri.parse(finalUrl));
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                  // Copy button
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: _urlController.text),
                      );
                      HapticFeedback.lightImpact();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 URL copied to clipboard'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Frequency status
            if (_isHz432Enabled)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${_selectedFrequency.toInt()} Hz Active',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontSize: 10,
                  ),
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
      floatingActionButton: _showScanButton
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Scan Downloads'),
              backgroundColor: Colors.green,
              onPressed: _scanAndImportDownloads,
            )
          : null,
    );
  }

  /// Scans Downloads folder and imports new music files.
  Future<void> _scanAndImportDownloads() async {
    try {
      HapticFeedback.mediumImpact();

      // Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Scan downloads folder
      final newFiles = await _downloadScanner.scanAndImport();

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (newFiles.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No new downloads found in Downloads folder'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Show import dialog
        if (!mounted) return;
        _showImportDialog(newFiles);
      }
    } catch (e) {
      _logger.e('Failed to scan downloads: $e');
      if (!mounted) return;
      Navigator.pop(context); // Close loading if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to scan downloads: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Shows import dialog with preview of new files.
  void _showImportDialog(List<String> files) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text('${files.length} new ${files.length == 1 ? 'file' : 'files'} found!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Downloaded music:'),
            const SizedBox(height: 8),
            ...files.take(5).map(
                  (file) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '• $file',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            if (files.length > 5)
              Text(
                '... and ${files.length - 5} more',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.music_note),
            label: const Text('Play with 432 Hz'),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Navigate to library with new files highlighted
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Files imported! Check your library to play with 432 Hz',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
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
        children: _quickSites
            .map((site) => _buildQuickSiteChip(site, colorScheme))
            .toList(),
      ),
    );
  }

  /// Builds a quick site chip.
  Widget _buildQuickSiteChip(QuickSite site, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        label: Text(site.name),
        backgroundColor: site.isDownloader
            ? Colors.deepPurple.withOpacity(0.3)
            : site.isStreaming
                ? Colors.blue.withOpacity(0.3)
                : null,
        onPressed: () {
          HapticFeedback.selectionClick();
          _controller.loadRequest(Uri.parse(site.url));

          // Show helper tip for downloader sites
          if (site.isDownloader) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  '💡 Download music, then tap "Scan Downloads" to import',
                ),
                backgroundColor: Colors.deepPurple,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Got it',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
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
    _urlController.dispose();
    super.dispose();
  }
}
