import 'package:uas_duolingo/feature/lesson/data/lesson_catalog.dart';

enum NodeStatus { locked, active, done }

class LessonNode {
  const LessonNode({
    required this.id,
    required this.title,
    required this.status,
  });

  final String id;
  final String title;
  final NodeStatus status;
}

class Unit {
  const Unit({
    required this.title,
    required this.description,
    required this.lessons,
  });

  final String title;
  final String description;
  final List<LessonNode> lessons;
}

// Bentuk daftar unit untuk UI dari katalog + lesson yang sudah selesai.
// Lesson selesai = done, lesson pertama yang belum selesai = active,
// sisanya = locked.
List<Unit> buildUnits(Set<String> completed) {
  var activeAssigned = false;
  final units = <Unit>[];

  for (final unitDef in courseCatalog) {
    final lessons = <LessonNode>[];
    for (final lessonDef in unitDef.lessons) {
      NodeStatus status;
      if (completed.contains(lessonDef.id)) {
        status = NodeStatus.done;
      } else if (!activeAssigned) {
        status = NodeStatus.active;
        activeAssigned = true;
      } else {
        status = NodeStatus.locked;
      }
      lessons.add(
        LessonNode(id: lessonDef.id, title: lessonDef.title, status: status),
      );
    }
    units.add(
      Unit(
        title: unitDef.title,
        description: unitDef.description,
        lessons: lessons,
      ),
    );
  }
  return units;
}
