
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/prime.button.dart';
import '../../progress/data/progress_repository.dart';
import '../../progress/providers/progress_provider.dart';
import '../data/lesson_service.dart';
import '../providers/lesson_provider.dart';

const int _xpPerCorrect = 10;
const Color _successEdge = Color(0xFF1F9E92);
const Color _errorEdge = Color(0xFFD94448);

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _index = 0;

  String? _selected;
  bool _checked = false;
  bool _busy = false;
  bool _finished = false;

  int _correct = 0;
  int _xpGained = 0;
  int _total = 0;

  final TextEditingController _answerController =
      TextEditingController();

  // State untuk soal matching
  int? _selectedLeft;
  QuizQuestion? _matchingQuestion;
  List<int> _rightOrder = [];

  void _prepareMatching(QuizQuestion question) {
    if (identical(_matchingQuestion, question)) return;
    _matchingQuestion = question;
    _rightOrder = List<int>.generate(question.pairs.length, (i) => i)
      ..shuffle();
    if (_rightOrder.length > 1 &&
        _rightOrder.asMap().entries.every((e) => e.key == e.value)) {
      _rightOrder.add(_rightOrder.removeAt(0));
    }
  }
  final Set<int> _matchedLeft = {};
  final Set<int> _matchedRight = {};

  void _exit() {
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _confirmExit() async {
    final quit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quit lesson?'),
        content: const Text(
          'You will lose your progress in this lesson.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('KEEP LEARNING'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text(
              'QUIT',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (quit == true && mounted) {
      _exit();
    }
  }

  Future<void> _showOutOfHearts() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Out of hearts!'),
        content: Text(
          'You get 1 heart back every '
          '${kHeartRegenInterval.inMinutes} minutes. '
          'Come back soon!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (mounted) {
      _exit();
    }
  }

  // Memeriksa jawaban multiple choice dan type answer
  Future<void> _check(QuizQuestion question) async {
    if (_checked || _busy) return;

    final answer = _selected;

    if (answer == null || answer.trim().isEmpty) {
      return;
    }

    final bool isCorrect =
        question.type == QuestionType.typeAnswer
            ? question.check(answer)
            : answer == question.correct;

    setState(() {
      _checked = true;

      if (isCorrect) {
        _correct++;
      }
    });

    if (!isCorrect) {
      final hearts = await ref
          .read(progressProvider.notifier)
          .loseHeart();

      if (!mounted) return;

      if (hearts <= 0) {
        await _showOutOfHearts();
      }
    }
  }

  // Memilih kata sebelah kiri pada soal matching
  void _selectLeft(int index, QuizQuestion question) {
    if (_checked || _busy || _matchedLeft.contains(index)) return;

    setState(() {
      _selectedLeft = index;
    });
  }

  // Memilih pasangan kata sebelah kanan
  Future<void> _selectRight(
    int index,
    QuizQuestion question,
  ) async {
    if (_checked || _busy ||
        _selectedLeft == null ||
        _matchedRight.contains(index)) {
      return;
    }

    final leftIndex = _selectedLeft!;
    final correctPair = leftIndex == _rightOrder[index];

    if (correctPair) {
      setState(() {
        _matchedLeft.add(leftIndex);
        _matchedRight.add(index);
        _selectedLeft = null;

        // Semua pasangan berhasil dicocokkan
        if (_matchedLeft.length == question.pairs.length) {
          _checked = true;
          _correct++;
        }
      });
    } else {
      setState(() {
        _selectedLeft = null;
        _busy = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect pair. Try again!'),
          duration: Duration(seconds: 1),
        ),
      );

      final hearts = await ref
          .read(progressProvider.notifier)
          .loseHeart();

      if (!mounted) return;

      if (hearts <= 0) {
        await _showOutOfHearts();
      } else {
        setState(() => _busy = false);
      }
    }
  }

  // Melanjutkan ke soal berikutnya
  Future<void> _next(List<QuizQuestion> questions) async {
    if (_busy) return;

    if (_index < questions.length - 1) {
      setState(() {
        _index++;

        _selected = null;
        _checked = false;

        _answerController.clear();

        _selectedLeft = null;
        _matchedLeft.clear();
        _matchedRight.clear();
        _matchingQuestion = null;
        _rightOrder = [];
      });

      return;
    }

    setState(() {
      _busy = true;
    });

    final xp = _correct * _xpPerCorrect;

    await ref
        .read(progressProvider.notifier)
        .completeLesson(
          lessonId: widget.lessonId,
          xpGained: xp,
          score: _correct,
        );

    if (!mounted) return;

    setState(() {
      _busy = false;
      _finished = true;
      _xpGained = xp;
      _total = questions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(
      lessonQuizProvider(widget.lessonId),
    );

    return PopScope(
      canPop: _finished,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmExit();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: quiz.when(
            loading: () => const _LoadingView(),

            error: (error, stack) => _MessageView(
              message: 'Could not load this lesson.',
              onBack: _exit,
            ),

            data: (questions) {
              if (questions.isEmpty) {
                return _MessageView(
                  message: 'This lesson has no questions yet.',
                  onBack: _exit,
                );
              }

              if (_finished) {
                return _ResultView(
                  xp: _xpGained,
                  correct: _correct,
                  total: _total,
                  onContinue: _exit,
                );
              }

              return _buildQuestion(questions);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(List<QuizQuestion> questions) {
    final question = questions[_index];

    final hearts =
        ref.watch(progressProvider).value?.hearts ?? 0;

    final isCorrect = question.type == QuestionType.typeAnswer
        ? (_selected != null && question.check(_selected!))
        : question.type == QuestionType.multipleChoice
            ? _selected == question.correct
            : _checked;

    final progress =
        (_index + (_checked ? 1 : 0)) / questions.length;

    return Column(
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 28,
                ),
                color: AppColors.textSecondary,
                onPressed: _confirmExit,
              ),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 14,
                    backgroundColor: AppColors.border,
                    color: AppColors.success,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              const Icon(
                Icons.favorite,
                color: AppColors.error,
                size: 26,
              ),

              const SizedBox(width: 4),

              Text(
                '$hearts',
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        // QUESTION CONTENT
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              16,
            ),
            children: [
              Text(
                question.instruction,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              if (question.prompt.isNotEmpty)
                Text(
                  question.prompt,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),

              const SizedBox(height: 28),

              // =====================================
              // 1. TYPE ANSWER
              // =====================================
              if (question.type == QuestionType.typeAnswer)
                _buildTypeAnswer(question),

              // =====================================
              // 2. MULTIPLE CHOICE
              // =====================================
              if (question.type == QuestionType.multipleChoice)
                _buildMultipleChoice(question),

              // =====================================
              // 3. MATCH PAIRS
              // =====================================
              if (question.type == QuestionType.matchPairs)
                _buildMatchPairs(question),
            ],
          ),
        ),

        // FEEDBACK
        if (_checked)
          _FeedbackBanner(
            correct: isCorrect,
            answer: question.correct,
          ),

        // BOTTOM BUTTON
        Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24,
          ),
          child: _checked
              ? PrimeButton(
                  label: _index == questions.length - 1
                      ? 'FINISH'
                      : 'CONTINUE',
                  color: isCorrect
                      ? AppColors.success
                      : AppColors.error,
                  edgeColor: isCorrect
                      ? _successEdge
                      : _errorEdge,
                  onPressed: _busy
                      ? null
                      : () => _next(questions),
                )
              : PrimeButton(
                  label: question.type == QuestionType.matchPairs
                      ? 'MATCH ALL PAIRS'
                      : 'CHECK',
                  onPressed: question.type == QuestionType.matchPairs
                      ? null
                      : (_selected == null ||
                              _selected!.trim().isEmpty)
                          ? null
                          : () => _check(question),
                ),
        ),
      ],
    );
  }

  // =========================================
  // TYPE ANSWER WIDGET
  // =========================================

  Widget _buildTypeAnswer(QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _answerController,
          enabled: !_checked,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            setState(() {
              _selected = value;
            });
          },
          onSubmitted: (_) {
            if (_selected != null &&
                _selected!.trim().isNotEmpty &&
                !_checked) {
              _check(question);
            }
          },
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.border,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.border,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================
  // MULTIPLE CHOICE WIDGET
  // =========================================

  Widget _buildMultipleChoice(QuizQuestion question) {
    return Column(
      children: [
        for (final option in question.options) ...[
          _OptionTile(
            text: option,
            selected: _selected == option,
            checked: _checked,
            isCorrectOption: option == question.correct,
            onTap: _checked
                ? null
                : () {
                    setState(() {
                      _selected = option;
                    });
                  },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  // =========================================
  // MATCH PAIRS WIDGET
  // =========================================

  Widget _buildMatchPairs(QuizQuestion question) {
    _prepareMatching(question);
    return Column(
      children: [
        const Text(
          'Select two words that have the same meaning.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < question.pairs.length; i++) ...[
                    _MatchTile(
                      text: question.pairs[i].left,
                      selected: _selectedLeft == i,
                      matched: _matchedLeft.contains(i),
                      onTap: () {
                        _selectLeft(i, question);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < question.pairs.length; i++) ...[
                    _MatchTile(
                      text: question.pairs[_rightOrder[i]].right,
                      selected: false,
                      matched: _matchedRight.contains(i),
                      onTap: () {
                        _selectRight(i, question);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          '${_matchedLeft.length}/${question.pairs.length} pairs matched',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// =============================================
// MATCH TILE
// =============================================

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.text,
    required this.selected,
    required this.matched,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.border;
    Color fill = AppColors.surface;

    if (matched) {
      border = AppColors.success;
      fill = AppColors.success.withValues(alpha: 0.12);
    } else if (selected) {
      border = AppColors.primary;
      fill = AppColors.primary.withValues(alpha: 0.10);
    }

    return GestureDetector(
      onTap: matched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 65,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: border,
            width: 2,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: matched
                ? AppColors.success
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// =============================================
// OPTION TILE
// =============================================

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.selected,
    required this.checked,
    required this.isCorrectOption,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool checked;
  final bool isCorrectOption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.border;
    Color fill = AppColors.surface;

    if (checked) {
      if (isCorrectOption) {
        border = AppColors.success;
        fill = AppColors.success.withValues(alpha: 0.12);
      } else if (selected) {
        border = AppColors.error;
        fill = AppColors.error.withValues(alpha: 0.12);
      }
    } else if (selected) {
      border = AppColors.primary;
      fill = AppColors.primary.withValues(alpha: 0.08);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: border,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// =============================================
// FEEDBACK BANNER
// =============================================

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.correct,
    required this.answer,
  });

  final bool correct;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final color = correct
        ? AppColors.success
        : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        14,
        24,
        14,
      ),
      color: color.withValues(alpha: 0.12),
      child: Row(
        children: [
          Icon(
            correct
                ? Icons.check_circle
                : Icons.cancel,
            color: color,
            size: 28,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct ? 'Correct!' : 'Not quite',
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                if (!correct)
                  Text(
                    'Correct answer: $answer',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================
// LOADING VIEW
// =============================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Preparing your lesson...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================
// MESSAGE VIEW
// =============================================

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.message,
    required this.onBack,
  });

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 24),

          PrimeButton(
            label: 'BACK',
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}

// =============================================
// RESULT VIEW
// =============================================

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.xp,
    required this.correct,
    required this.total,
    required this.onContinue,
  });

  final int xp;
  final int correct;
  final int total;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          const Icon(
            Icons.emoji_events_rounded,
            size: 110,
            color: AppColors.accent,
          ),

          const SizedBox(height: 16),

          const Text(
            'Lesson complete!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ResultStat(
                icon: Icons.bolt,
                color: AppColors.accentDark,
                label: '+$xp XP',
              ),

              const SizedBox(width: 16),

              _ResultStat(
                icon: Icons.check_circle,
                color: AppColors.success,
                label: '$correct/$total correct',
              ),
            ],
          ),

          const Spacer(),

          PrimeButton(
            label: 'CONTINUE',
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

// =============================================
// RESULT STAT
// =============================================

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),

          const SizedBox(width: 6),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
