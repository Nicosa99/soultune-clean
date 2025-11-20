/// Premium badge widget displaying lock icon for premium features.
///
/// A small, reusable overlay widget that indicates a feature requires
/// premium subscription. Displays a lock icon with subtle animations.
///
/// ## Usage
///
/// ```dart
/// // Overlay on any widget
/// Stack(
///   children: [
///     MyFeatureWidget(),
///     if (!isPremium) const PremiumBadge(),
///   ],
/// )
///
/// // With custom positioning
/// Stack(
///   children: [
///     MyFeatureWidget(),
///     Positioned(
///       top: 8,
///       right: 8,
///       child: PremiumBadge(size: 24),
///     ),
///   ],
/// )
/// ```
///
/// ## Design
///
/// - Material 3 design language
/// - Amber/gold color (premium feel)
/// - Subtle pulse animation
/// - Accessible (semantic label)
library;

import 'package:flutter/material.dart';

/// Premium badge widget with lock icon.
///
/// Displays a circular badge with lock icon to indicate premium features.
/// Includes subtle pulse animation to draw attention.
class PremiumBadge extends StatefulWidget {
  /// Creates a [PremiumBadge].
  const PremiumBadge({
    this.size = 32.0,
    this.iconSize = 18.0,
    this.animated = true,
    this.backgroundColor,
    this.iconColor,
    super.key,
  });

  /// Size of the badge circle.
  final double size;

  /// Size of the lock icon.
  final double iconSize;

  /// Whether to animate the badge (pulse effect).
  final bool animated;

  /// Background color of the badge.
  ///
  /// Defaults to amber/gold gradient.
  final Color? backgroundColor;

  /// Icon color.
  ///
  /// Defaults to white.
  final Color? iconColor;

  @override
  State<PremiumBadge> createState() => _PremiumBadgeState();
}

class _PremiumBadgeState extends State<PremiumBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bgColor = widget.backgroundColor ??
        const Color(0xFFFFB300); // Amber 700 - premium feel

    final iconColor = widget.iconColor ?? Colors.white;

    final badge = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withOpacity(0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.lock_rounded,
        size: widget.iconSize,
        color: iconColor,
      ),
    );

    if (!widget.animated) {
      return Semantics(
        label: 'Premium feature - requires subscription',
        child: badge,
      );
    }

    return Semantics(
      label: 'Premium feature - requires subscription',
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: badge,
      ),
    );
  }
}

/// Compact premium indicator for small spaces.
///
/// Displays just a lock icon without background circle.
/// Useful for inline indicators in lists.
///
/// ## Usage
///
/// ```dart
/// Row(
///   children: [
///     Text('Advanced Feature'),
///     const SizedBox(width: 4),
///     const PremiumIndicator(),
///   ],
/// )
/// ```
class PremiumIndicator extends StatelessWidget {
  /// Creates a [PremiumIndicator].
  const PremiumIndicator({
    this.size = 16.0,
    this.color,
    super.key,
  });

  /// Size of the lock icon.
  final double size;

  /// Icon color.
  ///
  /// Defaults to amber.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? const Color(0xFFFFB300);

    return Semantics(
      label: 'Premium',
      child: Icon(
        Icons.lock_rounded,
        size: size,
        color: iconColor,
      ),
    );
  }
}

/// Premium chip for feature labels.
///
/// Displays "PREMIUM" text chip with gradient background.
/// Useful for category labels, feature lists, etc.
///
/// ## Usage
///
/// ```dart
/// ListTile(
///   title: Text('CIA Gateway Protocol'),
///   trailing: const PremiumChip(),
/// )
/// ```
class PremiumChip extends StatelessWidget {
  /// Creates a [PremiumChip].
  const PremiumChip({
    this.label = 'PREMIUM',
    this.compact = false,
    super.key,
  });

  /// Label text.
  final String label;

  /// Whether to use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFB300), // Amber 700
            Color(0xFFFFA000), // Amber 800
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: compact ? 9 : 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
