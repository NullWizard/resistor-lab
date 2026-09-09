import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_components.dart';

/// Detailed Educational Screen: Learn About Resistors.
///
/// Features high-visibility rounded liquid glass components, rich technical
/// schematics, and interactive circuit graphics inspired by liquidglassdesign.com:
/// A. What is a Resistor? (with IEEE & IEC Schematic Symbols)
/// B. Function of a Resistor (5 Core Application Cards)
/// C. Ohm's Law & Calculations (Visual Formula Triangle Deck)
/// D. Measuring Resistance with a Multimeter (Step-by-Step Lab Guide)
/// E. Resistor Tolerance (Tolerance Variance Spectrum)
/// F. Power Rating & Joule Heating (Wattage Dissipation Scale)
/// G. Four-Band Resistor Color Code System & Mnemonic Capsules
/// H. Quick Revision ("Remember These" - Viva Essentials)
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Learn About Resistors',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: FuturisticBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 110.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Overview Liquid Glass Banner
                    _buildHeaderBanner(context),
                    const SizedBox(height: 22),

                    // Section A: What is a Resistor?
                    _buildSectionA(context),
                    const SizedBox(height: 20),

                    // Section B: Function of a Resistor
                    _buildSectionB(context),
                    const SizedBox(height: 20),

                    // Section C: Ohm's Law
                    _buildSectionC(context),
                    const SizedBox(height: 20),

                    // Section D: Measuring Resistance
                    _buildSectionD(context),
                    const SizedBox(height: 20),

                    // Section E: Resistor Tolerance
                    _buildSectionE(context),
                    const SizedBox(height: 20),

                    // Section F: Power Rating
                    _buildSectionF(context),
                    const SizedBox(height: 20),

                    // Section G: Resistor Color Code Table
                    _buildSectionG(context),
                    const SizedBox(height: 20),

                    // Section H: Quick Revision ("Remember These")
                    _buildSectionH(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TOPIC BANNER
  // ==========================================
  Widget _buildHeaderBanner(BuildContext context) {
    return GlassContainer(
      borderRadius: 24,
      glowColor: const Color(0xFF00E5FF),
      padding: const EdgeInsets.all(22.0),
      child: Row(
        children: [
          const LiquidGlassIconLens(
            icon: Icons.menu_book_rounded,
            accentColor: Color(0xFF00E5FF),
            size: 54,
            iconSize: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GlassBadge(
                  label: 'THEORY & LAB WORKBENCH',
                  accentColor: Color(0xFF00E5FF),
                  fontSize: 10,
                ),
                const SizedBox(height: 6),
                Text(
                  'Resistor Fundamentals & Theory',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFFF8FAFC),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Core electronic principles, schematic symbols, formulas, and viva questions.',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF94A3B8),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION A: WHAT IS A RESISTOR?
  // ==========================================
  Widget _buildSectionA(BuildContext context) {
    const commonValues = [
      '100 Ω',
      '220 Ω',
      '330 Ω',
      '470 Ω',
      '1 kΩ',
      '2.2 kΩ',
      '4.7 kΩ',
      '10 kΩ',
      '100 kΩ',
      '1 MΩ',
    ];

    return LiquidGlassTopicCard(
      title: 'What is a Resistor?',
      icon: Icons.info_outline_rounded,
      accentColor: const Color(0xFF38BDF8),
      children: [
        _buildInfoCard(
          label: 'Definition',
          content:
              'A resistor is a passive two-terminal electrical component that implements electrical resistance as a circuit element.',
          accentColor: const Color(0xFF38BDF8),
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          label: 'Circuit Purpose',
          content:
              'Its primary purpose is to control, limit, or regulate current flow and generate a precise voltage drop across circuit branches.',
          accentColor: const Color(0xFF38BDF8),
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          label: 'Physical Mechanism',
          content:
              'Conduction electrons collide with the atomic lattice of resistive material (carbon/metal alloy), transferring kinetic energy into thermal energy (heat) and opposing current drift.',
          accentColor: const Color(0xFF38BDF8),
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          label: 'SI Unit',
          content:
              'The SI unit of electrical resistance is the Ohm (symbol: Ω), named in honor of German physicist Georg Simon Ohm.',
          accentColor: const Color(0xFF38BDF8),
        ),
        const SizedBox(height: 16),

        // GRAPHIC: IEEE vs IEC Resistor Schematic Symbols
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF081220).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.28),
              width: 1.1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.schema_rounded, color: Color(0xFF38BDF8), size: 17),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Standard Schematic Symbols in Circuit Diagrams',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  // IEEE / US Zig-Zag
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF040A14).withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.22),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 28,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _ZigZagSymbolPainter(color: const Color(0xFF38BDF8)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'IEEE / US Standard',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: const Color(0xFF38BDF8),
                            ),
                          ),
                          const Text(
                            'Zig-zag line symbol',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // IEC / International Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF040A14).withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.22),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 28,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _IecBoxSymbolPainter(color: const Color(0xFF38BDF8)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'IEC Standard',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: const Color(0xFF38BDF8),
                            ),
                          ),
                          const Text(
                            'Rectangular box symbol',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Common Resistor Values Pill Cloud
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF070E1A).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1E293B),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Common Preferred Lab Values (E12 / E24 Series):',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: commonValues.map((val) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      val,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE0F2FE),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION B: FUNCTION OF A RESISTOR
  // ==========================================
  Widget _buildSectionB(BuildContext context) {
    final functions = [
      (
        num: '01',
        title: 'Current Limiting',
        desc:
            'Protects sensitive components like LEDs and microchips from excessive forward current burnout (e.g. keeping LED current under 20 mA).',
        icon: Icons.shield_rounded,
        accent: const Color(0xFF2DD4BF),
      ),
      (
        num: '02',
        title: 'Voltage Division',
        desc:
            'Two series resistors divide supply voltage in proportion to their resistance values: Vout = Vin × [R2 / (R1 + R2)].',
        icon: Icons.call_split_rounded,
        accent: const Color(0xFF00E5FF),
      ),
      (
        num: '03',
        title: 'Component Protection',
        desc:
            'Suppresses transient inductive spikes, absorbs inrush surges, and protects I/O ports from high voltage spikes.',
        icon: Icons.security_rounded,
        accent: const Color(0xFF38BDF8),
      ),
      (
        num: '04',
        title: 'Transistor Biasing',
        desc:
            'Establishes steady DC operating points (Q-points) in BJT and FET circuits to guarantee distortion-free audio/RF amplification.',
        icon: Icons.tune_rounded,
        accent: const Color(0xFFA78BFA),
      ),
      (
        num: '05',
        title: 'Pull-Up & Pull-Down Resistors',
        desc:
            'Ensures digital logic inputs (Arduino/MCU) never remain in an undefined floating state when switches or sensors are open.',
        icon: Icons.swap_vert_rounded,
        accent: const Color(0xFFF59E0B),
      ),
    ];

    return LiquidGlassTopicCard(
      title: 'Function of a Resistor',
      icon: Icons.account_tree_rounded,
      accentColor: const Color(0xFF2DD4BF),
      children: [
        ...functions.map((fn) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF07111D).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: fn.accent.withValues(alpha: 0.25),
                  width: 1.1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: fn.accent.withValues(alpha: 0.15),
                      border: Border.all(
                        color: fn.accent.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        fn.num,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: fn.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(fn.icon, size: 16, color: fn.accent),
                            const SizedBox(width: 6),
                            Text(
                              fn.title,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFF8FAFC),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fn.desc,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFCBD5E1),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // SECTION C: OHM'S LAW
  // ==========================================
  Widget _buildSectionC(BuildContext context) {
    return LiquidGlassTopicCard(
      title: "Ohm's Law & Calculations",
      icon: Icons.calculate_rounded,
      accentColor: const Color(0xFFA78BFA),
      children: [
        const Text(
          "Ohm's Law states that current (I) through a conductor between two points is directly proportional to voltage (V) across the points and inversely proportional to resistance (R), at constant temperature.",
          style: TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 16),

        // GRAPHIC: Visual Ohm's Law Formula Triangle & Units Deck
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF090D1C).withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFA78BFA).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA78BFA).withValues(alpha: 0.12),
                blurRadius: 18,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Ohm's Triangle Visualization
              Container(
                width: 140,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF13112E).withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFA78BFA).withValues(alpha: 0.40),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'V',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                    Container(
                      height: 1.5,
                      width: 90,
                      color: const Color(0xFFA78BFA),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'I',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2DD4BF),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('×', style: TextStyle(color: const Color(0xFFA78BFA), fontSize: 18)),
                        ),
                        Text(
                          'R',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3 Formula Capsules
              Row(
                children: [
                  _buildFormulaCapsule('V = I × R', 'Voltage (Volts)', const Color(0xFF38BDF8)),
                  const SizedBox(width: 8),
                  _buildFormulaCapsule('I = V / R', 'Current (Amperes)', const Color(0xFF2DD4BF)),
                  const SizedBox(width: 8),
                  _buildFormulaCapsule('R = V / I', 'Resistance (Ohms)', const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Worked Lab Example Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1322).withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Viva Lab Example Calculation',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFFFBBF24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Given: Voltage (V) = 5 V across an R = 100 Ω breadboard resistor.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFE2E8F0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF050B14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('I = V / R', style: GoogleFonts.jetBrainsMono(fontSize: 13, color: const Color(0xFF94A3B8))),
                    const SizedBox(height: 2),
                    Text('I = 5 V / 100 Ω = 0.05 A', style: GoogleFonts.jetBrainsMono(fontSize: 13, color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 4),
                    Text('I = 50 mA (Safe for breadboard LED drivers)',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFBBF24),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildFormulaCapsule(String formula, String desc, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Text(
              formula,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SECTION D: MEASURING RESISTANCE
  // ==========================================
  Widget _buildSectionD(BuildContext context) {
    const steps = [
      'Turn ON the digital multimeter (DMM).',
      'Turn the rotary selector knob to resistance mode (marked with the Ω symbol).',
      'CRITICAL SAFETY: Disconnect resistor from power! In-circuit readings create parallel sneak paths and can blow multimeter fuses.',
      'Touch red and black test probes firmly to the two resistor leads. Polarity does not matter.',
      'Read the stable numeric resistance on the LCD screen.',
    ];

    return LiquidGlassTopicCard(
      title: 'Measuring Resistance (Multimeter)',
      icon: Icons.speed_rounded,
      accentColor: const Color(0xFFF59E0B),
      children: [
        const Text(
          'In electronics lab sessions, resistance is verified using a Digital Multimeter (DMM). Always follow standard laboratory procedure:',
          style: TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 14),

        ...steps.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final text = entry.value;
          final isWarning = idx == 3;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isWarning
                    ? const Color(0xFF200B0B).withValues(alpha: 0.70)
                    : const Color(0xFF08121E).withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isWarning
                      ? const Color(0xFFEF4444).withValues(alpha: 0.45)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.20),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isWarning
                          ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.20),
                      border: Border.all(
                        color: isWarning ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$idx',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isWarning ? const Color(0xFFF87171) : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        color: isWarning ? const Color(0xFFFCA5A5) : const Color(0xFFCBD5E1),
                        fontWeight: isWarning ? FontWeight.w600 : FontWeight.normal,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // SECTION E: RESISTOR TOLERANCE
  // ==========================================
  Widget _buildSectionE(BuildContext context) {
    return LiquidGlassTopicCard(
      title: 'Resistor Tolerance',
      icon: Icons.tune_rounded,
      accentColor: const Color(0xFF10B981),
      children: [
        const Text(
          'Tolerance specifies how far the physical measured resistance can deviate from its nominal marked color code value, expressed as a percentage (±%).',
          style: TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 14),

        // GRAPHIC: Tolerance Spectrum Meter
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF061418).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.linear_scale_rounded, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tolerance Range Visualizer: 1,000 Ω ± 5% (Gold)',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Visual Gauge Readout Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '950 Ω (-5% Min)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6EE7B7),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '1,000 Ω (Nominal)',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ),
                  Text(
                    '1,050 Ω (+5% Max)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6EE7B7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Continuous Visual Spectrum Gauge Track
              Container(
                height: 18,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFEF4444).withValues(alpha: 0.35),
                      const Color(0xFF10B981).withValues(alpha: 0.50),
                      const Color(0xFF10B981),
                      const Color(0xFF10B981).withValues(alpha: 0.50),
                      const Color(0xFFEF4444).withValues(alpha: 0.35),
                    ],
                    stops: const [0.0, 0.20, 0.50, 0.80, 1.0],
                  ),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Deviation formula: ±5% of 1,000 Ω = ±50 Ω. Any reading between 950 Ω and 1,050 Ω is 100% acceptable.',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Tolerance Band Badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _ToleranceBadge('Brown', '±1%', Color(0xFF6D4C41), Colors.white),
            _ToleranceBadge('Red', '±2%', Color(0xFFD32F2F), Colors.white),
            _ToleranceBadge('Gold', '±5%', Color(0xFFFFD700), Colors.black87),
            _ToleranceBadge('Silver', '±10%', Color(0xFFC0C0C0), Colors.black87),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // SECTION F: POWER RATING
  // ==========================================
  Widget _buildSectionF(BuildContext context) {
    final wattageList = [
      ('1/8 W (0.125 W)', 'Ultra-compact circuits'),
      ('1/4 W (0.25 W)', 'Standard breadboards (most common)'),
      ('1/2 W (0.5 W)', 'Audio stages & small drivers'),
      ('1 W – 2 W', 'Power regulators'),
      ('5 W+', 'Wirewound & ceramic power loads'),
    ];

    return LiquidGlassTopicCard(
      title: 'Power Rating & Joule Heating',
      icon: Icons.whatshot_rounded,
      accentColor: const Color(0xFFEF4444),
      children: [
        const Text(
          'A resistor converts electrical energy into heat (P = I²R). The power rating defines the maximum continuous wattage it can safely dissipate without burning out.',
          style: TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 14),

        // Three Power Dissipation Formulas
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E0808).withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('P = V × I',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF87171),
                  )),
              const Text('•', style: TextStyle(color: Color(0xFFEF4444), fontSize: 20)),
              Text('P = I² × R',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF87171),
                  )),
              const Text('•', style: TextStyle(color: Color(0xFFEF4444), fontSize: 20)),
              Text('P = V² / R',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF87171),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Physical Wattage Scale Cards
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF090D18).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Physical Body Size Scale:',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 8),
              ...wattageList.map((w) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          w.$1,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFCA5A5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          w.$2,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION G: RESISTOR COLOR CODE
  // ==========================================
  Widget _buildSectionG(BuildContext context) {
    const mnemonics = [
      ('B', 'Black', Color(0xFF212121), '0'),
      ('B', 'Brown', Color(0xFF6D4C41), '1'),
      ('R', 'Red', Color(0xFFD32F2F), '2'),
      ('O', 'Orange', Color(0xFFF57C00), '3'),
      ('Y', 'Yellow', Color(0xFFFBC02D), '4'),
      ('G', 'Green', Color(0xFF388E3C), '5'),
      ('B', 'Blue', Color(0xFF1976D2), '6'),
      ('V', 'Violet', Color(0xFF7B1FA2), '7'),
      ('G', 'Grey', Color(0xFF757575), '8'),
      ('W', 'White', Color(0xFFFFFFFF), '9'),
    ];

    return LiquidGlassTopicCard(
      title: 'Four-Band Color Code & Mnemonics',
      icon: Icons.palette_rounded,
      accentColor: const Color(0xFF38BDF8),
      children: [
        const Text(
          'Axial resistors use color bands to encode numeric resistance values and precision tolerance:',
          style: TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 14),

        // Mnemonic Memory Deck
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF091220).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology_rounded, color: Color(0xFF38BDF8), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Memory Mnemonic (Standard Lab Formula):',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: const Color(0xFFBAE6FD),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '"B B R O Y of Great Britain Very Good Wife"',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF8FAFC),
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: mnemonics.map((m) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF040A14),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: m.$3.withValues(alpha: 0.6), width: 1.1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: m.$3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${m.$1}: ${m.$2} (${m.$4})',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFCBD5E1),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Color Reference Table
        Table(
          border: TableBorder.all(color: const Color(0xFF1E293B)),
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.3),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: const Color(0xFF080D1A)),
              children: [
                _tableHeader('Color'),
                _tableHeader('Digit'),
                _tableHeader('Multiplier'),
                _tableHeader('Tolerance'),
              ],
            ),
            _buildTableRow('Black', 0, '×1 (10⁰)', '—', const Color(0xFF212121)),
            _buildTableRow('Brown', 1, '×10 (10¹)', '±1%', const Color(0xFF6D4C41)),
            _buildTableRow('Red', 2, '×100 (10²)', '±2%', const Color(0xFFD32F2F)),
            _buildTableRow('Orange', 3, '×1,000 (10³)', '—', const Color(0xFFF57C00)),
            _buildTableRow('Yellow', 4, '×10,000 (10⁴)', '—', const Color(0xFFFBC02D)),
            _buildTableRow('Green', 5, '×100,000 (10⁵)', '—', const Color(0xFF388E3C)),
            _buildTableRow('Blue', 6, '×1,000,000 (10⁶)', '—', const Color(0xFF1976D2)),
            _buildTableRow('Violet', 7, '×10,000,000 (10⁷)', '—', const Color(0xFF7B1FA2)),
            _buildTableRow('Grey', 8, '×100,000,000 (10⁸)', '—', const Color(0xFF757575)),
            _buildTableRow('White', 9, '×1,000,000,000 (10⁹)', '—', const Color(0xFFFFFFFF)),
            _buildTableRow('Gold', null, '×0.1', '±5%', const Color(0xFFFFD700)),
            _buildTableRow('Silver', null, '×0.01', '±10%', const Color(0xFFC0C0C0)),
          ],
        ),
      ],
    );
  }

  static Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: const Color(0xFFF8FAFC),
        ),
      ),
    );
  }

  // ==========================================
  // SECTION H: QUICK REVISION (VIVA ESSENTIALS)
  // ==========================================
  Widget _buildSectionH(BuildContext context) {
    const revisionPoints = [
      "Ohm's Law fundamental relationship: V = I × R, with I = V / R and R = V / I.",
      "The SI unit of resistance is the Ohm (Ω). Current is measured in Amperes (A), Voltage in Volts (V).",
      "Always disconnect components from any powered circuit before measuring with a multimeter.",
      "A 4-band resistor uses Band 1 & 2 for digits, Band 3 for multiplier, and Band 4 for tolerance.",
      "Standard tolerance band colors: Gold = ±5%, Silver = ±10%, Brown = ±1%, Red = ±2%.",
      "Power rating (P = I²R) determines safe heat dissipation; 1/4 W (0.25 W) is standard for breadboards.",
    ];

    return LiquidGlassTopicCard(
      title: 'Remember These (Viva Essentials)',
      icon: Icons.bookmark_added_rounded,
      accentColor: const Color(0xFFF59E0B),
      children: [
        ...revisionPoints.map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF091224).withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF59E0B),
                      ),
                      child: const Icon(Icons.check_rounded, size: 11, color: Color(0xFF080D1A)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  static Widget _buildInfoCard({
    required String label,
    required String content,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF07101C).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                  boxShadow: [
                    BoxShadow(color: accentColor, blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFFCBD5E1),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  static TableRow _buildTableRow(String colorName, int? digit, String mult, String tol, Color color) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: color == Colors.white ? Colors.grey : Colors.transparent, width: 0.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(colorName, style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(digit != null ? '$digit' : '—', style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1))),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(mult, style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1))),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(tol, style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1))),
        ),
      ],
    );
  }
}

class _ToleranceBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color text;

  const _ToleranceBadge(this.label, this.value, this.bg, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bg.withValues(alpha: 0.55), width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFF8FAFC),
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the IEEE (US) Zig-Zag resistor schematic symbol (Dynamic Responsive Width).
class _ZigZagSymbolPainter extends CustomPainter {
  final Color color;

  const _ZigZagSymbolPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final midY = size.height / 2;
    final w = size.width;

    // Terminal dots
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(3, midY), 2.5, dotPaint);
    canvas.drawCircle(Offset(w - 3, midY), 2.5, dotPaint);

    // Compute leads and responsive zig-zag width
    final leadLen = (w * 0.20).clamp(8.0, 24.0);
    final zigzagStart = leadLen;
    final zigzagEnd = w - leadLen;
    final zigzagWidth = zigzagEnd - zigzagStart;

    // Left lead
    path.moveTo(3, midY);
    path.lineTo(zigzagStart, midY);

    // Zig-Zag peaks (scaled proportionally across zigzagWidth)
    const numPeaks = 6;
    final dx = zigzagWidth / numPeaks;
    final peakH = 9.0.clamp(4.0, size.height * 0.40);

    for (int i = 1; i <= numPeaks; i++) {
      final px = zigzagStart + dx * (i - 0.5);
      final py = (i % 2 == 1) ? midY - peakH : midY + peakH;
      path.lineTo(px, py);
    }
    path.lineTo(zigzagEnd, midY);

    // Right lead
    path.lineTo(w - 3, midY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ZigZagSymbolPainter oldDelegate) => oldDelegate.color != color;
}

/// Custom painter for the IEC (International) rectangular box resistor schematic symbol (Dynamic Responsive Width).
class _IecBoxSymbolPainter extends CustomPainter {
  final Color color;

  const _IecBoxSymbolPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final midY = size.height / 2;
    final w = size.width;

    // Terminal dots
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(3, midY), 2.5, dotPaint);
    canvas.drawCircle(Offset(w - 3, midY), 2.5, dotPaint);

    // Box dimensions scaled to available width
    final boxW = (w * 0.52).clamp(32.0, 68.0);
    const boxH = 16.0;
    final boxLeft = (w - boxW) / 2;
    final boxRight = boxLeft + boxW;

    // Left lead
    canvas.drawLine(Offset(3, midY), Offset(boxLeft, midY), paint);

    // Box
    final rect = Rect.fromCenter(center: Offset(w / 2, midY), width: boxW, height: boxH);
    canvas.drawRect(rect, paint);

    // Right lead
    canvas.drawLine(Offset(boxRight, midY), Offset(w - 3, midY), paint);
  }

  @override
  bool shouldRepaint(covariant _IecBoxSymbolPainter oldDelegate) => oldDelegate.color != color;
}
