import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/learning_node.dart';

class PathNode extends StatefulWidget {
  const PathNode({super.key, required this.node, required this.onTap});

  static const double width = 120;
  static const double circleSize = 72;

  final LessonNode node;
  final VoidCallback onTap;

  @override
  State<PathNode> createState() => _PathNodeState();
}

class _PathNodeState extends State<PathNode> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;

    Color face;
    Color edge;
    Color iconColor;
    IconData icon;

    if (node.status == NodeStatus.done) {
      face = AppColors.accent;
      edge = AppColors.accentDark;
      iconColor = AppColors.primaryDark;
      icon = Icons.check_rounded;
    } else if (node.status == NodeStatus.active) {
      face = AppColors.primary;
      edge = AppColors.primaryDark;
      iconColor = Colors.white;
      icon = Icons.play_arrow_rounded;
    } else {
      face = AppColors.disabled;
      edge = AppColors.disabledEdge;
      iconColor = AppColors.textSecondary;
      icon = Icons.lock_rounded;
    }

    final locked = node.status == NodeStatus.locked;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: SizedBox(
        width: PathNode.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: PathNode.circleSize,
              height: PathNode.circleSize,
              transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
              decoration: BoxDecoration(
                color: face,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: edge, offset: Offset(0, _pressed ? 2 : 6)),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              node.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: locked ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}