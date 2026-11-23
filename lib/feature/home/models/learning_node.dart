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

// temp, change later
const List<Unit> dummyUnits = [
  Unit(
    title: 'Unit 1',
    description: 'Greetings and introductions',
    lessons: [
      LessonNode(id: '1-1', title: 'Hello', status: NodeStatus.done),
      LessonNode(id: '1-2', title: 'Introductions', status: NodeStatus.done),
      LessonNode(id: '1-3', title: 'Basic numbers', status: NodeStatus.active),
      LessonNode(id: '1-4', title: 'Review', status: NodeStatus.locked),
    ],
  ),
  Unit(
    title: 'Unit 2',
    description: 'Food and drinks',
    lessons: [
      LessonNode(id: '2-1', title: 'Food', status: NodeStatus.locked),
      LessonNode(id: '2-2', title: 'Drinks', status: NodeStatus.locked),
      LessonNode(id: '2-3', title: 'At the restaurant', status: NodeStatus.locked),
      LessonNode(id: '2-4', title: 'Review', status: NodeStatus.locked),
    ],
  ),
];