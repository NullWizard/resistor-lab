import 'package:flutter/material.dart';
import '../widgets/glass_components.dart';
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
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.electric_bolt_rounded, color: Color(0xFF00E5FF)),
            SizedBox(width: 10),
            Text(
              'Resistor',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: FuturisticBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16.0,
                16.0,
                16.0,
                MediaQuery.paddingOf(context).bottom + 40.0,
              ),
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
                        'Interactive Features',
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
                        title: 'Learn About Resistors',
                        description:
                            "Understand resistor fundamentals, Ohm's law, tolerance and measurement.",
                        icon: Icons.menu_book_rounded,
                        accentColor: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFEFF6FF),
                        onTap: () {
                          Navigator.push(
                            context,
                            LiquidGlassPageRoute(
                              builder: (context) => const LearnScreen(),
                            ),
                          );
                        },
                      );

                      final card2 = _buildModuleCard(
                        context,
                        title: 'Resistor Color Code',
                        description:
                            'Calculate resistance and tolerance using resistor color bands.',
                        icon: Icons.calculate_rounded,
                        accentColor: const Color(0xFF0D9488),
                        backgroundColor: const Color(0xFFF0FDFA),
                        onTap: () {
                          Navigator.push(
                            context,
                            LiquidGlassPageRoute(
                              builder: (context) => const CalculatorScreen(),
                            ),
                          );
                        },
                      );

                      final card3 = _buildModuleCard(
                        context,
                        title: 'Types of Resistors',
                        description:
                            'Explore fixed, variable and special-purpose resistors.',
                        icon: Icons.category_rounded,
                        accentColor: const Color(0xFF7C3AED),
                        backgroundColor: const Color(0xFFF5F3FF),
                        onTap: () {
                          Navigator.push(
                            context,
                            LiquidGlassPageRoute(
                              builder: (context) => const TypesScreen(),
                            ),
                          );
                        },
                      );

                      final card4 = _buildModuleCard(
                        context,
                        title: 'Quiz',
                        description:
                            'Test your Basic Electronics knowledge with 10 questions.',
                        icon: Icons.quiz_rounded,
                        accentColor: const Color(0xFFEA580C),
                        backgroundColor: const Color(0xFFFFF7ED),
                        onTap: () {
                          Navigator.push(
                            context,
                            LiquidGlassPageRoute(
                              builder: (context) => const QuizScreen(),
                            ),
                          );
                        },
                      );

                      final card5 = _buildModuleCard(
                        context,
                        title: 'Scan Resistor',
                        description:
                            'Use your camera to identify resistor color bands.',
                        icon: Icons.camera_alt_rounded,
                        accentColor: const Color(0xFF0891B2),
                        backgroundColor: const Color(0xFFECFEFF),
                        onTap: () {
                          Navigator.push(
                            context,
                            LiquidGlassPageRoute(
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

  /// Polished Header with "Basic Electronics Lab", "Resistor", and Subtitle.
  /// Polished Header with "Basic Electronics Lab", "Resistor", and Subtitle.
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      borderRadius: 26,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              GlassBadge(
                label: 'BASIC ELECTRONICS LAB',
                icon: Icons.school_rounded,
                accentColor: Color(0xFF00E5FF),
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Title with Circuit Bolt
          Row(
            children: [
              const LiquidGlassIconLens(
                icon: Icons.electric_bolt_rounded,
                accentColor: Color(0xFF00E5FF),
                size: 46,
                iconSize: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resistor',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Virtual Laboratory & 3D Interactive Workbench',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Subtitle
          Text(
            'Interactive 3D models, color calculators, viva flashcards, and comprehensive lab theory.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFCBD5E1),
              height: 1.45,
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
      'Identify different types of resistors in 3D',
    ];

    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiquidGlassIconLens(
                icon: Icons.assignment_outlined,
                accentColor: Color(0xFF10B981),
                size: 38,
                iconSize: 19,
              ),
              const SizedBox(width: 12),
              Text(
                'Lab Objectives',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF8FAFC),
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              const GlassBadge(
                label: '4 GOALS',
                accentColor: Color(0xFF10B981),
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...objectives.map(
            (obj) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.5),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF08121E).withValues(alpha: 0.60),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.18),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10B981).withValues(alpha: 0.20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.50),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF10B981),
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        obj,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFFE2E8F0),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Card for the interactive features.
  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GlassContainer(
      onTap: onTap,
      borderRadius: 22,
      padding: const EdgeInsets.all(18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Floating Liquid Glass Icon Lens
          LiquidGlassIconLens(
            icon: icon,
            accentColor: accentColor,
            size: 52,
            iconSize: 26,
          ),
          const SizedBox(width: 16),

          // Content Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Feature Title
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8FAFC),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),

                // Module Description
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF94A3B8),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Forward Glass Button Lens
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: accentColor,
              size: 13,
            ),
          ),
        ],
      ),
    );
  }
}
