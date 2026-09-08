import 'package:flutter/material.dart';

/// Screen displaying the comprehensive taxonomy of resistors:
/// 1. Fixed Resistors (Carbon Composition, Carbon Film, Metal Film, Wirewound)
/// 2. Variable Resistors (Potentiometer, Rheostat, Preset / Trimmer)
/// 3. Special-Purpose Resistors (LDR, Thermistor, Varistor)
class TypesScreen extends StatelessWidget {
  const TypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Types of Resistors'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Overview Banner
                  _buildHeaderBanner(context),
                  const SizedBox(height: 22),

                  // CATEGORY 1: FIXED RESISTORS
                  _buildCategoryHeading(
                    context,
                    title: '1. Fixed Resistors',
                    subtitle: 'Resistors with a permanent, unchanging ohmic resistance value.',
                    badgeColor: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 12),
                  _buildResponsiveGrid(
                    context,
                    children: [
                      _buildResistorCard(
                        context,
                        name: 'Carbon Composition Resistor',
                        icon: Icons.grain_rounded,
                        accentColor: const Color(0xFF92400E),
                        backgroundColor: const Color(0xFFFEF3C7),
                        whatItDoes:
                            'Provides fixed electrical resistance with high energy surge absorption capability.',
                        howItWorks:
                            'Constructed from a solid rod made of finely ground carbon granules mixed with a ceramic binder. Current passes through microscopic conductive carbon chains.',
                        application:
                            'High-voltage power supplies, surge suppression circuits, and vintage radio equipment.',
                      ),
                      _buildResistorCard(
                        context,
                        name: 'Carbon Film Resistor',
                        icon: Icons.layers_rounded,
                        accentColor: const Color(0xFFD97706),
                        backgroundColor: const Color(0xFFFFFBEB),
                        whatItDoes:
                            'General-purpose resistor offering good tolerance (±5%) and better stability than carbon composition.',
                        howItWorks:
                            'A thin film of pure carbon is deposited onto an insulating ceramic rod. A helical groove is spiral-cut into the film to achieve the exact target resistance value.',
                        application:
                            'Everyday electronic circuits, laboratory breadboard experiments, and consumer electronics.',
                      ),
                      _buildResistorCard(
                        context,
                        name: 'Metal Film Resistor',
                        icon: Icons.precision_manufacturing_rounded,
                        accentColor: const Color(0xFF0284C7),
                        backgroundColor: const Color(0xFFF0F9FF),
                        whatItDoes:
                            'High-precision resistor with very low electrical noise and exceptional temperature stability.',
                        howItWorks:
                            'A microscopic film of nickel-chromium (Nichrome) or metal oxide is vacuum-sputtered onto an alumina ceramic core and laser-trimmed to tight tolerances (±1% or ±0.1%).',
                        application:
                            'Precision laboratory instruments, medical monitoring equipment, and Hi-Fi audio amplifiers.',
                      ),
                      _buildResistorCard(
                        context,
                        name: 'Wire Wound Resistor',
                        icon: Icons.linear_scale_rounded,
                        accentColor: const Color(0xFFB91C1C),
                        backgroundColor: const Color(0xFFFEF2F2),
                        whatItDoes:
                            'High-power resistor capable of dissipating substantial heat without thermal breakdown.',
                        howItWorks:
                            'Made by winding a high-resistance alloy wire (like Nichrome or Manganin) around an insulated ceramic core, coated in protective vitreous enamel or ceramic cement.',
                        application:
                            'High-power amplifiers, motor speed controllers, power supplies, and dummy load banks.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // CATEGORY 2: VARIABLE RESISTORS
                  _buildCategoryHeading(
                    context,
                    title: '2. Variable Resistors',
                    subtitle: 'Resistors whose ohmic value can be manually or mechanically adjusted.',
                    badgeColor: const Color(0xFF7C3AED),
                  ),
                  const SizedBox(height: 12),
                  _buildResponsiveGrid(
                    context,
                    children: [
                      _buildResistorCard(
                        context,
                        name: 'Potentiometer (Pot)',
                        icon: Icons.tune_rounded,
                        accentColor: const Color(0xFF7C3AED),
                        backgroundColor: const Color(0xFFF5F3FF),
                        whatItDoes:
                            'A 3-terminal variable resistor primarily configured as an adjustable voltage divider.',
                        howItWorks:
                            'A sliding contact (wiper) mechanically rotates or slides across a fixed resistive track, tapping off an adjustable fraction of the total voltage between terminals 1 and 3.',
                        application:
                            'Rotary volume controls in stereos, game controller joystick position sensing, and laboratory bench power supply calibration.',
                      ),
                      _buildResistorCard(
                        context,
                        name: 'Rheostat',
                        icon: Icons.speed_rounded,
                        accentColor: const Color(0xFF0D9488),
                        backgroundColor: const Color(0xFFF0FDFA),
                        whatItDoes:
                            'A 2-terminal variable resistor designed to directly control and regulate electric current flow.',
                        howItWorks:
                            'Connected in series with the load. Turning the wiper varies the effective length of resistive wire in the circuit path, directly changing circuit impedance (I = V / R).',
                        application:
                            'Incandescent light dimmer controls, laboratory physics experiments, and electric motor speed regulation.',
                      ),
                      _buildResistorCard(
                        context,
                        name: 'Preset / Trimmer (Trimpot)',
                        icon: Icons.build_circle_rounded,
                        accentColor: const Color(0xFF0284C7),
                        backgroundColor: const Color(0xFFF0F9FF),
                        whatItDoes:
                            'Miniature adjustable resistor mounted directly onto circuit boards for factory or one-time calibration.',
                        howItWorks:
                            'Features a tiny internal rotary screw or spindle adjusted using a precision screwdriver. It is set during manufacturing/tuning and rarely touched again by users.',
                        application:
                            'Calibrating sensor sensitivity, tuning oscillator frequencies, and trimming operational amplifier offset voltages.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // CATEGORY 3: SPECIAL RESISTORS
                  _buildCategoryHeading(
                    context,
                    title: '3. Special-Purpose Resistors',
                    subtitle: 'Non-linear resistors whose resistance changes in response to physical quantities.',
                    badgeColor: const Color(0xFFEA580C),
                  ),
                  const SizedBox(height: 12),
                  _buildResponsiveGrid(
                    context,
                    children: [
                      _buildResistorCard(
                        context,
                        name: 'LDR (Light Dependent Resistor)',
                        icon: Icons.light_mode_rounded,
                        accentColor: const Color(0xFFD97706),
                        backgroundColor: const Color(0xFFFEF3C7),
                        whatItDoes:
                            'A light-sensitive resistor whose resistance decreases significantly as light intensity increases.',
                        howItWorks:
                            'Fabricated from a Cadmium Sulfide (CdS) semiconductor. Incident photons energize bound valence electrons into the conduction band, increasing free charge carriers and conductivity.',
                        application:
                            'Automatic street lights, camera light meters, solar tracking systems, and clock alarm dimmers.',
                      ),
                      _buildResistorCard(
                        context,
                        name: 'Thermistor (NTC / PTC)',
                        icon: Icons.device_thermostat_rounded,
                        accentColor: const Color(0xFFDC2626),
                        backgroundColor: const Color(0xFFFEF2F2),
                        whatItDoes:
                            'A temperature-sensitive resistor whose resistance varies predictably with thermal changes.',
                        howItWorks:
                            'In NTC (Negative Temperature Coefficient), heat creates extra free electron carriers, reducing resistance. In PTC, resistance spikes sharply at a critical Curie temperature.',
                        application:
                            'Digital thermometers, 3D printer hotend temp monitors, Li-ion battery overheat protection, and inrush current limiters.',
                      ),
                      _buildResistorCard(
                        context,
                        name: 'Varistor (VDR / MOV)',
                        icon: Icons.bolt_rounded,
                        accentColor: const Color(0xFF4338CA),
                        backgroundColor: const Color(0xFFEEF2FF),
                        whatItDoes:
                            'A voltage-dependent non-linear resistor used for transient surge and lightning spike protection.',
                        howItWorks:
                            'Operates as an open circuit (extremely high resistance) at normal operating voltages. When high voltage spikes occur, it abruptly clamps down to low resistance, safely shunting surge energy to ground.',
                        application:
                            'Surge protector power strips, AC mains input protection modules, and automotive electronics.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Banner at the top of the screen.
  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: const Row(
        children: [
          Icon(Icons.category_rounded, color: Color(0xFF7C3AED), size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Types of Resistors Guide',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C1D95),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A quick guide to fixed, variable, and special resistors used in the lab.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
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

  /// Category section heading.
  Widget _buildCategoryHeading(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color badgeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  /// Responsive Grid / Column for cards.
  Widget _buildResponsiveGrid(BuildContext context, {required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        if (isWide) {
          final rows = <Widget>[];
          for (int i = 0; i < children.length; i += 2) {
            final card1 = children[i];
            final card2 = (i + 1 < children.length) ? children[i + 1] : null;

            rows.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: card1),
                    const SizedBox(width: 14),
                    if (card2 != null)
                      Expanded(child: card2)
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            );
          }
          return Column(children: rows);
        }

        return Column(
          children: children
              .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: c,
                  ))
              .toList(),
        );
      },
    );
  }

  /// Detailed Card showing: Name, What it does, How it works, Application.
  Widget _buildResistorCard(
    BuildContext context, {
    required String name,
    required IconData icon,
    required Color accentColor,
    required Color backgroundColor,
    required String whatItDoes,
    required String howItWorks,
    required String application,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon + Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // 1. What it does
            _buildDetailRow(
              tag: 'What it does',
              tagColor: const Color(0xFF0284C7),
              content: whatItDoes,
            ),
            const SizedBox(height: 10),

            // 2. How it works
            _buildDetailRow(
              tag: 'How it works',
              tagColor: const Color(0xFF0D9488),
              content: howItWorks,
            ),
            const SizedBox(height: 10),

            // 3. Common Application
            _buildDetailRow(
              tag: 'Lab Application',
              tagColor: const Color(0xFF7C3AED),
              content: application,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDetailRow({
    required String tag,
    required Color tagColor,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: tagColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: tagColor,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF334155),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
