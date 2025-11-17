/// Predefined frequency presets for SoulTune.
///
/// Contains scientifically-based healing frequency presets organized
/// by category. These presets combine Solfeggio frequencies, brainwave
/// entrainment, and binaural beats.
library;

import 'package:soultune/features/generator/data/models/binaural_config.dart';
import 'package:soultune/features/generator/data/models/frequency_constants.dart';
import 'package:soultune/features/generator/data/models/frequency_layer.dart';
import 'package:soultune/features/generator/data/models/frequency_preset.dart';
import 'package:soultune/features/generator/data/models/preset_category.dart';
import 'package:soultune/features/generator/data/models/waveform.dart';

/// All predefined frequency presets.
///
/// Returns a list of 14 scientifically-designed presets covering
/// sleep, meditation, focus, healing, and energy categories.
List<FrequencyPreset> getPredefinedPresets() {
  final now = DateTime.now();

  return [
    // =========================================================================
    // SLEEP & RELAXATION (3 presets)
    // =========================================================================

    FrequencyPreset(
      id: 'preset_deep_sleep',
      name: 'Deep Sleep',
      category: PresetCategory.sleep,
      description: 'Delta waves for restorative deep sleep. '
          'Promotes physical healing and cellular regeneration.',
      layers: [
        const FrequencyLayer(
          frequency: 2.0,
          waveform: Waveform.sine,
          volume: 0.6,
          label: 'Delta Wave',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio174Hz,
          waveform: Waveform.sine,
          volume: 0.4,
          label: 'Pain Relief',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 207,
      ),
      durationMinutes: 60,
      tags: ['sleep', 'delta', 'healing', 'rest'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_twilight_sleep',
      name: 'Twilight Sleep',
      category: PresetCategory.sleep,
      description: 'Gentle theta waves for easy transition into sleep. '
          'Reduces racing thoughts and anxiety.',
      layers: [
        const FrequencyLayer(
          frequency: 4.0,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Theta Wave',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio174Hz,
          waveform: Waveform.sine,
          volume: 0.3,
          label: 'Grounding',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio285Hz,
          waveform: Waveform.sine,
          volume: 0.3,
          label: 'Cellular Healing',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 205,
      ),
      durationMinutes: 45,
      tags: ['sleep', 'theta', 'relaxation', 'anxiety'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_insomnia_relief',
      name: 'Insomnia Relief',
      category: PresetCategory.sleep,
      description: 'Specialized frequencies for chronic sleep issues. '
          'Combines healing tones with sleep-inducing delta waves.',
      layers: [
        const FrequencyLayer(
          frequency: 3.5,
          waveform: Waveform.sine,
          volume: 0.6,
          label: 'Deep Delta',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio528Hz,
          waveform: Waveform.sine,
          volume: 0.4,
          label: 'Miracle Frequency',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 220,
        rightFrequency: 226.5,
      ),
      durationMinutes: 90,
      tags: ['insomnia', 'sleep', 'healing', '528hz'],
      createdAt: now,
    ),

    // =========================================================================
    // MEDITATION & MINDFULNESS (3 presets)
    // =========================================================================

    FrequencyPreset(
      id: 'preset_theta_meditation',
      name: 'Theta Meditation',
      category: PresetCategory.meditation,
      description: 'Schumann Resonance for deep meditation. '
          "Aligns with Earth's natural frequency for grounding.",
      layers: [
        const FrequencyLayer(
          frequency: kSchumannResonance,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Schumann Resonance',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio528Hz,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Transformation',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 207.83,
      ),
      durationMinutes: 30,
      tags: ['meditation', 'theta', 'schumann', 'grounding'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_spiritual_awakening',
      name: 'Spiritual Awakening',
      category: PresetCategory.meditation,
      description: 'Higher Solfeggio frequencies for spiritual growth. '
          'Activates crown chakra and expands consciousness.',
      layers: [
        const FrequencyLayer(
          frequency: kSolfeggio963Hz,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Crown Chakra',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio741Hz,
          waveform: Waveform.sine,
          volume: 0.3,
          label: 'Intuition',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio852Hz,
          waveform: Waveform.sine,
          volume: 0.3,
          label: 'Spiritual Order',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 400,
        rightFrequency: 410,
      ),
      durationMinutes: 20,
      tags: ['spiritual', 'awakening', 'crown', 'consciousness'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_chakra_balancing',
      name: 'Chakra Balancing',
      category: PresetCategory.meditation,
      description: 'Sequential Solfeggio frequencies to balance all chakras. '
          'Harmonizes energy centers from root to crown.',
      layers: [
        const FrequencyLayer(
          frequency: kSolfeggio528Hz,
          waveform: Waveform.sine,
          volume: 0.6,
          label: 'Heart Center',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio396Hz,
          waveform: Waveform.sine,
          volume: 0.4,
          label: 'Root Chakra',
        ),
      ],
      durationMinutes: 25,
      tags: ['chakra', 'balance', 'energy', 'solfeggio'],
      createdAt: now,
    ),

    // =========================================================================
    // FOCUS & PRODUCTIVITY (3 presets)
    // =========================================================================

    FrequencyPreset(
      id: 'preset_deep_focus',
      name: 'Deep Focus',
      category: PresetCategory.focus,
      description: 'Beta and gamma waves for sustained concentration. '
          'Enhances mental clarity and productivity.',
      layers: [
        const FrequencyLayer(
          frequency: 20.0,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Beta Wave',
        ),
        const FrequencyLayer(
          frequency: 40.0,
          waveform: Waveform.sine,
          volume: 0.4,
          label: 'Gamma Wave',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 220,
      ),
      durationMinutes: 45,
      tags: ['focus', 'beta', 'productivity', 'clarity'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_gamma_boost',
      name: 'Gamma Brain Boost',
      category: PresetCategory.focus,
      description: 'High-frequency gamma waves for peak performance. '
          'Maximizes cognitive function and information processing.',
      layers: [
        const FrequencyLayer(
          frequency: 40.0,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Gamma 40Hz',
        ),
        const FrequencyLayer(
          frequency: 100.0,
          waveform: Waveform.sine,
          volume: 0.4,
          label: 'High Gamma',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 300,
        rightFrequency: 340,
      ),
      durationMinutes: 30,
      tags: ['gamma', 'cognitive', 'performance', 'brain'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_exam_mode',
      name: 'Study & Exam Mode',
      category: PresetCategory.focus,
      description: 'Optimized for learning and memory retention. '
          'Alpha-beta blend for relaxed alertness.',
      layers: [
        const FrequencyLayer(
          frequency: 12.0,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Alpha-Beta Border',
        ),
        const FrequencyLayer(
          frequency: 40.0,
          waveform: Waveform.sine,
          volume: 0.3,
          label: 'Gamma',
        ),
        const FrequencyLayer(
          frequency: 1000.0,
          waveform: Waveform.sine,
          volume: 0.2,
          label: 'Auditory Focus',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 220,
        rightFrequency: 232,
      ),
      durationMinutes: 60,
      tags: ['study', 'exam', 'learning', 'memory'],
      createdAt: now,
    ),

    // =========================================================================
    // HEALING & WELLNESS (3 presets)
    // =========================================================================

    FrequencyPreset(
      id: 'preset_dna_repair',
      name: 'DNA Repair',
      category: PresetCategory.healing,
      description: '528Hz Miracle Frequency for cellular healing. '
          'Promotes DNA repair and transformation.',
      layers: [
        const FrequencyLayer(
          frequency: kSolfeggio528Hz,
          waveform: Waveform.sine,
          volume: 0.6,
          label: 'Miracle Frequency',
        ),
        const FrequencyLayer(
          frequency: 432.0,
          waveform: Waveform.sine,
          volume: 0.4,
          label: 'Natural Harmony',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 228,
      ),
      durationMinutes: 30,
      tags: ['dna', 'repair', '528hz', 'cellular', 'miracle'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_stress_relief',
      name: 'Stress Relief',
      category: PresetCategory.healing,
      description: 'Release tension and anxiety with 396Hz. '
          'Liberates guilt and fear from the body.',
      layers: [
        const FrequencyLayer(
          frequency: kSolfeggio396Hz,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Liberation',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio174Hz,
          waveform: Waveform.sine,
          volume: 0.4,
          label: 'Pain Relief',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 205.96,
      ),
      durationMinutes: 20,
      tags: ['stress', 'anxiety', 'relief', 'calm'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_pain_reduction',
      name: 'Pain Reduction',
      category: PresetCategory.healing,
      description: 'Low Solfeggio frequencies for physical pain. '
          'Promotes tissue regeneration and comfort.',
      layers: [
        const FrequencyLayer(
          frequency: kSolfeggio174Hz,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Pain Relief',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio285Hz,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Regeneration',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 220,
        rightFrequency: 226,
      ),
      durationMinutes: 25,
      tags: ['pain', 'relief', 'healing', 'body'],
      createdAt: now,
    ),

    // =========================================================================
    // ENERGY & MOTIVATION (2 presets)
    // =========================================================================

    FrequencyPreset(
      id: 'preset_morning_energy',
      name: 'Morning Energizer',
      category: PresetCategory.energy,
      description: 'Uplifting frequencies to start your day. '
          'Combines beta waves with healing 528Hz.',
      layers: [
        const FrequencyLayer(
          frequency: 18.0,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Beta Awakening',
        ),
        const FrequencyLayer(
          frequency: 40.0,
          waveform: Waveform.sine,
          volume: 0.3,
          label: 'Gamma Energy',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio528Hz,
          waveform: Waveform.sine,
          volume: 0.3,
          label: 'Positive Vibration',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 220,
        rightFrequency: 238,
      ),
      durationMinutes: 15,
      tags: ['morning', 'energy', 'motivation', 'wake'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_passion_activation',
      name: 'Passion Activation',
      category: PresetCategory.energy,
      description: 'Ignite your inner fire and motivation. '
          'Beta waves combined with harmonic 432Hz.',
      layers: [
        const FrequencyLayer(
          frequency: 25.0,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'High Beta',
        ),
        const FrequencyLayer(
          frequency: 432.0,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Natural Harmony',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 225,
      ),
      durationMinutes: 20,
      tags: ['passion', 'motivation', 'drive', 'energy'],
      createdAt: now,
    ),

    // =========================================================================
    // CIA GATEWAY PROCESS (Declassified 1983, Public 2003)
    // =========================================================================

    FrequencyPreset(
      id: 'preset_cia_focus10',
      name: 'Focus 10 (Gateway)',
      category: PresetCategory.cia,
      description: 'CIA Gateway Level 1: "Mind Awake, Body Asleep". '
          'The foundational state from declassified 1983 Army Intelligence '
          'report. Entry point for consciousness expansion training.',
      layers: const [],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 210,
      ),
      durationMinutes: 30,
      tags: ['cia', 'gateway', 'focus10', 'alpha', 'foundation'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_cia_focus12',
      name: 'Focus 12 (Expanded)',
      category: PresetCategory.cia,
      description: 'CIA Gateway Level 2: Expanded awareness beyond normal '
          'consciousness. "The bridge to Focus 15 and beyond." '
          'First OBE-like sensations typically occur here.',
      layers: const [],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 212,
      ),
      durationMinutes: 35,
      tags: ['cia', 'gateway', 'focus12', 'expanded', 'awareness'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_cia_focus15',
      name: 'Focus 15 (No-Time)',
      category: PresetCategory.cia,
      description: 'CIA Gateway Level 3: "No-Time" state. Vibrational '
          'sensations and energy field awareness begin. Preparation for '
          'Focus 21 breakthrough. Use panning for enhanced effect.',
      layers: const [],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 215,
      ),
      durationMinutes: 40,
      tags: ['cia', 'gateway', 'focus15', 'no-time', 'vibrations'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_cia_focus21',
      name: 'Focus 21 (THE GATEWAY)',
      category: PresetCategory.cia,
      description: '⚠️ ADVANCED: The breakthrough state. CIA: "Expanded '
          'consciousness beyond spacetime. OBE, remote viewing accessible." '
          'Requires 4+ weeks Focus 10-15 practice. ENABLE PANNING!',
      layers: const [],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 206,
      ),
      durationMinutes: 60,
      tags: ['cia', 'gateway', 'focus21', 'theta', 'breakthrough', 'advanced'],
      createdAt: now,
    ),

    // =========================================================================
    // OUT-OF-BODY EXPERIENCE
    // =========================================================================

    FrequencyPreset(
      id: 'preset_oobe_initiation',
      name: 'OBE Initiation',
      category: PresetCategory.oobe,
      description: 'Schumann Resonance (7.83Hz) for OBE induction. '
          'Best at 3-6 AM when melatonin peaks. May cause sleep paralysis. '
          'Enable panning for maximum effect.',
      layers: const [],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 207.83,
      ),
      durationMinutes: 90,
      tags: ['oobe', 'astral', 'schumann', 'theta', 'advanced'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_astral_projection',
      name: 'Astral Projection',
      category: PresetCategory.oobe,
      description: '4Hz Delta with 528Hz healing overlay. Highest reported '
          'OBE success rate. Extended duration for deep exploration. '
          'Advanced practitioners only.',
      layers: [
        const FrequencyLayer(
          frequency: 4.0,
          waveform: Waveform.sine,
          volume: 0.6,
          label: 'Delta Base',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio528Hz,
          waveform: Waveform.sine,
          volume: 0.4,
          label: 'Love Frequency',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 204,
      ),
      durationMinutes: 120,
      tags: ['oobe', 'astral', 'delta', 'advanced', 'extended'],
      createdAt: now,
    ),

    // =========================================================================
    // REMOTE VIEWING (Project Stargate)
    // =========================================================================

    FrequencyPreset(
      id: 'preset_remote_viewing',
      name: 'RV Training',
      category: PresetCategory.remoteViewing,
      description: 'Used by CIA Project Stargate (1978-1995). '
          'Joseph McMoneagle achieved 450+ successful missions. '
          'Beta waves for focused remote perception.',
      layers: const [],
      binauralConfig: const BinauralConfig(
        leftFrequency: 220,
        rightFrequency: 238,
      ),
      durationMinutes: 45,
      tags: ['rv', 'remote-viewing', 'stargate', 'beta', 'perception'],
      createdAt: now,
    ),

    FrequencyPreset(
      id: 'preset_enhanced_perception',
      name: 'Enhanced Perception',
      category: PresetCategory.remoteViewing,
      description: '40Hz Gamma for peak cognitive function. Research shows '
          'Gamma correlates with "Aha!" moments and heightened intuition. '
          'ESP and precognition development.',
      layers: const [],
      binauralConfig: const BinauralConfig(
        leftFrequency: 300,
        rightFrequency: 340,
      ),
      durationMinutes: 30,
      tags: ['gamma', 'esp', 'intuition', 'perception', 'peak'],
      createdAt: now,
    ),

    // =========================================================================
    // CONSCIOUSNESS EXPANSION
    // =========================================================================

    FrequencyPreset(
      id: 'preset_dimensional_awareness',
      name: 'Dimensional Awareness',
      category: PresetCategory.consciousness,
      description: 'Multi-layered stack: 963Hz Crown Chakra + 432Hz '
          'natural harmony + 6Hz Theta base. Advanced consciousness '
          'exploration and expanded dimensional perception.',
      layers: [
        const FrequencyLayer(
          frequency: 6.0,
          waveform: Waveform.sine,
          volume: 0.5,
          label: 'Theta Base',
        ),
        const FrequencyLayer(
          frequency: kSolfeggio963Hz,
          waveform: Waveform.sine,
          volume: 0.3,
          label: 'Crown Chakra',
        ),
        const FrequencyLayer(
          frequency: 432.0,
          waveform: Waveform.sine,
          volume: 0.2,
          label: 'Natural Harmony',
        ),
      ],
      binauralConfig: const BinauralConfig(
        leftFrequency: 200,
        rightFrequency: 206,
      ),
      durationMinutes: 60,
      tags: ['consciousness', 'dimensions', 'advanced', 'expansion'],
      createdAt: now,
    ),
  ];
}
