import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uas_duolingo/core/router/app_routes.dart';
import 'package:uas_duolingo/core/theme/app_colors.dart';
import 'package:uas_duolingo/core/widgets/prime.button.dart';
import 'package:uas_duolingo/feature/progress/data/progress_repository.dart';
import 'package:uas_duolingo/feature/progress/providers/progress_provider.dart';
import 'package:uas_duolingo/feature/home/models/learning_node.dart';

void _showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

Future<void> showNodeSheet(
  BuildContext context,
  WidgetRef ref,
  LessonNode node,
) async {
  if (node.status == NodeStatus.locked) {
    _showMessage(context, 'Finish the previous lesson first.');
    return;
  }

  // muat ulang dulu supaya HP yang sudah regenerasi ikut terhitung
  final progress = await ref.read(progressProvider.notifier).reload();
  if (!context.mounted) return;

  if (progress.hearts <= 0) {
    final remaining =
        kHeartRegenInterval -
        DateTime.now().difference(progress.heartsUpdatedAt);
    final minutes = max(1, remaining.inMinutes + 1);
    _showMessage(context, 'No hearts left. Next heart in about $minutes min.');
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
              if (context.mounted) {
                context.push(AppRoutes.lessonPath(node.id));
              }
            },
          ),
        ],
      ),
    ),
  );
}
