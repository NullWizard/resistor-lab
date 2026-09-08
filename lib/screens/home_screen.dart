import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'learn_screen.dart';
import 'quiz_screen.dart';
import 'scan_resistor_screen.dart';
import 'types_screen.dart';

/// The Home Screen of Resistor Lab.
///
/// Serves as the main dashboard for the Basic Electronics Lab assignment,
/// featuring the Lab Objectives and five primary modules:
/// 1. Learn About Resistors
/// 2. Resistor Color Code
/// 3. Types of Resistors
/// 4. Quiz
/// 5. Scan Resistor
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.electric_bolt_rounded, color: Color(0xFFD97706)),
            SizedBox(width: 10),
            Text(
              'Resistor Lab',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Polished Header Section
                  _buildHeader(context),
                  const SizedBox(height: 20),

                  // 2. Lab Objectives Section
                  _buildLabObjectivesCard(context),
                  const SizedBox(height: 24),

                  // 3. Section Title for Modules
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lab Modules',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Responsive Four Module Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 680;

                      final card1 = _buildModuleCard(
                        context,
                        moduleNumber: 'Module 01',
                        title: 'Learn About Resistors',
                        description:
                            "Understand resistor fundamentals, Ohm's law, tolerance and measurement.",
                        icon: Icons.menu_book_rounded,
                        accentColor: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFEFF6FF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LearnScreen(),
                            ),
                          );
                        },
                      );

                      final card2 = _buildModuleCard(
                        context,
                        moduleNumber: 'Module 02',
                        title: 'Resistor Color Code',
                        description:
                            'Calculate resistance and tolerance using resistor color bands.',
                        icon: Icons.calculate_rounded,
                        accentColor: const Color(0xFF0D9488),
                        backgroundColor: const Color(0xFFF0FDFA),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CalculatorScreen(),
                            ),
                          );
                        },
                      );

                      final card3 = _buildModuleCard(
                        context,
                        moduleNumber: 'Module 03',
                        title: 'Types of Resistors',
                        description:
                            'Explore fixed, variable and special-purpose resistors.',
                        icon: Icons.category_rounded,
                        accentColor: const Color(0xFF7C3AED),
                        backgroundColor: const Color(0xFFF5F3FF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TypesScreen(),
                            ),
                          );
                        },
                      );

                      final card4 = _buildModuleCard(
                        context,
                        moduleNumber: 'Module 04',
                        title: 'Quiz',
                        description:
                            'Test your Basic Electronics knowledge with 10 questions.',
                        icon: Icons.quiz_rounded,
                        accentColor: const Color(0xFFEA580C),
                        backgroundColor: const Color(0xFFFFF7ED),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuizScreen(),
                            ),
                          );
                        },
                      );

                      final card5 = _buildModuleCard(
                        context,
                        moduleNumber: 'Module 05',
                        title: 'Scan Resistor',
                        description:
                            'Use your camera to identify resistor color bands.',
                        icon: Icons.camera_alt_rounded,
                        accentColor: const Color(0xFF0891B2),
                        backgroundColor: const Color(0xFFECFEFF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScanResistorScreen(),
                            ),
                          );
                        },
                      );

                      if (isWide) {
                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: card1),
                                const SizedBox(width: 16),
                                Expanded(child: card2),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: card3),
                                const SizedBox(width: 16),
                                Expanded(child: card4),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: card5),
                                const SizedBox(width: 16),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          card1,
                          const SizedBox(height: 14),
                          card2,
                          const SizedBox(height: 14),
                          card3,
                          const SizedBox(height: 14),
                          card4,
                          const SizedBox(height: 14),
                          card5,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Polished Header with "Basic Electronics Lab", "Resistor Lab", and Subtitle.
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF), Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department / Lab Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school_rounded, color: Colors.amberAccent, size: 14),
                SizedBox(width: 6),
                Text(
                  'Basic Electronics Lab',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Main Title
          Text(
            'Resistor Lab',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            'Learn, calculate and test your knowledge of resistors.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFE0F2FE),
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Lab Objectives Section.
  Widget _buildLabObjectivesCard(BuildContext context) {
    final theme = Theme.of(context);

    const objectives = [
      'Understand the function and unit of resistors',
      'Measure resistor value',
      'Understand resistor tolerance',
      'Identify different types of resistors',
    ];

    return Card(
      elevation: 0,
      color: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Lab Objectives',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...objectives.map(
              (obj) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF059669),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        obj,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable Card for the four educational modules.
  Widget _buildModuleCard(
    BuildContext context, {
    required String moduleNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module Icon Container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Content Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Module Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        moduleNumber,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Module Title
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Module Description
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Navigation Arrow
              const Padding(
                padding: EdgeInsets.only(top: 14.0),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF94A3B8),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
