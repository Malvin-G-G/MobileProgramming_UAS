import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/prime.button.dart';
import '../models/learning_node.dart';

void showNodeSheet(BuildContext context, LessonNode node) {
  if (node.status == NodeStatus.locked) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Finish the previous lesson first.')),
      );
    return;
  }

  final done = node.status == NodeStatus.done;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            node.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            done
                ? 'Already completed. Practice again?'
                : 'Ready to start this lesson?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          PrimeButton(
            label: done ? 'PRACTICE' : 'START',
            onPressed: () {
              Navigator.of(sheetContext).pop();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Lessons are not built yet (next feature).'),
                  ),
                );
            },
          ),
        ],
      ),
    ),
  );
}