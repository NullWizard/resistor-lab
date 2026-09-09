import 'package:flutter/material.dart';
import '../widgets/glass_components.dart';

/// Detailed Educational Screen: Learn About Resistors.
///
/// Covers:
/// A. What is a Resistor?
/// B. Function of a Resistor
/// C. Ohm's Law & Calculations
/// D. Measuring Resistance with a Multimeter
/// E. Resistor Tolerance & Examples
/// F. Power Rating & Joule Heating Formulas
/// G. Four-Band Resistor Color Code Reference Table
/// H. Quick Revision ("Remember These")
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Learn About Resistors'),
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
                    // Topic Banner
                    _buildHeaderBanner(context),
                    const SizedBox(height: 20),

                    // Section A: What is a Resistor?
                    _buildSectionA(context),
                    const SizedBox(height: 18),

                    // Section B: Function of a Resistor
                    _buildSectionB(context),
                    const SizedBox(height: 18),

                    // Section C: Ohm's Law
                    _buildSectionC(context),
                    const SizedBox(height: 18),

                    // Section D: Measuring Resistance
                    _buildSectionD(context),
                    const SizedBox(height: 18),

                    // Section E: Resistor Tolerance
                    _buildSectionE(context),
                    const SizedBox(height: 18),

                    // Section F: Power Rating
                    _buildSectionF(context),
                    const SizedBox(height: 18),

                    // Section G: Resistor Color Code Table
                    _buildSectionG(context),
                    const SizedBox(height: 18),

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
      borderRadius: 20,
      glowColor: const Color(0xFF00E5FF),
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.40),
              ),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF00E5FF),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resistor Fundamentals & Theory',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFFF8FAFC),
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Study notes and key concepts for lab experiments and vivas.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
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
    return _buildCardWrapper(
      title: 'A. What is a Resistor?',
      icon: Icons.info_outline_rounded,
      iconColor: const Color(0xFF38BDF8),
      children: [
        const Text(
          '• Definition: A resistor is a passive two-terminal electrical component that implements electrical resistance as a circuit element.',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Purpose in a Circuit: Its primary purpose is to control, limit, or regulate the flow of electrical current and to generate a specific voltage drop.',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 8),
        const Text(
          '• How it Opposes Current: Inside the resistor, conduction electrons collide with the atomic lattice of the resistive material (e.g., carbon or metal alloy). These collisions slow down electron drift, opposing current flow and dissipating energy as heat.',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Unit of Resistance: The SI unit of resistance is the Ohm (symbol: Ω), named after German physicist Georg Simon Ohm.',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 12),

        // Common values chip container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF080D1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Common Resistor Values in Labs (E12/E24 Series):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: Color(0xFFF8FAFC),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '100 Ω, 220 Ω, 330 Ω, 470 Ω, 1 kΩ (1,000 Ω), 2.2 kΩ, 4.7 kΩ, 10 kΩ, 100 kΩ, 1 MΩ (1,000,000 Ω)',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
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
    return _buildCardWrapper(
      title: 'B. Function of a Resistor',
      icon: Icons.account_tree_rounded,
      iconColor: const Color(0xFF2DD4BF),
      children: [
        _buildFunctionItem(
          title: '1. Current Limiting',
          description:
              'Prevents damage to sensitive components such as LEDs and diodes by restricting current to safe operating limits (e.g., keeping LED current under 20 mA).',
        ),
        _buildFunctionItem(
          title: '2. Voltage Division',
          description:
              'When two resistors are connected in series across a voltage source, they divide the total voltage proportionally based on their resistance ratio (Vout = Vin × R2 / (R1 + R2)).',
        ),
        _buildFunctionItem(
          title: '3. Protecting Components',
          description:
              'Absorbs power surges, suppresses transient electrical spikes, and protects microcontrollers and IC pins from overcurrent damage.',
        ),
        _buildFunctionItem(
          title: '4. Biasing Circuits',
          description:
              'Sets the quiescent DC operating point (Q-point) for active components like bipolar junction transistors (BJTs) and operational amplifiers to ensure distortion-free amplification.',
        ),
        _buildFunctionItem(
          title: '5. Pull-Up and Pull-Down Applications',
          description:
              'Connected to digital logic input pins (e.g., Arduino or microcontrollers) to guarantee a known HIGH (Vcc) or LOW (GND) logic level when switches or buttons are open, preventing floating inputs.',
        ),
      ],
    );
  }

  // ==========================================
  // SECTION C: OHM'S LAW
  // ==========================================
  Widget _buildSectionC(BuildContext context) {
    return _buildCardWrapper(
      title: "C. Ohm's Law",
      icon: Icons.calculate_rounded,
      iconColor: const Color(0xFFA78BFA),
      children: [
        const Text(
          "Ohm's Law is the most fundamental relationship in electrical engineering. It states that the current flowing through a conductor between two points is directly proportional to the voltage across the two points, provided the temperature remains constant.",
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 14),

        // Formula Triad Card
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF080D1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'V = I × R',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA78BFA),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text('Voltage (V)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
              Text('|', style: TextStyle(color: Color(0xFF334155), fontSize: 24)),
              Column(
                children: [
                  Text(
                    'I = V / R',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA78BFA),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text('Current (A)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
              Text('|', style: TextStyle(color: Color(0xFF334155), fontSize: 24)),
              Column(
                children: [
                  Text(
                    'R = V / I',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA78BFA),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text('Resistance (Ω)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Worked Example Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF080D1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Worked Lab Example:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFFFBBF24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Given: Voltage (V) = 5 V,  Resistance (R) = 100 Ω',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: Color(0xFFE2E8F0),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF101726),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('I = V / R', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFFCBD5E1))),
                    SizedBox(height: 2),
                    Text('I = 5 / 100', style: TextStyle(fontFamily: 'monospace', color: Color(0xFF94A3B8))),
                    SizedBox(height: 2),
                    Text('I = 0.05 A', style: TextStyle(fontFamily: 'monospace', color: Color(0xFF94A3B8))),
                    SizedBox(height: 2),
                    Text(
                      'I = 50 mA',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION D: MEASURING RESISTANCE
  // ==========================================
  Widget _buildSectionD(BuildContext context) {
    return _buildCardWrapper(
      title: 'D. Measuring Resistance (Digital Multimeter)',
      icon: Icons.speed_rounded,
      iconColor: const Color(0xFFF59E0B),
      children: [
        const Text(
          'In an electronics lab, resistance is measured using a Digital Multimeter (DMM). Follow these standard laboratory steps:',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 12),

        _buildStepItem(step: '1', text: 'Turn ON the digital multimeter.'),
        _buildStepItem(step: '2', text: 'Turn the selector dial to resistance mode (indicated by the Ω symbol).'),
        _buildStepItem(
          step: '3',
          text: 'CRITICAL SAFETY: Ensure the resistor is completely DISCONNECTED from any powered circuit. (Measuring in-circuit can give incorrect readings due to parallel paths, and live circuits can damage the meter!).',
          isWarning: true,
        ),
        _buildStepItem(step: '4', text: 'Touch the red and black test probes to each terminal of the resistor. Polarity does not matter.'),
        _buildStepItem(step: '5', text: 'Read the stable measured resistance displayed on the digital screen.'),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF080D1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.help_outline_rounded, color: Color(0xFF94A3B8), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Why does the measured value differ slightly from the marked value?\n'
                  'Because every physical resistor has manufacturing tolerances, temperature fluctuations, and meter lead resistance. A 1,000 Ω resistor with 5% tolerance can measure between 950 Ω and 1050 Ω.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFFCBD5E1), height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION E: RESISTOR TOLERANCE
  // ==========================================
  Widget _buildSectionE(BuildContext context) {
    return _buildCardWrapper(
      title: 'E. Resistor Tolerance',
      icon: Icons.tune_rounded,
      iconColor: const Color(0xFF10B981),
      children: [
        const Text(
          '• What Tolerance Means: Tolerance indicates how much the actual measured resistance can deviate from its nominal (marked) value, expressed as a percentage (±%).',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Why Tolerance Exists: Manufacturing variations in chemical purity, coating thickness, laser trimming precision, and ambient temperature make exact resistance economically impractical.',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 12),

        const Text(
          'Common Tolerance Band Colors:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF8FAFC)),
        ),
        const SizedBox(height: 6),
        const Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _ToleranceBadge('Brown', '±1%', Color(0xFF6D4C41), Colors.white),
            _ToleranceBadge('Red', '±2%', Color(0xFFD32F2F), Colors.white),
            _ToleranceBadge('Gold', '±5%', Color(0xFFFFD700), Colors.black87),
            _ToleranceBadge('Silver', '±10%', Color(0xFFC0C0C0), Colors.black87),
          ],
        ),
        const SizedBox(height: 14),

        // Tolerance Example Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF080D1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tolerance Calculation Example: 1 kΩ (1000 Ω) ±5%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: Color(0xFF34D399),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '5% of 1000 Ω = (5 / 100) × 1000 = 50 Ω deviation allowance.',
                style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Minimum = 1000 - 50 = 950 Ω',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Maximum = 1000 + 50 = 1050 Ω',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION F: POWER RATING
  // ==========================================
  Widget _buildSectionF(BuildContext context) {
    return _buildCardWrapper(
      title: 'F. Power Rating & Joule Heating',
      icon: Icons.whatshot_rounded,
      iconColor: const Color(0xFFEF4444),
      children: [
        const Text(
          '• Meaning: The power rating of a resistor specifies the maximum amount of electrical power it can safely dissipate continuously as heat without burning out, deteriorating, or altering its resistance value.',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Why Resistors Heat Up: Electric current passing through a resistor collides with material atoms, converting electrical energy into heat (Joule heating). If heat generated exceeds dissipation capability, the resistor can smoke, crack, or damage the circuit board.',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Common Standard Ratings: 1/4 W (0.25 W - most common on breadboards), 1/2 W (0.5 W), 1 W, 2 W, and 5 W+. Higher power resistors are physically larger to provide greater surface area for heat dissipation.',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 14),

        // Three Power Formulas
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF080D1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'P = V × I',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF87171)),
              ),
              Text('•', style: TextStyle(color: Color(0xFF7F1D1D), fontSize: 20)),
              Text(
                'P = I²R',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF87171)),
              ),
              Text('•', style: TextStyle(color: Color(0xFF7F1D1D), fontSize: 20)),
              Text(
                'P = V² / R',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF87171)),
              ),
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
    return _buildCardWrapper(
      title: 'G. Four-Band Resistor Color Code',
      icon: Icons.palette_rounded,
      iconColor: const Color(0xFF38BDF8),
      children: [
        const Text(
          'Through-hole resistors use colored bands printed on their cylindrical ceramic bodies to encode resistance and tolerance:',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFCBD5E1)),
        ),
        const SizedBox(height: 8),

        // Band meanings
        const Column(
          children: [
            _BandRow('Band 1', 'First Significant Digit'),
            _BandRow('Band 2', 'Second Significant Digit'),
            _BandRow('Band 3', 'Multiplier (Decimal Power: 10ⁿ)'),
            _BandRow('Band 4', 'Tolerance Percentage (±%)'),
          ],
        ),
        const SizedBox(height: 14),

        const Text(
          'Color Reference Table:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF8FAFC)),
        ),
        const SizedBox(height: 8),

        // Color Table
        Table(
          border: TableBorder.all(color: const Color(0xFF1E293B)),
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.3),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFF080D1A)),
              children: [
                Padding(padding: EdgeInsets.all(8), child: Text('Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF8FAFC)))),
                Padding(padding: EdgeInsets.all(8), child: Text('Digit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF8FAFC)))),
                Padding(padding: EdgeInsets.all(8), child: Text('Multiplier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF8FAFC)))),
                Padding(padding: EdgeInsets.all(8), child: Text('Tolerance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF8FAFC)))),
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

  // ==========================================
  // SECTION H: QUICK REVISION
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

    return GlassContainer(
      borderRadius: 18,
      glowColor: const Color(0xFFF59E0B),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.bookmark_added_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Remember These (Quick Revision for Viva)',
                  style: TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...revisionPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B132B).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF00E5FF),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 13,
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
      ),
    );
  }

  // Helper Widgets
  static Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return GlassContainer(
      borderRadius: 18,
      glowColor: iconColor.withValues(alpha: 0.12),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF8FAFC),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFF1E293B)),
          ...children,
        ],
      ),
    );
  }

  static Widget _buildFunctionItem({required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1), height: 1.35),
          ),
        ],
      ),
    );
  }

  static Widget _buildStepItem({required String step, required String text, bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: isWarning ? const Color(0xFFEF4444) : const Color(0xFF00E5FF),
            child: Text(
              step,
              style: TextStyle(
                color: isWarning ? Colors.white : const Color(0xFF080D1A),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                color: isWarning ? const Color(0xFFF87171) : const Color(0xFFCBD5E1),
                fontWeight: isWarning ? FontWeight.w600 : FontWeight.normal,
                height: 1.35,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _BandRow extends StatelessWidget {
  final String band;
  final String meaning;

  const _BandRow(this.band, this.meaning);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF080D1A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Text(
              band,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFFF8FAFC)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '→ $meaning',
              style: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
            ),
          ),
        ],
      ),
    );
  }
}
