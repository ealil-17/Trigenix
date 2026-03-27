import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';
import 'responsive_layout.dart';

class GradientPageBackground extends StatelessWidget {
  final Widget child;

  const GradientPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topColor = isDark ? const Color(0xFF0E1A33) : const Color(0xFFD8E8FF);
    final bottomColor = isDark ? const Color(0xFF050913) : const Color(0xFFF2F6FC);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -60,
            child: _GlowOrb(
              size: 230,
              color: (isDark ? AppTheme.cyan : AppTheme.electricBlue).withOpacity(0.16),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -80,
            child: _GlowOrb(
              size: 250,
              color: (isDark ? AppTheme.electricBlue : AppTheme.cyan).withOpacity(0.14),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: ResponsiveLayout.contentMaxWidth(context)),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: math.pi / 5,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color, blurRadius: 64, spreadRadius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF121D33).withOpacity(0.88) : Colors.white.withOpacity(0.9),
        border: Border.all(
          color: borderColor ?? (isDark ? const Color(0xFF2A3857) : const Color(0xFFD8E4F6)),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF9EB6D8)).withOpacity(0.2),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeading({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700);
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: subtitleStyle),
        ],
      ],
    );
  }
}

class RiskBadge extends StatelessWidget {
  final RiskLevel risk;

  const RiskBadge({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: risk.color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: risk.color.withOpacity(0.55)),
      ),
      child: Text(
        risk.displayName,
        style: TextStyle(color: risk.color, fontWeight: FontWeight.w800, letterSpacing: 0.4),
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const MetricTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800);
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: titleStyle),
                Text(label, style: labelStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStatePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppTheme.success),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}
