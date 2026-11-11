/// Represents a subject or category with OpenTDB mapping or offline support.
class SubjectCategory {
  final String name;
  final int? categoryId; // Open Trivia DB category ID
  final String icon;
  final String description;
  final bool isCustomOrFile;
  final String? assetPath;

  const SubjectCategory({
    required this.name,
    this.categoryId,
    required this.icon,
    required this.description,
    this.isCustomOrFile = false,
    this.assetPath,
  });

  static const List<SubjectCategory> defaultSubjects = [
    SubjectCategory(
      name: 'Flutter & Dart Mobile Dev',
      icon: '📱',
      description: 'Widgets, State Management, BuildContext & Async',
      isCustomOrFile: true,
      assetPath: 'assets/questions/flutter_lab.json',
    ),
    SubjectCategory(
      name: 'Computer Science & OS',
      icon: '💻',
      description: 'OS, Networks, DBMS, Data Structures & SQL',
      isCustomOrFile: true,
      assetPath: 'assets/questions/computer_science.json',
    ),
    SubjectCategory(
      name: 'Science: Computers & IT',
      categoryId: 18,
      icon: '🖥️',
      description: 'Hardware, software, protocols, and modern computing',
    ),
    SubjectCategory(
      name: 'Science: Mathematics',
      categoryId: 19,
      icon: '📐',
      description: 'Algebra, geometry, calculus, and mathematical logic',
    ),
    SubjectCategory(
      name: 'General Knowledge',
      categoryId: 9,
      icon: '🌍',
      description: 'World facts, famous discoveries, and trivia',
    ),
    SubjectCategory(
      name: 'Science & Nature',
      categoryId: 17,
      icon: '🔬',
      description: 'Physics, chemistry, biology, and astronomy',
    ),
    SubjectCategory(
      name: 'Science: Gadgets & Tech',
      categoryId: 30,
      icon: '⚡',
      description: 'Mobile tech, consumer gadgets, and inventions',
    ),
    SubjectCategory(
      name: 'History & Milestones',
      categoryId: 23,
      icon: '📜',
      description: 'Historical events, civilizations, and revolutions',
    ),
    SubjectCategory(
      name: 'Geography & Nations',
      categoryId: 22,
      icon: '🗺️',
      description: 'Countries, capitals, flags, mountains, and oceans',
    ),
    SubjectCategory(
      name: 'Sports & Olympics',
      categoryId: 21,
      icon: '⚽',
      description: 'Athletics, tournaments, world cups, and records',
    ),
  ];
}
