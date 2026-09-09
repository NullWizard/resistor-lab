import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '../widgets/glass_components.dart';
import '../widgets/resistor_3d_viewer.dart';

/// Screen displaying the comprehensive taxonomy of resistors with interactive
/// 3D CAD models, structural insights, and visionOS liquid glass styling:
/// 1. Fixed Resistors (Carbon Composition, Carbon Film, Metal Film, Wirewound, Cement, SMD)
/// 2. Variable Resistors (Potentiometer, Rheostat, Preset / Trimmer)
/// 3. Special-Purpose Resistors (LDR, Thermistor, Varistor)
class TypesScreen extends StatelessWidget {
  const TypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Types of Resistors'),
      ),
      body: FuturisticBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 90.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Overview Glass Banner
                    _buildHeaderBanner(context),
                    const SizedBox(height: 24),

                    // CATEGORY 1: FIXED RESISTORS
                    _buildCategoryHeading(
                      context,
                      title: '1. Fixed Resistors',
                      subtitle:
                          'Permanent ohmic resistance. Drag any 3D model to inspect in 360°.',
                      badgeColor: const Color(0xFF00E5FF),
                    ),
                    const SizedBox(height: 14),
                    _buildResponsiveGrid(
                      context,
                      children: [
                        _buildResistorCard(
                          context,
                          name: 'Carbon Composition Resistor',
                          modelType: Resistor3DType.carbonComposition,
                          icon: Icons.grain_rounded,
                          accentColor: const Color(0xFFF59E0B),
                          whatItDoes:
                              'Provides fixed electrical resistance with high energy surge absorption capability.',
                          howItWorks:
                              'Constructed from a solid rod of finely ground carbon granules mixed with a ceramic binder. Current passes through microscopic conductive carbon chains.',
                          application:
                              'High-voltage power supplies, surge suppression circuits, and vintage radio equipment.',
                        ),
                        _buildResistorCard(
                          context,
                          name: 'Carbon Film Resistor',
                          modelType: Resistor3DType.carbonFilm,
                          icon: Icons.layers_rounded,
                          accentColor: const Color(0xFFFBBF24),
                          whatItDoes:
                              'General-purpose resistor offering good tolerance (±5%) and better stability than carbon composition.',
                          howItWorks:
                              'A thin pure carbon film is deposited onto a ceramic rod. A helical spiral groove is cut into the film to achieve the exact target resistance value.',
                          application:
                              'Everyday electronic circuits, laboratory breadboard experiments, and consumer electronics.',
                        ),
                        _buildResistorCard(
                          context,
                          name: 'Metal Film Resistor',
                          modelType: Resistor3DType.metalFilm,
                          icon: Icons.precision_manufacturing_rounded,
                          accentColor: const Color(0xFF00E5FF),
                          whatItDoes:
                              'High-precision resistor with ultra-low electrical noise and exceptional temperature stability.',
                          howItWorks:
                              'A microscopic film of nickel-chromium (Nichrome) is vacuum-sputtered onto an alumina core and laser-trimmed to tight tolerances (±1% or ±0.1%).',
                          application:
                              'Precision laboratory instruments, medical monitoring equipment, and Hi-Fi audio amplifiers.',
                        ),
                        _buildResistorCard(
                          context,
                          name: 'Wire Wound Resistor',
                          modelType: Resistor3DType.wireWound,
                          icon: Icons.linear_scale_rounded,
                          accentColor: const Color(0xFFF87171),
                          whatItDoes:
                              'High-power resistor capable of dissipating substantial heat without thermal breakdown.',
                          howItWorks:
                              'Made by winding a high-resistance alloy wire (Nichrome or Manganin) around an insulated ceramic core, coated in vitreous protective enamel.',
                          application:
                              'High-power amplifiers, motor speed controllers, power supplies, and dummy load banks.',
                        ),
                        _buildResistorCard(
                          context,
                          name: 'Cement Power Resistor',
                          modelType: Resistor3DType.cementPower,
                          icon: Icons.square_foot_rounded,
                          accentColor: const Color(0xFFE2E8F0),
                          whatItDoes:
                              'Extreme high-power dissipation resistor designed to endure high surge currents safely.',
                          howItWorks:
                              'Encases a heavy-duty wirewound resistor inside a rectangular ceramic shell potted with fireproof inorganic cement.',
                          application:
                              'Power supply bleeders, automotive ballast resistors, and electrical heating dummy loads.',
                        ),
                        _buildResistorCard(
                          context,
                          name: 'SMD Chip Resistor (0805)',
                          modelType: Resistor3DType.smd,
                          icon: Icons.memory_rounded,
                          accentColor: const Color(0xFF38BDF8),
                          whatItDoes:
                              'Sub-miniature rectangular chip mounted directly onto PCB surface pads for high-density circuits.',
                          howItWorks:
                              'Metal oxide film printed on an alumina ceramic substrate with silver wrap-around solder termination end-caps and numeric 3-digit code.',
                          application:
                              'Smartphones, motherboards, laptops, and all modern miniature consumer electronics.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // CATEGORY 2: VARIABLE RESISTORS
                    _buildCategoryHeading(
                      context,
                      title: '2. Variable Resistors',
                      subtitle:
                          'Resistors whose ohmic resistance can be mechanically or manually adjusted.',
                      badgeColor: const Color(0xFFA855F7),
                    ),
                    const SizedBox(height: 14),
                    _buildResponsiveGrid(
                      context,
                      children: [
                        _buildResistorCard(
                          context,
                          name: 'Potentiometer (Pot)',
                          modelType: Resistor3DType.potentiometer,
                          icon: Icons.tune_rounded,
                          accentColor: const Color(0xFFA855F7),
                          whatItDoes:
                              'A 3-terminal variable resistor primarily configured as an adjustable voltage divider.',
                          howItWorks:
                              'A sliding contact (wiper) mechanically rotates across a fixed resistive track, tapping off an adjustable fraction of the total voltage between terminals 1 and 3.',
                          application:
                              'Rotary volume controls in stereos, game controller joystick position sensing, and laboratory power supply calibration.',
                        ),
                        _buildResistorCard(
                          context,
                          name: 'Rheostat',
                          modelType: Resistor3DType.rheostat,
                          icon: Icons.speed_rounded,
                          accentColor: const Color(0xFF2DD4BF),
                          whatItDoes:
                              'A 2-terminal variable resistor designed to directly control and regulate electric current flow.',
                          howItWorks:
                              'Connected in series with the load. Turning the wiper varies the effective length of resistive wire in the circuit path, changing circuit current (I = V / R).',
                          application:
                              'Incandescent light dimmer controls, laboratory physics experiments, and electric motor speed regulation.',
                        ),
                        _buildResistorCard(
                          context,
                          name: 'Preset / Trimmer (Trimpot)',
                          modelType: Resistor3DType.trimmer,
                          icon: Icons.build_circle_rounded,
                          accentColor: const Color(0xFF60A5FA),
                          whatItDoes:
                              'Miniature adjustable resistor mounted directly onto circuit boards for factory or one-time calibration.',
                          howItWorks:
                              'Features a tiny internal rotary screw adjusted using a precision screwdriver. It is set during manufacturing/tuning and rarely touched again by users.',
                          application:
                              'Calibrating sensor sensitivity, tuning oscillator frequencies, and trimming operational amplifier offset voltages.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // CATEGORY 3: SPECIAL RESISTORS
                    _buildCategoryHeading(
                      context,
                      title: '3. Special-Purpose Resistors',
                      subtitle:
                          'Non-linear resistors whose resistance changes dynamically with external physical stimuli.',
                      badgeColor: const Color(0xFFF97316),
                    ),
                    const SizedBox(height: 14),
                    _buildResponsiveGrid(
                      context,
                      children: [
                        _buildResistorCard(
                          context,
                          name: 'LDR (Light Dependent Resistor)',
                          modelType: Resistor3DType.ldr,
                          icon: Icons.light_mode_rounded,
                          accentColor: const Color(0xFFFBBF24),
                          whatItDoes:
                              'A light-sensitive resistor whose resistance decreases significantly as ambient light intensity increases.',
                          howItWorks:
                              'Fabricated from a Cadmium Sulfide (CdS) semiconductor. Incident photons energize bound valence electrons into the conduction band, increasing free charge carriers.',
                          application:
                              'Automatic street lights, camera light meters, solar tracking systems, and clock alarm dimmers.',
                        ),
                        _buildResistorCard(
                          context,
                          name: 'Thermistor (NTC / PTC)',
                          modelType: Resistor3DType.thermistor,
                          icon: Icons.device_thermostat_rounded,
                          accentColor: const Color(0xFFFB7185),
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
                          modelType: Resistor3DType.varistor,
                          icon: Icons.bolt_rounded,
                          accentColor: const Color(0xFF818CF8),
                          whatItDoes:
                              'A voltage-dependent non-linear resistor used for transient surge and lightning spike protection.',
                          howItWorks:
                              'Operates as an open circuit (high resistance) at normal operating voltages. When high voltage spikes occur, it abruptly clamps down to low resistance, safely shunting surge energy.',
                          application:
                              'Surge protector power strips, AC mains input protection modules, and automotive electronics.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Banner at the top of the screen in visionOS frosted glass styling.
  Widget _buildHeaderBanner(BuildContext context) {
    return GlassContainer(
      borderRadius: 24,
      glowColor: const Color(0xFF00E5FF),
      padding: const EdgeInsets.all(22.0),
      child: Row(
        children: [
          const LiquidGlassIconLens(
            icon: Icons.view_in_ar_rounded,
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
                  label: 'INTERACTIVE 3D CAD TAXONOMY',
                  accentColor: Color(0xFF00E5FF),
                  fontSize: 10,
                ),
                const SizedBox(height: 6),
                Text(
                  '3D Resistor Taxonomy & Models',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8FAFC),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Drag any model in 360° to inspect internal materials, resistive elements, and contacts.',
                  style: const TextStyle(
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

  /// Category section heading with futuristic neon accent.
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
              height: 20,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8FAFC),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
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
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: card1),
                    const SizedBox(width: 16),
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
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: c,
                  ))
              .toList(),
        );
      },
    );
  }

  /// Detailed Card showing: Name, Interactive 3D Model, What it does, How it works, Application.
  Widget _buildResistorCard(
    BuildContext context, {
    required String name,
    required Resistor3DType modelType,
    required IconData icon,
    required Color accentColor,
    required String whatItDoes,
    required String howItWorks,
    required String application,
  }) {
    return GlassContainer(
      borderRadius: 22,
      padding: const EdgeInsets.all(20.0),
      glowColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Liquid Glass Icon Lens + Name
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LiquidGlassIconLens(
                icon: icon,
                accentColor: accentColor,
                size: 46,
                iconSize: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8FAFC),
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Interactive 3D Model Viewport
          Resistor3DViewer(
            type: modelType,
            height: 155,
            title: name,
          ),
          const SizedBox(height: 16),

          // 1. What it does
          _buildDetailRow(
            tag: 'Function',
            tagColor: const Color(0xFF00E5FF),
            content: whatItDoes,
          ),
          const SizedBox(height: 12),

          // 2. How it works
          _buildDetailRow(
            tag: 'Internal Structure',
            tagColor: const Color(0xFF2DD4BF),
            content: howItWorks,
          ),
          const SizedBox(height: 12),

          // 3. Common Application
          _buildDetailRow(
            tag: 'Lab Application',
            tagColor: const Color(0xFFA855F7),
            content: application,
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow({
    required String tag,
    required Color tagColor,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF070F1C).withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tagColor.withValues(alpha: 0.20),
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassBadge(
            label: tag,
            accentColor: tagColor,
            fontSize: 9.5,
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFFCBD5E1),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
