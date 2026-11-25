import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../progress/providers/progress_provider.dart';
import '../models/learning_node.dart';
import 'node_sheet.dart';
import 'path_node.dart';

const Color _connectorColor = Color(0xFFD5D3E0); // garis abu penghubung node
const double _connectorWidth = 8;
const double _rowHeight = 124; // tinggi satu baris node
const double _circleTop = 8; // jarak atas baris ke lingkaran
const double _zigzag = 0.6; // seberapa jauh node bergeser kiri-kanan (0..1)

class LearningPath extends ConsumerWidget {
  const LearningPath({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(progressProvider).value?.completed ?? const {};
    final units = buildUnits(completed);

    final children = <Widget>[];
    var startIndex = 0;

    for (final unit in units) {
      children.add(_UnitBanner(unit: unit));
      children.add(const SizedBox(height: 12));
      children.add(
        _UnitPath(
          lessons: unit.lessons,
          startIndex: startIndex,
          onNodeTap: (node) => showNodeSheet(context, ref, node),
        ),
      );
      children.add(const SizedBox(height: 24));
      startIndex += unit.lessons.length;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: children,
    );
  }
}

/// Node-node satu unit + garis penghubungnya.
/// Posisi dihitung manual supaya garis tepat menyambung pusat lingkaran.
  const _UnitPath({
    required this.lessons,
    required this.startIndex,
    required this.onNodeTap,
  });

  final List<LessonNode> lessons;
  final int startIndex; // supaya pola zig-zag nyambung antar unit
  final ValueChanged<LessonNode> onNodeTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // pusat tiap lingkaran
        final centers = <Offset>[];
        for (var i = 0; i < lessons.length; i++) {
          final x = math.sin((startIndex + i) * math.pi / 2) * _zigzag;
          final cx = width / 2 + x * (width - PathNode.width) / 2;
          final cy = i * _rowHeight + _circleTop + PathNode.circleSize / 2;
          centers.add(Offset(cx, cy));
        }

        return SizedBox(
          width: width,
          height: lessons.length * _rowHeight,
          child: Stack(
            children: [
              // garis di lapisan paling bawah
              Positioned.fill(
                child: CustomPaint(painter: _ConnectorPainter(centers)),
              ),
              ...List.generate(lessons.length, (i) {
                final node = lessons[i];
                return Positioned(
                  left: centers[i].dx - PathNode.width / 2,
                  top: centers[i].dy - PathNode.circleSize / 2,
                  width: PathNode.width,
                  child: PathNode(
                    node: node,
                    onTap: () => onNodeTap(node),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter(this.centers);

  final List<Offset> centers;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _connectorColor
      ..strokeWidth = _connectorWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < centers.length - 1; i++) {
      canvas.drawLine(centers[i], centers[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) =>
      oldDelegate.centers != centers;
}

class _UnitBanner extends StatelessWidget {
  const _UnitBanner({required this.unit});

  final Unit unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unit.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit.description,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Reaksi saat node diketuk: pesan kalau terkunci,
/// panel START / PRACTICE kalau aktif atau sudah selesai.
void _showNodeSheet(BuildContext context, LessonNode node) {
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
                    content: Text('Lessons are not built yet (coming soon).'),
                  ),
                );
            },
          ),
        ],
      ),
    ),
  );
}
