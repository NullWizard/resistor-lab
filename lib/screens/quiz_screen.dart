import 'package:flutter/material.dart';

/// Clean model representing a quiz question with exactly 4 options.
class QuizQuestion {
  final String topic;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const QuizQuestion({
    required this.topic,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

/// Fully functional 10-Question Multiple Choice Quiz screen for Basic Electronics Lab.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // 10 Comprehensive Questions covering all required topics
  static const List<QuizQuestion> _questions = [
    // 1. Definition of resistance
    QuizQuestion(
      topic: 'Definition of Resistance',
      question:
          'What is the fundamental physical function of electrical resistance in a circuit?',
      options: [
        'To store electrical charge in an electrostatic field',
        'To oppose and regulate the flow of electric current',
        'To convert alternating current (AC) directly into direct current (DC)',
        'To generate magnetic flux without any energy dissipation',
      ],
      correctOptionIndex: 1,
      explanation:
          'Resistance is the opposition that a substance offers to the flow of electric current, creating a voltage drop and regulating current levels.',
    ),

    // 2. Unit of resistance
    QuizQuestion(
      topic: 'Unit of Resistance',
      question:
          'What is the standard International System of Units (SI) unit of electrical resistance?',
      options: [
        'Farad (F)',
        'Henry (H)',
        'Ohm (Ω)',
        'Watt (W)',
      ],
      correctOptionIndex: 2,
      explanation:
          'The SI unit of electrical resistance is the Ohm (symbol: Ω), named in honor of German physicist Georg Simon Ohm.',
    ),

    // 3. Ohm's Law
    QuizQuestion(
      topic: "Ohm's Law",
      question:
          'According to Ohm\'s Law, what current (I) flows through a 100 Ω resistor when a potential difference of 5 V is applied?',
      options: [
        '50 mA (0.05 A)',
        '500 mA (0.5 A)',
        '20 mA (0.02 A)',
        '5 A',
      ],
      correctOptionIndex: 0,
      explanation:
          'Using I = V / R = 5 V / 100 Ω = 0.05 A = 50 milliamperes (mA).',
    ),

    // 4. Resistor color codes
    QuizQuestion(
      topic: 'Resistor Color Codes',
      question:
          'In the standard electronic color code mnemonic (BBROYGBVGW), which numerical digit does the Yellow band represent?',
      options: [
        'Digit 2',
        'Digit 3',
        'Digit 4',
        'Digit 5',
      ],
      correctOptionIndex: 2,
      explanation:
          'Black=0, Brown=1, Red=2, Orange=3, Yellow=4, Green=5, Blue=6, Violet=7, Grey=8, White=9.',
    ),

    // 5. Four-band resistor calculation
    QuizQuestion(
      topic: 'Four-Band Resistor Calculation',
      question:
          'A 4-band resistor has the color sequence Brown, Black, Red, Gold. What is its nominal resistance and tolerance?',
      options: [
        '100 Ω ±5%',
        '1,000 Ω (1 kΩ) ±5%',
        '10,000 Ω (10 kΩ) ±10%',
        '1,200 Ω (1.2 kΩ) ±2%',
      ],
      correctOptionIndex: 1,
      explanation:
          'Brown (1), Black (0), Red (×100) = 10 × 100 = 1,000 Ω (1 kΩ). Gold represents ±5% tolerance.',
    ),

    // 6. Tolerance
    QuizQuestion(
      topic: 'Tolerance',
      question:
          'What is the acceptable range of measured resistance for a 1 kΩ (1,000 Ω) resistor with a ±5% Gold tolerance band?',
      options: [
        '900 Ω to 1,100 Ω',
        '950 Ω to 1,050 Ω',
        '980 Ω to 1,020 Ω',
        '990 Ω to 1,010 Ω',
      ],
      correctOptionIndex: 1,
      explanation:
          '5% of 1,000 Ω is 50 Ω. The minimum acceptable value is 1,000 - 50 = 950 Ω, and maximum is 1,000 + 50 = 1,050 Ω.',
    ),

    // 7. Measuring resistance with a multimeter
    QuizQuestion(
      topic: 'Measuring with a Multimeter',
      question:
          'When preparing to measure the resistance of a component using a digital multimeter (DMM), which laboratory safety procedure is essential?',
      options: [
        'Keep the circuit power switched ON so active current can be sensed',
        'Disconnect the resistor completely from any powered circuit or live voltage',
        'Warm the test probes with a soldering iron before making contact',
        'Connect the multimeter leads in parallel across the AC mains supply',
      ],
      correctOptionIndex: 1,
      explanation:
          'Always isolate the resistor from any power source. Measuring powered circuits causes erroneous readings through parallel paths and can blow the multimeter internal fuse.',
    ),

    // 8. Power rating
    QuizQuestion(
      topic: 'Power Rating',
      question:
          'How much power is dissipated by a 100 Ω resistor when an electric current of 0.1 A flows through it?',
      options: [
        '0.1 W',
        '0.5 W',
        '1.0 W',
        '10.0 W',
      ],
      correctOptionIndex: 2,
      explanation:
          'Using Joule\'s heating formula: P = I² × R = (0.1 A)² × 100 Ω = 0.01 × 100 = 1.0 Watt.',
    ),

    // 9. Fixed vs variable resistors
    QuizQuestion(
      topic: 'Fixed vs Variable Resistors',
      question:
          'Which component is a three-terminal variable resistor primarily wired as an adjustable voltage divider?',
      options: [
        'Wirewound ceramic resistor',
        'Carbon film fixed resistor',
        'Potentiometer',
        'Metal oxide varistor',
      ],
      correctOptionIndex: 2,
      explanation:
          'A potentiometer features three terminals with an internal movable wiper contact that taps off an adjustable fraction of input voltage.',
    ),

    // 10. LDR / Thermistor applications
    QuizQuestion(
      topic: 'Special-Purpose Resistor Applications',
      question:
          'How does the electrical resistance of a standard Light Dependent Resistor (LDR) change as light intensity increases?',
      options: [
        'Its resistance decreases significantly',
        'Its resistance increases significantly',
        'Its resistance remains strictly constant regardless of illumination',
        'Its resistance immediately reverses polarity',
      ],
      correctOptionIndex: 0,
      explanation:
          'Photons striking the Cadmium Sulfide (CdS) semiconductor liberate extra charge carriers into the conduction band, significantly dropping its resistance.',
    ),
  ];

  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  int _score = 0;
  bool _isQuizCompleted = false;

  void _onOptionSelected(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _onNextPressed() {
    if (_selectedOptionIndex == null) return;

    // Tally score
    if (_selectedOptionIndex ==
        _questions[_currentQuestionIndex].correctOptionIndex) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
      });
    } else {
      setState(() {
        _isQuizCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _score = 0;
      _isQuizCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resistor Quiz'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: _isQuizCompleted ? _buildResultsView() : _buildQuizView(),
          ),
        ),
      ),
    );
  }

  /// Active Question View
  Widget _buildQuizView() {
    final question = _questions[_currentQuestionIndex];
    final totalQuestions = _questions.length;
    final progress = (_currentQuestionIndex + 1) / totalQuestions;
    final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress & Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                  color: Color(0xFFF8FAFC),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF101726),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Text(
                  question.topic,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Linear Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
            ),
          ),
          const SizedBox(height: 20),

          // Question Card
          Card(
            elevation: 0,
            color: const Color(0xFF101726),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF1E293B), width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                question.question,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF8FAFC),
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Four Selectable Answer Options
          ...List.generate(question.options.length, (index) {
            final optionText = question.options[index];
            final isSelected = _selectedOptionIndex == index;
            final letter = String.fromCharCode(65 + index); // A, B, C, D

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => _onOptionSelected(index),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.12)
                        : const Color(0xFF101726),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00E5FF)
                          : const Color(0xFF1E293B),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isSelected
                            ? const Color(0xFF00E5FF)
                            : const Color(0xFF1E293B),
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF080D1A)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFFCBD5E1),
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF00E5FF),
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),

          // Next / Submit Button
          ElevatedButton(
            onPressed: _selectedOptionIndex != null ? _onNextPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: const Color(0xFF080D1A),
              disabledBackgroundColor: const Color(0xFF1E293B),
              disabledForegroundColor: const Color(0xFF64748B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastQuestion ? 'Submit & View Results' : 'Next Question',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isLastQuestion
                      ? Icons.emoji_events_rounded
                      : Icons.arrow_forward_rounded,
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Results Screen View
  Widget _buildResultsView() {
    final total = _questions.length;
    final percentage = ((_score / total) * 100).round();

    // Performance Feedback based on score
    String performanceMessage;
    Color badgeColor;
    IconData resultIcon;

    if (percentage >= 80) {
      performanceMessage =
          'Great score! You have a solid grasp of resistor basics and color codes.';
      badgeColor = const Color(0xFF10B981);
      resultIcon = Icons.stars_rounded;
    } else if (percentage >= 50) {
      performanceMessage =
          'Good work! Review resistor tolerance and color codes once more.';
      badgeColor = const Color(0xFFF59E0B);
      resultIcon = Icons.thumb_up_rounded;
    } else {
      performanceMessage =
          'Keep practicing! Go through the notes and try the quiz again.';
      badgeColor = const Color(0xFFEF4444);
      resultIcon = Icons.refresh_rounded;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Results Card
          Card(
            elevation: 0,
            color: const Color(0xFF101726),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF1E293B), width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(resultIcon, color: badgeColor, size: 36),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Quiz Complete!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Score & Percentage Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF080D1A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Score',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_score / $total',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF8FAFC),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: const Color(0xFF1E293B),
                        ),
                        Column(
                          children: [
                            const Text(
                              'Percentage',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Performance message
                  Text(
                    performanceMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFFCBD5E1),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Restart Quiz Button
          ElevatedButton.icon(
            onPressed: _restartQuiz,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Restart Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: const Color(0xFF080D1A),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Return Home Button
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Return Home'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF8FAFC),
              side: const BorderSide(color: Color(0xFF334155), width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
