import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/quiz_config.dart';
import '../services/custom_quiz_parser.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/neobank_card.dart';
import '../widgets/pill_button.dart';
import 'quiz_screen.dart';

class FileSubjectsScreen extends StatefulWidget {
  const FileSubjectsScreen({super.key});

  @override
  State<FileSubjectsScreen> createState() => _FileSubjectsScreenState();
}

class _FileSubjectsScreenState extends State<FileSubjectsScreen> {
  Map<String, String> _customFiles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    final files = await LocalStorageService.getCustomSubjects();
    setState(() {
      _customFiles = files;
      _isLoading = false;
    });
  }

  Future<void> _pickFileFromDisk() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final content = await file.xFile.readAsString();
        final name = file.name.replaceAll('.json', '').replaceAll('.txt', '');
        _showConfirmImportDialog(name, content);
      }
    } catch (e) {
      // If native file picker encounters an issue, fallback to paste dialog
      _showPasteOrAddDialog();
    }
  }

  void _showPasteOrAddDialog() {
    final titleController = TextEditingController(text: 'My Custom Subject');
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add Subject File / Questions', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subject / File Name',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Operating Systems Unit 1',
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Paste JSON or Q&A Format',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                    ),
                    TextButton(
                      onPressed: () {
                        contentController.text = _sampleTemplate;
                      },
                      child: const Text('Insert Sample', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: contentController,
                  maxLines: 8,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Paste questions here...',
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          PillButton(
            label: 'Import',
            variant: PillButtonVariant.dark,
            onPressed: () {
              Navigator.pop(ctx);
              _processImport(titleController.text.trim(), contentController.text.trim());
            },
          ),
        ],
      ),
    );
  }

  void _showConfirmImportDialog(String suggestedName, String content) {
    final titleController = TextEditingController(text: suggestedName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirm File Import', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Subject Name for this file:'),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          PillButton(
            label: 'Save File',
            variant: PillButtonVariant.dark,
            onPressed: () {
              Navigator.pop(ctx);
              _processImport(titleController.text.trim(), content);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _processImport(String subjectName, String content) async {
    if (subjectName.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide both subject name and content')),
      );
      return;
    }

    final parsed = CustomQuizParser.parseContent(content, subjectName);
    if (parsed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid questions found! Please check JSON/Text format.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    await LocalStorageService.saveCustomSubject(subjectName, content);
    await _loadFiles();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Successfully loaded ${parsed.length} questions for "$subjectName"!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _launchQuizForFile(String subjectName, String content) {
    final parsed = CustomQuizParser.parseContent(content, subjectName);
    final config = QuizConfig(
      subjectName: subjectName,
      numberOfQuestions: parsed.length,
      timerSecondsPerQuestion: 15,
      source: 'file',
      customContent: content,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(config: config),
      ),
    );
  }

  static const String _sampleTemplate = '''[
  {
    "question": "What is the primary function of an Operating System?",
    "options": ["Manage hardware & software resources", "Compile source code", "Design UI graphics", "Host web servers"],
    "correctAnswer": "Manage hardware & software resources",
    "explanation": "OS manages processor, memory, and devices."
  },
  {
    "question": "Which protocol is used to securely browse the World Wide Web?",
    "options": ["HTTP", "HTTPS", "FTP", "SMTP"],
    "correctAnswer": "HTTPS",
    "explanation": "HTTPS encrypts HTTP traffic using TLS/SSL."
  }
]''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Files & Custom Quizzes'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Import Card
              NeobankCard(
                variant: CardVariant.lime,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '📁 Custom Quiz Vault',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'FILE IMPORT',
                            style: TextStyle(
                              color: AppTheme.limeAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload your course syllabus files (.json or text) to test yourself on subject-specific lab questions.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.3),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: PillButton(
                            label: 'Pick File',
                            icon: Icons.file_upload_outlined,
                            variant: PillButtonVariant.dark,
                            onPressed: _pickFileFromDisk,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PillButton(
                            label: 'Paste Text',
                            icon: Icons.paste_rounded,
                            variant: PillButtonVariant.outline,
                            onPressed: _showPasteOrAddDialog,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bundled Offline Subjects
              const Text(
                'Preloaded Lab Subject Files',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
              ),
              const SizedBox(height: 10),
              _buildPreloadedTile(
                title: 'Flutter Mobile App Development',
                desc: '10 Questions on Widgets, State, BuildContext, Lifecycle',
                assetPath: 'assets/questions/flutter_lab.json',
              ),
              const SizedBox(height: 8),
              _buildPreloadedTile(
                title: 'Computer Science & Operating Systems',
                desc: 'OS Scheduling, Deadlocks, SQL, Networking',
                assetPath: 'assets/questions/computer_science.json',
              ),
              const SizedBox(height: 24),

              // User Uploaded Files
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Imported Subject Files',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                  Text(
                    '${_customFiles.length} Saved',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_customFiles.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.folder_open_rounded, size: 40, color: AppTheme.textMuted),
                      SizedBox(height: 8),
                      Text(
                        'No custom files added yet.',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap "Pick File" or "Paste Text" above to import questions for any subject.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _customFiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final key = _customFiles.keys.elementAt(i);
                    final content = _customFiles[key]!;
                    final count = CustomQuizParser.parseContent(content, key).length;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.limeLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Text('📄', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  '$count Questions loaded',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                            onPressed: () async {
                              await LocalStorageService.deleteCustomSubject(key);
                              _loadFiles();
                            },
                          ),
                          PillButton(
                            label: 'Start',
                            variant: PillButtonVariant.dark,
                            height: 38,
                            onPressed: () => _launchQuizForFile(key, content),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreloadedTile({
    required String title,
    required String desc,
    required String assetPath,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text('📦', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          PillButton(
            label: 'Test',
            variant: PillButtonVariant.outline,
            height: 38,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    config: QuizConfig(
                      subjectName: title,
                      numberOfQuestions: 10,
                      timerSecondsPerQuestion: 15,
                      source: 'preloaded',
                      customFilePath: assetPath,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
