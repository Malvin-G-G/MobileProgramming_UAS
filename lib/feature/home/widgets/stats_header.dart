import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class StatsHeader extends StatelessWidget {
  const StatsHeader({
    super.key,
    required this.leading,
    required this.xp,
    required this.hearts,
    this.level = 1,
  });

  final Widget leading;
  final int xp;
  final int hearts;
  final int level;

class StatsHeader extends StatelessWidget {
  const StatsHeader({
    super.key,
    required this.leading,
    required this.xp,
    required this.hearts,
  });

  final Widget leading;
  final int xp;
  final int hearts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          leading,
          const Spacer(),
          _Stat(icon: Icons.bolt, color: AppColors.accentDark, value: xp),
          _LevelChip(level: level),
          const SizedBox(width: 16),
          const SizedBox(width: 16),
          _Stat(icon: Icons.favorite, color: AppColors.error, value: hearts),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.value});
  final IconData icon;
  final Color color;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'LV $level',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}