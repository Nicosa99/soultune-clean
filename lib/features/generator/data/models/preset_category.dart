/// Categories for frequency presets.
///
/// Groups presets by their primary therapeutic purpose.
library;

/// Category types for frequency presets.
enum PresetCategory {
  /// Sleep and relaxation presets.
  sleep('Sleep', '😴', 'Deep rest & relaxation'),

  /// Meditation and mindfulness presets.
  meditation('Meditation', '🧘', 'Inner peace & awareness'),

  /// Focus and productivity presets.
  focus('Focus', '⚡', 'Concentration & clarity'),

  /// Healing and wellness presets.
  healing('Healing', '💆', 'Physical & emotional recovery'),

  /// Energy and motivation presets.
  energy('Energy', '🔥', 'Vitality & motivation'),

  /// CIA Gateway Process presets (declassified).
  cia('CIA Gateway', '🔓', 'Declassified consciousness tech'),

  /// Out-of-body experience presets.
  oobe('Out-of-Body', '👁️', 'OBE & astral projection'),

  /// Remote viewing training presets.
  remoteViewing('Remote Viewing', '🔭', 'Enhanced perception & RV'),

  /// Advanced consciousness expansion.
  consciousness('Consciousness', '🌌', 'Expanded awareness states'),

  /// Custom user-created presets.
  custom('Custom', '⭐', 'Your personal presets');

  /// Creates a [PresetCategory] with display properties.
  const PresetCategory(this.displayName, this.emoji, this.description);

  /// Human-readable category name.
  final String displayName;

  /// Emoji icon for the category.
  final String emoji;

  /// Short description of the category.
  final String description;
}
