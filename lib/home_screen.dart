import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String studentName;

  const HomeScreen({required this.studentName, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _assignmentController = TextEditingController();
  final TextEditingController _examController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double? _finalGrade;
  double? _requiredExamGrade;
  String? _resultMessage;
  String? _requiredGradeMessage;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _assignmentController.dispose();
    _examController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _calculateFinalGrade() {
    if (!_formKey.currentState!.validate()) return;

    final assignmentGrade = double.tryParse(_assignmentController.text);
    final examGrade = double.tryParse(_examController.text);
    if (assignmentGrade == null ||
        assignmentGrade < 40 ||
        assignmentGrade > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('علامة الوظيفة يجب أن تكون بين 40 و 100'),
          backgroundColor: Color.fromARGB(255, 114, 27, 20),
        ),
      );
      return;
    }
    final finalGrade = (assignmentGrade * 0.25) + (examGrade! * 0.75);

    setState(() {
      _finalGrade = finalGrade;
      _requiredExamGrade = null;
      _requiredGradeMessage = null;

      // Determine result message based on grade
      if (finalGrade >= 60) {
        _resultMessage = 'ناجح';
      } else if (finalGrade >= 58 && finalGrade < 60) {
        _resultMessage = 'ناجح بالمساعدة';
      } else {
        _resultMessage = 'راسب';
      }

      _animationController.forward(from: 0.0);
    });
  }

  void _calculateRequiredGrade() {
    // Only validate assignment grade, not exam grade
    if (_assignmentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال علامة الوظيفة'),
          backgroundColor: Color.fromARGB(255, 114, 27, 20),
        ),
      );
      return;
    }

    final assignmentGrade = double.tryParse(_assignmentController.text);
    if (assignmentGrade == null || assignmentGrade < 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "الحد الأدنى لعلامة الوظيفة هو 40  , أقل من ذلك لا تسطيع تقديم الامتحان",
          ),
          backgroundColor: Color.fromARGB(255, 114, 27, 20),
        ),
      );
      return;
    } else if (assignmentGrade > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('علامة الوظيفة يجب أن تكون بين 40 و 100'),
          backgroundColor: Color.fromARGB(255, 114, 27, 20),
        ),
      );
      return;
    }

    // Calculate required exam grade using 58 as the passing threshold
    final requiredExamGrade = (58 - (assignmentGrade * 0.25)) / 0.75;

    setState(() {
      _finalGrade = null;
      _resultMessage = null;

      if (requiredExamGrade > 100) {
        _requiredGradeMessage = 'لا يمكن النجاح حتى مع العلامة الكاملة';
        _requiredExamGrade = null;
      } else if (requiredExamGrade <= 0) {
        _requiredGradeMessage = 'أنت ناجح عملياً من علامة الوظيفة';
        _requiredExamGrade = null;
      } else {
        _requiredExamGrade = requiredExamGrade;
        _requiredGradeMessage = null;
      }
      _animationController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مرحباً ${widget.studentName}',
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.secondary.withOpacity(0.03),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildGradeCalculatorSection(context, isMobile),
                  SizedBox(height: isMobile ? 24.0 : 32.0),
                  if (_finalGrade != null ||
                      _requiredExamGrade != null ||
                      _requiredGradeMessage != null)
                    _buildResultSection(context, isMobile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeCalculatorSection(BuildContext context, bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header
          Text(
            'حاسبة النتيجة النهائية',
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أدخل علاماتك واحسب النتيجة النهائية',
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: isMobile ? 20.0 : 28.0),

          // Input Fields Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 20.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Assignment Grade Input
                  _buildGradeInputField(
                    context,
                    'علامة الوظيفة',
                    'أدخل علامة الوظيفة (40-100)',
                    _assignmentController,
                  ),
                  SizedBox(height: isMobile ? 16.0 : 20.0),

                  // Exam Grade Input
                  _buildGradeInputField(
                    context,
                    'علامة الامتحان',
                    'أدخل علامة الامتحان (0-100)',
                    _examController,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isMobile ? 20.0 : 28.0),

          // Buttons
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildActionButton(
                  context,
                  'احسب العلامة النهائية',
                  Icons.calculate_rounded,
                  Colors.blue,
                  _calculateFinalGrade,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  context,
                  'احسب علامة الامتحان اللازمة للنجاح',
                  Icons.trending_up_rounded,
                  Colors.green,
                  _calculateRequiredGrade,
                ),
              ],
            )
          else
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'احسب العلامة النهائية',
                    Icons.calculate_rounded,
                    Colors.blue,
                    _calculateFinalGrade,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'احسب علامة الامتحان اللازمة للنجاح',
                    Icons.trending_up_rounded,
                    Colors.green,
                    _calculateRequiredGrade,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGradeInputField(
    BuildContext context,
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            prefixIcon: const Icon(Icons.grade_rounded),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال العلامة';
            }
            final grade = double.tryParse(value);
            if (grade == null) {
              return 'الرجاء إدخال رقم صحيح';
            }
            if (grade < 0 || grade > 100) {
              return 'العلامة يجب أن تكون بين 0 و 100';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, textDirection: TextDirection.rtl),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  Widget _buildResultSection(BuildContext context, bool isMobile) {
    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            padding: EdgeInsets.all(isMobile ? 20.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(_getResultIcon(), size: 56, color: _getResultColor()),
                const SizedBox(height: 16),
                if (_finalGrade != null) ...[
                  Text(
                    'العلامة النهائية',
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _finalGrade!.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getResultColor(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Result badge with appropriate color
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _getResultColor(),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      _resultMessage!,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Assistance note
                  if (_resultMessage == 'ناجح بالمساعدة') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'تم النجاح باستخدام العلامات المساعدة',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ] else if (_requiredExamGrade != null) ...[
                  Text(
                    'علامة الامتحان المطلوبة',
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _requiredExamGrade!.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryFixedDim,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'تحتاج إلى ${(_requiredExamGrade! + 2).toStringAsFixed(2)} دون علامات المساعدة ',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.scrim,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      ' 58 أو 59 تعتبر ناجحاً بالمساعدة',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get the color based on the final grade
  Color _getResultColor() {
    if (_finalGrade == null) return Colors.grey;

    if (_finalGrade! >= 60) {
      return Colors.green;
    } else if (_finalGrade! >= 58) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Get the icon based on the result status
  IconData _getResultIcon() {
    if (_finalGrade == null) return Icons.info_rounded;

    if (_finalGrade! >= 60) {
      return Icons.check_circle_rounded;
    } else if (_finalGrade! >= 58) {
      return Icons.help_outline_rounded;
    } else {
      return Icons.cancel_rounded;
    }
  }
}

class _QuickAccessItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  _QuickAccessItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
