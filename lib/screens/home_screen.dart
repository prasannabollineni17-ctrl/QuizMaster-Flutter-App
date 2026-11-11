import 'package:flutter/material.dart';
import '../models/quiz_config.dart';
import '../models/subject_category.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/neobank_card.dart';
import '../widgets/pill_button.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(QuizConfig)? onStartQuiz;
  final VoidCallback? onNavigateToFiles;

  const HomeScreen({
    super.key,
    this.onStartQuiz,
    this.onNavigateToFiles,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _subjectController = TextEditingController();
  String _selectedSubjectName = 'Flutter & Dart Mobile Dev';
  int? _selectedCategoryId;
  String _selectedSource = 'preloaded';
  String? _selectedAssetPath = 'assets/questions/flutter_lab.json';
  String? _customContent;

  int _selectedQuestionCount = 10;
  int _selectedTimerSeconds = 15;
  String _selectedDifficulty = 'any';
  String _playerName = 'Student';

  final List<int> _questionCountOptions = [5, 10, 15, 20];
  final List<int> _timerOptions = [10, 15, 20, 30];
  final List<String> _difficultyOptions = ['any', 'easy', 'medium', 'hard'];

  List<SubjectCategory> _allSubjects = List.from(SubjectCategory.defaultSubjects);
  Map<String, String> _customSavedFiles = {};

  @override
  void initState() {
    super.initState();
    _subjectController.text = _selectedSubjectName;
    _loadCustomSubjectsAndUser();
  }

  Future<void> _loadCustomSubjectsAndUser() async {
    final name = await LocalStorageService.getPlayerName();
    final customFiles = await LocalStorageService.getCustomSubjects();
    setState(() {
      _playerName = name;
      _customSavedFiles = customFiles;
      // Add custom uploaded subjects into subject list
      final customCategories = customFiles.entries.map(
        (e) => SubjectCategory(
          name: e.key,
          icon: '📁',
          description: 'Custom file question set',
          isCustomOrFile: true,
        ),
      );
      _allSubjects = [
        ...SubjectCategory.defaultSubjects,
        ...customCategories,
      ];
    });
  }

  void _onSelectSubject(SubjectCategory cat) {
    setState(() {
      _selectedSubjectName = cat.name;
      _subjectController.text = cat.name;
      _selectedCategoryId = cat.categoryId;
      if (cat.assetPath != null) {
        _selectedSource = 'preloaded';
        _selectedAssetPath = cat.assetPath;
        _customContent = null;
      } else if (cat.isCustomOrFile && _customSavedFiles.containsKey(cat.name)) {
        _selectedSource = 'file';
        _customContent = _customSavedFiles[cat.name];
        _selectedAssetPath = null;
      } else {
        _selectedSource = 'api';
        _selectedAssetPath = null;
        _customContent = null;
      }
    });
  }

  void _launchQuiz() {
    final config = QuizConfig(
      subjectName: _selectedSubjectName,
      categoryId: _selectedCategoryId,
      numberOfQuestions: _selectedQuestionCount,
      timerSecondsPerQuestion: _selectedTimerSeconds,
      difficulty: _selectedDifficulty,
      source: _selectedSource,
      customFilePath: _selectedAssetPath,
      customContent: _customContent,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(config: config),
      ),
    ).then((_) => _loadCustomSubjectsAndUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile & Greeting Header (Matching Neobank UI)
              _buildHeader(),
              const SizedBox(height: 20),

              // Hero Lime-Green Card
              _buildHeroCard(),
              const SizedBox(height: 24),

              // Subject selection with auto-suggestions
              _buildSubjectSelectorSection(),
              const SizedBox(height: 24),

              // Number of Questions Selector
              _buildQuestionCountSelector(),
              const SizedBox(height: 24),

              // Timer Per Question Selector
              _buildTimerSelector(),
              const SizedBox(height: 24),

              // Difficulty Selector
              _buildDifficultySelector(),
              const SizedBox(height: 32),

              // Launch Button
              PillButton(
                label: 'Start Quiz Now',
                icon: Icons.play_arrow_rounded,
                variant: PillButtonVariant.dark,
                height: 56,
                isExpanded: true,
                onPressed: _launchQuiz,
              ),
              const SizedBox(height: 16),

              // Custom File import shortcut
              Center(
                child: TextButton.icon(
                  onPressed: widget.onNavigateToFiles,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text(
                    'Add Questions from File / Custom Subject',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, $_playerName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Ready for your Lab Exam',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        // Avatar matching reference design
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.limeAccent, width: 2),
          ),
          alignment: Alignment.center,
          child: const Text(
            '🎓',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return NeobankCard(
      variant: CardVariant.lime,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: AppTheme.limeAccent),
                    const SizedBox(width: 4),
                    Text(
                      _selectedSource == 'api'
                          ? 'OPEN TRIVIA API'
                          : (_selectedSource == 'file' ? 'CUSTOM FILE' : 'LAB ASSET'),
                      style: const TextStyle(
                        color: AppTheme.limeAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: AppTheme.textDark),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Target Subject',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedSubjectName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppTheme.limeAccent),
                    const SizedBox(width: 6),
                    Text(
                      '${_selectedTimerSeconds}s / question',
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$_selectedQuestionCount Questions',
                  style: const TextStyle(
                    color: AppTheme.limeAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelectorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select or Enter Subject',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              '${_allSubjects.length} Available',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Autocomplete search input with suggestions
        Autocomplete<SubjectCategory>(
          displayStringForOption: (cat) => cat.name,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return _allSubjects.take(6);
            }
            return _allSubjects.where((cat) {
              return cat.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (cat) => _onSelectSubject(cat),
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Type subject (e.g. Flutter, Computers, History)...',
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.surfaceWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.surfaceDark, width: 1.5),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _selectedSubjectName = val.isEmpty ? 'General Knowledge' : val;
                });
              },
            );
          },
        ),

        const SizedBox(height: 12),
        // Horizontal scrollable quick chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _allSubjects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = _allSubjects[i];
              final isSelected = cat.name == _selectedSubjectName;
              return InkWell(
                onTap: () => _onSelectSubject(cat),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.surfaceDark : AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.surfaceDark : AppTheme.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppTheme.textLight : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Number of Questions',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _questionCountOptions.map((count) {
            final isSelected = _selectedQuestionCount == count;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedQuestionCount = count),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.limeAccent : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.limeAccentDark : AppTheme.borderLight,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? AppTheme.textDark : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Timer Per Question',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              '$_selectedTimerSeconds Seconds',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: _timerOptions.map((seconds) {
            final isSelected = _selectedTimerSeconds == seconds;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedTimerSeconds = seconds),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.surfaceDark : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.surfaceDark : AppTheme.borderLight,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Text(
                      '${seconds}s',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? AppTheme.limeAccent : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty Level',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _difficultyOptions.map((diff) {
            final isSelected = _selectedDifficulty == diff;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedDifficulty = diff),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.surfaceDark : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.surfaceDark : AppTheme.borderLight,
                      ),
                    ),
                    child: Text(
                      diff.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? AppTheme.limeAccent : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
